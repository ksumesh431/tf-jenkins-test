// Jenkinsfile for Terraform pipeline with apply/destroy choice
pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose Terraform action to execute')
    }
    environment {
        TF_VAR_region = 'us-east-1'
        TF_VERSION = '1.9.8' // Specify the required Terraform version
    }
    options {
        timestamps()            
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }
    stages {
        stage('Install Terraform') {
            steps {
                ansiColor('xterm') {
                    script {
                        sh """
                            if ! terraform --version | grep -q '${TF_VERSION}'; then
                                curl -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                                unzip terraform.zip
                                sudo mv terraform /usr/local/bin/
                                rm terraform.zip
                            fi
                            terraform --version
                        """
                    }
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                ansiColor('xterm') {
                    sh 'terraform init -input=false'
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                ansiColor('xterm') {
                    sh 'terraform validate'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                ansiColor('xterm') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform plan -out=tfplan -input=false'
                        } else if (params.ACTION == 'destroy') {
                            sh 'terraform plan -destroy -out=tfplan -input=false'
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
                }
            }
        }
        
        stage('Terraform Apply/Destroy') {
            when {
                expression {
                    (params.ACTION == 'apply' && BRANCH_NAME == 'main' && input(message: 'Proceed with Apply?')) || 
                    (params.ACTION == 'destroy' && input(message: 'Proceed with Destroy?'))
                }
            }
            steps {
                ansiColor('xterm') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -input=false tfplan'
                        } else if (params.ACTION == 'destroy') {
                            sh 'terraform apply -destroy -input=false tfplan'
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Terraform pipeline completed successfully!'
        }
        failure {
            echo 'Terraform pipeline failed.'
        }
    }
}
