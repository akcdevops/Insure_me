pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
    }

    stages {
        stage('git checkout') {
            steps {
                // Get some code from a GitHub repository
                git branch: 'master', url: 'https://github.com/akcdevops/Insure_me.git'
                
            }
        }
        stage('Build'){
            steps{
               sh 'mvn clean package install site surefire-report:report'
            }
            
        }
        stage('Artifact Upload to S3'){
            steps{
               script{
                 withAWS(credentials: 'awscred',region: 'ap-south-1') 
                 {
                    s3Upload(bucket: 'akcdevops-project1', path: '/target/insure-me-1.0.jar',file: 'target/insure-me-1.0.jar')
                 }
               } 
            }
             post {
                success {
                    slackSend channel: '#jenkins_anil',
                              color: 'green',
                              message: "Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' - SUCCESSFUL!"
                }
                failure {
                    slackSend channel: '#jenkins_anil',
                              color: 'red',
                              message: "Build '${env.JOB_NAME} [${env.BUILD_NUMBER}]' - FAILED!"
                }
            }

        }
       
    }
    post{
        success{
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'target/surefire-reports', reportFiles: 'surefire-report.html', reportName: 'Surefire Report', reportTitles: '', useWrapperFileDirectly: true])
        }
    }
}