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
               sh 'mvn clean package'
            }
        }
        stage('Artifact Upload to S3'){
            steps{
               script{
                 withAWS(credentials: 'awscred',region: 'ap-south-1') 
                 {
                    s3Upload(bucket: 'akcdevops-project1', path: 'target/project1-0.0.1-SNAPSHOT.war',file: 'target/project1-0.0.1-SNAPSHOT.war')
                 }
               } 
            }

        }
        
    }
}