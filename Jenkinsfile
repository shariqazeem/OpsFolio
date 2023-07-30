pipeline {
    agent any
    environment {
        buildTag = "V${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/shariqazeem/OpsFolio.git'
            }
        }

        stage('Docker Build and Tag') {
            steps {
                script {
                    try {
                        sh "docker build -t resume:${buildTag} ."
                        sh "docker tag resume:${buildTag} shariqazeem/resume:${buildTag}"
                    } catch (Exception e) {
                        // Handle build failure
                        error "Docker build failed: ${e.getMessage()}"
                    } finally {
                        // Cleanup intermediate or failed images
                        sh "docker rmi resume:${buildTag}"
                    }
                }
            }
        }


        stage('Publish image to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                    sh "docker push shariqazeem/resume:${buildTag}"
                }
            }
        }

        stage('Stop and Delete App on Remote Instance') {
            steps {
                sshagent(credentials: ['ssh-credentials-id']) {
                    script {
                        try {
                            def containerIds = sh(
                                returnStdout: true,
                                script: 'ssh -o StrictHostKeyChecking=no ubuntu@13.59.37.218 docker ps -q'
                            ).trim()

                            if (containerIds) {
                                sh "docker -H ssh://ubuntu@13.59.37.218 stop ${containerIds}"
                                sh "docker -H ssh://ubuntu@13.59.37.218 rm ${containerIds}"
                            } else {
                                echo "No running containers exist. Proceeding with the deployment."
                            }
                        } catch (Exception e) {
                            error "Error stopping or deleting containers: ${e.getMessage()}"
                        }
                    }
                }
            }
        }


        stage('Deploy New Version on Remote Instance') {
            steps {
                sshagent(credentials: ['ssh-credentials-id']) {
                    sh "docker -H ssh://ubuntu@13.59.37.218 pull shariqazeem/resume:${buildTag}"
                    sh "docker -H ssh://ubuntu@13.59.37.218 run -d -p 3000:3000 shariqazeem/resume:${buildTag}"
                }
            }
        }
    }
}
