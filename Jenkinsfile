pipeline {
    agent any
    tools {
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
                    withAWS(credentials: 'awscred',region: 'ap-south-1') {
                        s3Upload(bucket: 'insureme-project', path: '/target/insure-me-1.0.jar',file: 'target/insure-me-1.0.jar')
                    }
                } 
            }
             

        }
        stage('Docker Build & Run'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    script{ 
                        sh 'docker build -t ${DOCKER_HUB}/${IMAGE_NAME}:${VERSION} . '
                        sh 'docker build -t ${DOCKER_HUB}/${IMAGE_NAME}:latest .' 
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
                        sh 'docker rmi ${DOCKER_HUB}/${IMAGE_NAME}:latest'
                    
                    }
                }
            }

        } 
        stage('Push to ECR') {
            steps {
                script {
                    withAWS(credentials: 'awscred',region: 'ap-south-1') {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                        sh "docker build -t ${IMAGE_NAME}:${VERSION} ."
                        sh "docker tag ${IMAGE_NAME}:${VERSION} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${VERSION}"
                        def ecrRepoUriversion = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${VERSION}"
                        sh "docker push $ecrRepoUriversion"
                        sh "docker rmi ${IMAGE_NAME}:${VERSION}"
                        sh "docker rmi $ecrRepoUriversion"
                    }
                }
            }
        }
        stage('Provisioning Dev Server'){
            steps{
                script{ 
                    sh "sudo terraform workspace select dev"
                    sh "sudo terraform init "
                    sh "sudo terraform validate"
                    sh "sudo terraform plan -var-file=dev.tfvars"
                    sh "sudo terraform apply -var-file=dev.tfvars --auto-approve" 
                }
            }
        }
        stage('Provisioning Prod Server'){
            steps{
                script{ 
                    sh "sudo terraform workspace select prod"
                    sh "sudo terraform init"
                    sh "sudo terraform validate"
                    sh "sudo terraform plan -var-file=prod.tfvars"
                    sh "sudo terraform apply -var-file=prod.tfvars --auto-approve"
                }
            }
        }
        stage('Ansible Dynamic Inventory & ping_playbook'){
            steps{
                script{
                    sh "sleep 2m"
                    withAWS(credentials: 'awscred',region: 'ap-south-1') {
                        sh "sudo ansible-inventory -i aws_ec2.yml --graph"
                        sh "sudo ansible-playbook -i aws_ec2.yml tomcat_playbook.yml"
                    }
                }
            }
           
        }
        stage('Destroy dev & Prod Infrs'){
            steps{
                script{  
                    def USER_INPUT = input(
                    message: 'you wnat Destroy the Dev and Prod Infra?',
                    parameters: [
                        [$class: 'ChoiceParameterDefinition',
                        choices: ['destroy'].join('\n'),
                        name: 'input',
                        description: 'Menu - select box option']
                    ])
                    echo "The answer is: ${USER_INPUT}"
                    if( "${USER_INPUT}" == "destroy"){
                        sh "sudo terraform workspace select prod"
                        sh "sudo terraform destroy -var-file=prod.tfvars --auto-approve"
                        sh "sudo terraform workspace select dev"
                        sh "sudo terraform destroy -var-file=dev.tfvars --auto-approve"

                    } else {
                        //do something else
                    }
                }
            }
        }
        
    }
    post{
        success{
            publishHTML([ allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/site', reportFiles: 'surefire-report.html', reportName: 'Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}