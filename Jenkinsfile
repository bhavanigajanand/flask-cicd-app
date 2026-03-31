pipeline {
    agent any

    environment {
        DOCKER_IMAGE   = "bhavanigajanand/flask-cicd-app"
        DOCKER_TAG     = "${BUILD_NUMBER}"
        REGISTRY_CREDS = 'dockerhub-credentials'
        EC2_HOST       = "ubuntu@3.85.241.67"
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

        stage('Deploy with Docker Compose') {
            steps {
                echo 'Deploying with Docker Compose...'
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-key',
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh """
                        # Copy docker-compose.yml to EC2
                        scp -i $SSH_KEY -o StrictHostKeyChecking=no \
                            docker-compose.yml ${EC2_HOST}:/home/ubuntu/

                        # Pull latest image and restart container
                        ssh -i $SSH_KEY -o StrictHostKeyChecking=no ${EC2_HOST} '
                            docker pull bhavanigajanand/flask-cicd-app:latest
                            docker-compose -f /home/ubuntu/docker-compose.yml up -d --force-recreate
                            docker ps
                        '
                    """
                }
            }
        }

    }

    post {
        success {
            echo "✅ Pipeline succeeded! Build #${BUILD_NUMBER} deployed."
        }
        failure {
            echo "❌ Pipeline failed. Check logs above."
        }
        always {
            sh 'docker logout || true'
        }
    }
}
