 # Require the dependencies file to load the vendor libraries
require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class SharepointListItemsRetrieveV1

  def initialize(input)
    java_import org.apache.http.HttpHost;
    java_import org.apache.http.HttpResponse
    java_import org.apache.http.auth.AuthSchemeProvider;
    java_import org.apache.http.auth.AuthScope;
    java_import org.apache.http.auth.NTCredentials;
    java_import org.apache.http.client.CredentialsProvider;
    java_import org.apache.http.client.HttpClient
    java_import org.apache.http.client.config.AuthSchemes;
    java_import org.apache.http.client.methods.HttpGet;
    java_import org.apache.http.client.protocol.HttpClientContext;
    java_import org.apache.http.config.RegistryBuilder;
    java_import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
    java_import org.apache.http.conn.ssl.SSLContextBuilder
    java_import org.apache.http.conn.ssl.TrustSelfSignedStrategy
    java_import org.apache.http.impl.auth.NTLMSchemeFactory;
    java_import org.apache.http.impl.client.BasicCredentialsProvider;
    java_import org.apache.http.impl.client.HttpClients;
    java_import org.apache.http.util.EntityUtils

    # Set the input document attribute
    @input_document = REXML::Document.new(input)

    # Store the info values in a Hash of info names to values.
    @info_values = {}
    REXML::XPath.each(@input_document,"/handler/infos/info") { |item|
      @info_values[item.attributes['name']] = item.text
    }

    @enable_debug_logging = @info_values['enable_debug_logging'] == 'Yes'

    # Retrieve all of the handler parameters and store them in a hash attribute
    # named @parameters.
    @parameters = {}
    REXML::XPath.match(@input_document, '/handler/parameters/parameter').each do |node|
      # Associate the attribute name to the String value (stripping leading and
      # trailing whitespace)
      @parameters[node.attribute('name').value] = node.text.to_s.strip
    end

    # Initialize the field values hash
    @attachment_field_values = {}
    # For each of the fields in the node.xml file, add them to the hash
    REXML::XPath.match(@input_document, '/handler/attachment_fields/field').each do |node|
      @attachment_field_values[node.attribute('name').value] = node.text
    end
  end

  # This is a required method that is automatically called by the Kinetic Task
  # Engine.
  def execute()
    nt_creds = NTCredentials.new(@info_values["username"],@info_values["password"],"",@info_values["domain"])

    authRegistry = RegistryBuilder.create().register(AuthSchemes::NTLM, NTLMSchemeFactory.new).build();
    credsProvider = BasicCredentialsProvider.new;
    credsProvider.setCredentials(AuthScope::ANY, NTCredentials.new(@info_values["username"],@info_values["password"],"",@info_values["domain"]))

    builder = SSLContextBuilder.new
    builder.loadTrustMaterial(nil, TrustSelfSignedStrategy.new)
    sslsf = SSLConnectionSocketFactory.new(builder.build(), SSLConnectionSocketFactory::ALLOW_ALL_HOSTNAME_VERIFIER)

    # Generate target values
    protocol = @info_values["sharepoint_location"].split("://")[0]
    host = @info_values["sharepoint_location"].gsub(protocol+"://","").split(":")[0]
    # See if a port was included in the sharepoint_location
    m = /#{Regexp.escape(protocol+"://"+host)}:(.*?)(?:\/|$)/.match(@info_values["sharepoint_location"])
    # Port is equal to the port included in the url, 443 (https), or 80 (http)
    port = !m.nil? ? m[1] : protocol == "https" ? "443" : "80"

    client = HttpClients.custom().setSSLSocketFactory(sslsf).setDefaultAuthSchemeRegistry(authRegistry).build();

    target = HttpHost.new(host, port.to_i, protocol)

    #Make sure the same context is used to execute logically related requests
    context = HttpClientContext.create()
    context.setCredentialsProvider(credsProvider)

    homepage_url = "#{@info_values['sharepoint_location'].chomp("/")}/#{@info_values['site_path'].to_s.reverse.chomp("/").reverse}"

    httpget = HttpGet.new("#{homepage_url.chomp("/")}/_api/web/lists/GetByTitle('#{URI.encode(@parameters['list_name'])}')/items")
    httpget.setHeader("Accept","application/json; odata=verbose")
    response = client.execute(target, httpget, context)
    check_for_sp_error(response)

    responseString = EntityUtils.toString(response.getEntity())

    items = []
    json = JSON.parse(responseString)
    json["d"]["results"].each do |item|
      i = {}
      item.each {|k,v| i[k.gsub("_x0020_"," ")] = v if !(v.is_a? Hash)}
      items.push(i)
    end

    return <<-RESULTS
    <results>
      <result name="Items">#{items}</result>
    </results>
    RESULTS
  end

  def check_for_sp_error(response)
    code = response.get_status_line.status_code
    if code.to_s.slice(0) != "2"
      puts "An error with the code '#{code}' was encountered. The server response is below."
      puts EntityUtils.toString(response.getEntity())
      if code == 401
        raise "401 Unauthorized: An invalid username/password combination was supplied"
      else
        raise "#{code} Error Code: Check the logs for the server response"
      end
    end
  end

  # This is a template method that is used to escape results values (returned in
  # execute) that would cause the XML to be invalid.  This method is not
  # necessary if values do not contain character that have special meaning in
  # XML (&, ", <, and >), however it is a good practice to use it for all return
  # variable results in case the value could include one of those characters in
  # the future.  This method can be copied and reused between handlers.
  def escape(string)
    # Globally replace characters based on the ESCAPE_CHARACTERS constant
    string.to_s.gsub(/[&"><]/) { |special| ESCAPE_CHARACTERS[special] } if string
  end
  # This is a ruby constant that is used by the escape method
  ESCAPE_CHARACTERS = {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '"' => '&quot;'}
end