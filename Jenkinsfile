pipeline {
    agent any

    environment {
        DOCKER_IMAGE     = "bhavanigajanand/flask-cicd-app"
        DOCKER_TAG       = "${BUILD_NUMBER}"
        REGISTRY_CREDS   = 'dockerhub-credentials'
        GITHUB_CREDS     = 'github-credentials'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                withCredentials([usernamePassword(
                    credentialsId: "${REGISTRY_CREDS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    kubectl set image deployment/flask-app \
                        flask-app=${DOCKER_IMAGE}:${DOCKER_TAG} \
                        --record
                    kubectl rollout status deployment/flask-app
                """
            }
        }

    }

    post {
        success {
            echo "✅ Pipeline succeeded! Build #${BUILD_NUMBER} deployed."
        }
        failure {
            echo "❌ Pipeline failed at stage. Check logs above."
        }
        always {
            sh 'docker logout'
        }
    }
}