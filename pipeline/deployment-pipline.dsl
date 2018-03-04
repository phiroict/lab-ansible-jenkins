pipeline {
    agent any
    stages {
        stage('Create QA servers') {
            steps {
                build 'QA-create-instances'
            }
        }
        stage('Install QA applications') {
            steps {
                build 'QA-install-apps'
            }
        }
        stage('Test QA application') {
            steps {
                build 'QA-smoke-test'
            }
        }
        stage('Delete QA servers') {
            steps {
                build 'QA-delete-instances'
            }
        }
    }
    post {
        failure {
          build 'QA-delete-instances'
        }
      }
}