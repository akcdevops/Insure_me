pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }
    environment {
    IMAGE_NAME = "challagondlaanilkumar/insureme"
    CONTAINER_NAME = "insureme"
    VERSION = "v${env.BUILD_NUMBER}"
    }


    stages {
        stage('git checkout') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'master', url: 'https://github.com/akcdevops/Insure_me.git'
            }
            post {
                always{
                  slackSend channel: 'jenkins', 
                  color: 'green', 
                  message:"started  JOB_NAME:${env.JOB_NAME} BUILD_NUMBER:${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)",
                  notifyCommitters: true,  
                  teamDomain: 'dwithitechnologies', 
                  tokenCredentialId: 'slack'
                }
            }
        }
        stage('Build')
        {
            steps
            {
               sh 'mvn clean package install site surefire-report:report'
            }  
        }
        stage('Artifact Upload to S3'){
            steps{
               script{
                 withAWS(credentials: 'awscred',region: 'ap-south-1') 
                 {
                    s3Upload(bucket: 'insureme-project', path: '/target/insure-me-1.0.jar',file: 'target/insure-me-1.0.jar')
                 }
               } 
            }
             

        }
        stage('Docker Build & Run'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script{ 
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                        // def containerExists = sh(returnStatus: true, script: "docker ps -aq --filter name=${CONTAINER_NAME}").trim() != ''
                        // if (containerExists) {
                        //     // // Check container status (running or stopped)
                        //     // def containerStatus = sh(returnStatus: true, script: "docker inspect --format '{{.State.Status}}' ${CONTAINER_NAME}").trim()
                        //     //     if (containerStatus == 'stopped') {
                        //     //         echo "Container '${CONTAINER_NAME}' is stopped. Condition met."
                        //     //         // Add steps to proceed based on the stopped container (optional)
                        //     //     } else {
                        //     //         echo "Container '${CONTAINER_NAME}' is not stopped. Skipping actions."
                        //     //     }
                        //     sh 'docker stop ${CONTAINER_NAME}'
                        //     sh 'docker rm ${CONTAINER_NAME}'
                        // } else {
                            // echo "Container '${CONTAINER_NAME}' not found."
                            sh 'docker build -t ${IMAGE_NAME}:${VERSION} . '
                            sh 'docker build -t ${IMAGE_NAME}:latest . '
                            sh 'docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${IMAGE_NAME}:latest'
                        // } 
                    }
                }
                
            }

        }
        stage('Docker Push'){
            steps{
                 withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                script{
                   sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                   sh 'docker push ${IMAGE_NAME}:${VERSION} && docker push ${IMAGE_NAME}:latest'
                   sh 'docker rmi ${IMAGE_NAME}:${VERSION}'
                   
                }
                }
            }

        }  
    }
    post{
        success{
            publishHTML([
                allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site', reportFiles: 'surefire-report.html', reportName: 'Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}