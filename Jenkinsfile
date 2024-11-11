// Jenkinsfile for Terraform pipeline with apply/destroy choice
pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose Terraform action to execute')
    }
    environment {
        TF_VERSION = '1.9.8' // Specify the required Terraform version
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
        ansiColor('xterm')
    }
    stages {
        stage('Install Terraform') {
            steps {
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

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        sh 'terraform plan -out=tfplan -input=false'
                    } else if (params.ACTION == 'destroy') {
                        sh 'terraform plan -destroy -out=tfplan -input=false'
                    }
                }
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        // Wait for user confirmation to apply
                        input(message: 'Proceed with Apply?')
                        sh 'terraform apply -input=false tfplan'
                    } else if (params.ACTION == 'destroy') {
                        // Wait for user confirmation to destroy
                        input(message: 'Proceed with Destroy?')
                        sh 'terraform apply -destroy -input=false tfplan'
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs() // Clean the workspace after the build
        }
        success {
            echo 'Terraform pipeline completed successfully!'
        }
        failure {
            echo 'Terraform pipeline failed.'
        }
    }
}
