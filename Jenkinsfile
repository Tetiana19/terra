pipeline {
    agent any
    tools {
         terraform 'terra'
}

    stages {
        stage('Git checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Tetiana19/terra.git']]])
            }
        }
        
        
        
        stage('Terraform init') {
            steps {
                azureCLI commands: [[exportVariablesString: '', script: '']], principalCredentialId: 'AzureTerra'
                sh 'terraform init'
            }
        }
        stage('Terraform apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }

}
