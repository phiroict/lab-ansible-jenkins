pipeline {
    agent any
    stages {
        stage('Delete QA servers') {
            steps {
                build 'QA-delete-instances'
            }
        }
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
        stage('Create PROD instances') {
            steps {
                build 'PROD-create-instances'
            }
        }
        stage('Install PROD applications') {
            steps {
                build 'PROD-install-apps'
            }
        }
    }
    post {
        failure {
            build 'QA-delete-instances'
        }
    }
}