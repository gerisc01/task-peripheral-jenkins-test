pipeline {
  agent any
  stages {
    stage('Environment Setup') {
      steps {
        echo 'Retrieving the scripts from GitHub'
        dir('scripts') {
            git(
                url: 'https://github.com/kineticdata/task-handler-upload-automate.git',
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
        sh "ruby scripts/inspect_handler_changes.rb -c $GIT_PREVIOUS_SUCCESSFUL_COMMIT -l `pwd`"
      }
    }
    stage('Upload Modified Handlers') {
      when { branch 'master' }
      steps {
        echo "Uploading handlers to Kinetic Community and Amazon S3"
      }
    }
  }
}