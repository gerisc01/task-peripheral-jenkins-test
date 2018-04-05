pipeline {
  agent any
  stages {
    stage('Environment Setup') {
      steps {
        echo 'Retrieving the scripts from GitHub'
        dir('scripts') {
            git(
                url: 'https://github.com/gerisc01/task-handler-upload-automate.git',
                branch: 'master',
                credentialsId: '2fc84922-6fc5-4613-a67a-57fcf566bbb6'
            )
            sh 'bundle install --path vendor/bundle'
        }
      }
    }
    stage('Check for Handler Changes') {
      steps {
        echo "Finding what handlers have changed since the last git commit"
        sh 'ruby scripts/inspect_handler_changes.rb -c $GIT_PREVIOUS_COMMIT -l "`pwd`"'
      }
    }
    stage('Upload Modified Handlers') {
      when { branch 'master' }
      steps {
        echo "Upload to S3 task-handlers bucket"
        withCredentials([usernamePassword(credentialsId: 'd9b3e21f-24a7-4d0b-8be8-e55eab29894f',usernameVariable: 'AWS_KEY',passwordVariable: 'AWS_SECRET')]) {
          sh 'ruby scripts/upload_to_s3.rb -a $AWS_KEY -s $AWS_SECRET -r "us-east-1" -l "`pwd`"'
        }

        echo "Upload to Kinetic Community"
        withCredentials([usernamePassword(credentialsId: '145a8493-62da-40cc-866b-454feb15d32d',usernameVariable: 'KD_USER',passwordVariable: 'KD_PASS')]) {
          sh 'ruby scripts/upload_to_community.rb -u $KD_USER -p $KD_PASS -l "`pwd`"'
        }
      }
    }
  }
}