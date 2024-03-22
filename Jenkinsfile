pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }
    environment {
    DOCKER_HUB = "challagondlaanilkumar"
    ECR = ""
    IMAGE_NAME = "insureme"
    CONTAINER_NAME = "insureme"
    VERSION = "v${env.BUILD_NUMBER}"
    AWS_ACCOUNT_ID = "339713145834"
    AWS_REGION = "ap-south-1"

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
                            
                            sh 'docker build -t ${DOCKER_HUB}/${IMAGE_NAME}:${VERSION} . '
                            sh 'docker build -t ${DOCKER_HUB}/${IMAGE_NAME}:latest .'
                            sh 'docker stop ${CONTAINER_NAME}'
                            sh 'docker rm ${CONTAINER_NAME}'
                            sh 'docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${DOCKER_HUB}/${IMAGE_NAME}:latest'
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
                   sh 'docker push ${DOCKER_HUB}/${IMAGE_NAME}:${VERSION} && docker push ${DOCKER_HUB}/${IMAGE_NAME}:latest'
                   sh 'docker rmi ${DOCKER_HUB}/${IMAGE_NAME}:${VERSION}'
                   
                }
                }
            }

        } 
        stage('Push to ECR') {
            steps {
                script {
                    withAWS(credentials: 'awscred',region: 'ap-south-1') {
                    // Get ECR login command (replace with your region if different)
                    //  sh "aws ecr get-authorization-token --region ${AWS_REGION} --query authorizationData[0].authorizationToken | tr -d '\r'"
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    sh "docker build -t ${IMAGE_NAME}:${VERSION} ."
                    // Construct the ECR repository URI
                    sh "docker tag ${IMAGE_NAME}:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${VERSION}"
                    def ecrRepoUriversion = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${VERSION}"
                    // Push the image to ECR
                    sh "docker push $ecrRepoUriversion"
                    sh "docker rmi ${IMAGE_NAME}:${VERSION}"
                 }
                }
            }
        } 
        stage('Ansible Dynamic Inventory & ping_playbook'){
            steps{
                script{
                    withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
                    def inventoryScript = 'inventory.py'
                    def playbookName = 'ping_playbook.yml'

                    // Optional: Define additional Ansible options (e.g., extra-vars)
                    def ansibleOptions = '-e host_group=\\"tag_${TagKey}_${TagValue}\\"'

                    sh """
                        ansible-playbook -i "$(python ${inventoryScript})" ${ansibleOptions} ${playbookName}
                    """
                      } 
                    // withAWS(credentials: 'awscred',region: 'ap-south-1') {
                    // // ansiblePlaybook becomeUser: 'ubuntu', credentialsId: 'akcdevops.pem', installation: 'ansible', inventory: 'aws_ec2.yml', playbook: 'ping_playbook.yml'
                    // sh "ansible-inventory -i aws_ec2.yml --graph"
                    // sh "ansible-playbook -i aws_ec2.yml ping_playbook.yml"
                    // // ansiblePlaybook become: true, becomeUser: 'ubuntu', credentialsId: 'akcdevops.pem', disableHostKeyChecking: true, extras: '-e host_group=\\"tag_${TagKey}_${TagValue}\\"', installation: 'ansible', inventory: 'etc/ansible/aws_ec2.yml', playbook: '/etc/ansible/ping.yml', vaultTmpPath: ''
                    //  }
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