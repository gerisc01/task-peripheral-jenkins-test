require 'java'
require 'uri'

# Attempt to load a class from the http-core package.
begin
  org.apache.http.Header
# If JRuby was unable to load the Document class.
rescue NameError
  # Require the java package.
  handler_path = File.expand_path(File.dirname(__FILE__))
  require File.join(handler_path, 'vendor', 'httpcore-4.4.1.jar')
end

# Attempt to load a class from the http-client package.
begin
  org.apache.http.entity.mime.Header
# If JRuby was unable to load the ServiceInstance class.
rescue NameError
  # Require the java package.
  handler_path = File.expand_path(File.dirname(__FILE__))
  require File.join(handler_path, 'vendor', 'httpmime-4.5.jar')
end

# Attempt to load a class from the http-client package.
begin
  org.apache.http.client.HttpClient
# If JRuby was unable to load the ServiceInstance class.
rescue NameError
  # Require the java package.
  handler_path = File.expand_path(File.dirname(__FILE__))
  require File.join(handler_path, 'vendor', 'httpclient-4.5.jar')
end

# Attempt to load a class from the commons-logging package
begin
  org.apache.commons.logging.LogFactory
# If JRuby was unable to load the ServiceInstance class.
rescue NameError
  # Require the java package.
  handler_path = File.expand_path(File.dirname(__FILE__))
  require File.join(handler_path, 'vendor', 'commons-logging-1.1.1.jar')
end

# Attempt to load a class from the commons-codec package
begin
  org.apache.commons.codec.binary.Base64
# If JRuby was unable to load the Base64 class.
rescue NameError
  # Require the java package.
  handler_path = File.expand_path(File.dirname(__FILE__))
  require File.join(handler_path, 'vendor', 'commons-codec-1.9.jar')
end
