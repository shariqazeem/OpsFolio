pipeline {
    agent any
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
                        def buildTag = "V${env.BUILD_NUMBER}"

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
                                script: 'ssh -o StrictHostKeyChecking=no ubuntu@3.144.167.38 docker ps -q'
                            ).trim()

                            if (containerIds) {
                                sh "docker -H ssh://ubuntu@3.144.167.38 stop ${containerIds}"
                                sh "docker -H ssh://ubuntu@3.144.167.38 rm ${containerIds}"
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
                    sh "docker -H ssh://ubuntu@3.144.167.38 pull shariqazeem/resume:${buildTag}"
                    sh "docker -H ssh://ubuntu@3.144.167.38 run -d -p 3000:3000 shariqazeem/resume:${buildTag}"
                }
            }
        }
    }
}
