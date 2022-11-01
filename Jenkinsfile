pipeline {
    agent any

    stages {
                
        stage('code scanning'){
            environment {
                scannerHome = tool 'CliScanner'
            }
            steps {             
                withSonarQubeEnv('sq1'){                    
                        echo 'Start Scanning...'
                        sh '${scannerHome}/bin/sonar-scanner'}
                
            }
        }
    }
}
