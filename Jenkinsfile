pipeline {
    agent any
    options {
        timestamps()
    }
    environment {
        CI = 'true'
    }
    stages {
        stage("Init") {
            steps {
                sh "docker-compose down -v --remove-orphans"
            }
        }
        stage("Down") {
            steps {
                sh "docker-compose down -v --remove-orphans"
            }
        }
    }
    post {
        always {
            sh "docker-compose down -v --remove-orphans || true"
        }
    }
}
