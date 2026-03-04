pipeline {
  agent any
  options { disableConcurrentBuilds() }

  parameters {
    choice(name: 'TARGET_ENV', choices: ['dev','staging','prod'], description: 'Terraform workspace / namespace')
  }

  environment {
    PATH = "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  }

  stages {
    stage('Terraform Init') {
      steps {
        sh '''
          set -eux
          cd terraform
          terraform init
        '''
      }
    }

    stage('Select Workspace') {
      steps {
        sh '''
          set -eux
          cd terraform
          terraform workspace select "${TARGET_ENV}" || terraform workspace new "${TARGET_ENV}"
        '''
      }
    }

    stage('Plan') {
      steps {
        sh '''
          set -eux
          cd terraform
          terraform plan -var-file="env/${TARGET_ENV}.tfvars"
        '''
      }
    }

    stage('Apply') {
      steps {
        sh '''
          set -eux
          cd terraform
          terraform apply -auto-approve -var-file="env/${TARGET_ENV}.tfvars"
        '''
      }
    }

    stage('Export Outputs') {
      steps {
        sh '''
          set -eux
          chmod +x ./scripts/write-outputs-json.sh
          ./scripts/write-outputs-json.sh "${TARGET_ENV}"
        '''
        archiveArtifacts artifacts: 'infra-outputs.json', fingerprint: true
      }
    }
  }
}