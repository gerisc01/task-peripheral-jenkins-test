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
          echo "The branch for this call is $GIT_BRANCH"
        }
    }
  }
}