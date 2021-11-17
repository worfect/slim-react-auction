pipeline {
    agent any
    options {
        timestamps()
    }
    environment {
        CI = 'true'
        REGISTRY = credentials("REGISTRY")
        IMAGE_TAG = sh(returnStdout: true, script: "echo '${env.BUILD_TAG}' | sed 's/%2F/-/g'").trim()
        GIT_DIFF_BASE_COMMIT = sh(
            returnStdout: true,
            script: "echo ${env.GIT_PREVIOUS_SUCCESSFUL_COMMIT ?: '`git rev-list HEAD | tail -n 1`'}"
        ).trim()
        GIT_DIFF_API = sh(
            returnStdout: true,
            script: "git diff --name-only ${env.GIT_DIFF_BASE_COMMIT} HEAD -- api || echo 'all'"
        ).trim()
        GIT_DIFF_FRONTEND = sh(
            returnStdout: true,
            script: "git diff --name-only ${env.GIT_DIFF_BASE_COMMIT} HEAD -- frontend || echo 'all'"
        ).trim()
        GIT_DIFF_CUCUMBER = sh(
            returnStdout: true,
            script: "git diff --name-only ${env.GIT_DIFF_BASE_COMMIT} HEAD -- cucumber || echo 'all'"
        ).trim()
        GIT_DIFF_ROOT = sh(
            returnStdout: true,
            script: "{ git diff --name-only ${env.GIT_DIFF_BASE_COMMIT} HEAD -- . || echo 'all'; } | { grep -v / - || true; }"
        ).trim()
    }
    stages {
        stage("Init") {
            steps {
                sh "touch .docker-images-before"
                sh "make init-ci"
                sh "docker-compose images > .docker-images-after"
                script {
                    DOCKER_DIFF = sh(
                        returnStdout: true,
                        script: "diff .docker-images-before .docker-images-after || true"
                    ).trim()
                }
            }
        }
        stage("Valid") {
            when {
                expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_API }
            }
            steps {
                sh "make api-validate-schema"
            }
        }
        stage("Lint") {
            parallel {
                stage("API") {
                    when {
                        expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_API }
                    }
                    steps {
                        sh "make api-lint"
                    }
                }
                stage("Frontend") {
                    when {
                        expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_FRONTEND }
                    }
                    steps {
                        sh "make frontend-lint"
                    }
                }
                stage("Cucumber") {
                     when {
                        expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_CUCUMBER }
                    }
                    steps {
                        sh "make cucumber-lint"
                    }
                }
            }
        }
        stage("Analyze") {
            when {
                expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_API }
            }
            steps {
                sh "make api-analyze"
            }
        }
        stage("Test") {
            parallel {
                stage("API") {
                    when {
                        expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_API }
                    }
                    steps {
                        sh "make api-test"
                    }
                }
                stage("Front") {
                    when {
                        expression { return DOCKER_DIFF || env.GIT_DIFF_ROOT || env.GIT_DIFF_FRONTEND }
                    }
                    steps {
                        sh "make frontend-test"
                    }
                }
            }
        }
        stage("Down") {
            steps {
                sh "make d-down-clear"
            }
        }
        stage("Build") {
            steps {
                sh "make build-prod"
            }
        }
        stage("Testing") {
            stages {
                stage("Build") {
                    steps {
                        sh "make testing-build"
                    }
                }
                stage("Init") {
                    steps {
                        sh "make testing-init"
                    }
                }
                stage("Smoke") {
                    steps {
                        sh "make testing-smoke"
                    }
                }
                stage("E2E") {
                    steps {
                        sh "make testing-e2e"
                    }
                }
                stage("Down") {
                    steps {
                        sh "make testing-down-clear"
                    }
                }
            }
        }
        stage("Push") {
            when {
                branch "master"
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'REGISTRY_AUTH',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASSWORD'
                    )
                ]) {
                    sh "docker login -u=$USER -p='$PASSWORD' $REGISTRY"
                }
                sh "make push-prod"
            }
        }
        stage ('Prod') {
            when {
                branch "master"
            }
            steps {
                withCredentials([
                    string(credentialsId: 'HOST', variable: 'HOST'),
                    string(credentialsId: 'PORT', variable: 'PORT'),
                    string(credentialsId: 'API_DB_PASSWORD', variable: 'API_DB_PASSWORD'),
                    string(credentialsId: 'API_MAILER_HOST', variable: 'API_MAILER_HOST'),
                    string(credentialsId: 'API_MAILER_PORT', variable: 'API_MAILER_PORT'),
                    string(credentialsId: 'API_MAILER_USER', variable: 'API_MAILER_USER'),
                    string(credentialsId: 'API_MAILER_PASSWORD', variable: 'API_MAILER_PASSWORD'),
                    string(credentialsId: 'API_MAILER_FROM_EMAIL', variable: 'API_MAILER_FROM_EMAIL'),
                ]) {
                    sshagent (credentials: ['AUTH']) {
                        sh "BUILD_NUMBER=${env.BUILD_NUMBER} make deploy"
                    }
                }
            }
        }
    }
    post {
        success {
            sh "mv -f .docker-images-after .docker-images-before"
        }
        always {
            sh "make d-down-clear || true"
            sh "make testing-down-clear || true"
            sh "make deploy-clean || true"
        }
    }
}
