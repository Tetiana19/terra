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
                sh  'az login --service-principal -u 6e4b4e8e-c7dc-40ab-a7c0-0e823507f5cd -p VITN4WwZMLOwBWjaJ-kRaJNrupWEDXC3BZ -t b41b72d0-4e9f-4c26-8a69-f949f367c91d
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
