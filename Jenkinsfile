pipeline {
  agent any
  options {
    disableConcurrentBuilds()
    timestamps()
  }

  parameters {
    choice(name: 'TARGET_ENV', choices: ['dev','staging','prod'], description: 'Terraform workspace / namespace')
  }

  environment {
    PATH = "/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    TF_DIR = "terraform"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          set -eux
          cd "${TF_DIR}"
          terraform init
        '''
      }
    }

    stage('Terraform Format Check') {
      steps {
        sh '''
          set -eux
          cd "${TF_DIR}"
          terraform fmt -check -recursive
        '''
      }
    }

    stage('Select Workspace') {
      steps {
        sh '''
          set -eux
          cd "${TF_DIR}"
          terraform workspace select "${TARGET_ENV}" || terraform workspace new "${TARGET_ENV}"
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh '''
          set -eux
          cd "${TF_DIR}"
          terraform validate
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -eux
          mkdir -p artifacts
          cd "${TF_DIR}"

          terraform plan \
            -var-file="env/${TARGET_ENV}.tfvars" \
            -out="tfplan-${TARGET_ENV}"

          terraform show -no-color "tfplan-${TARGET_ENV}" > "../artifacts/tfplan-${TARGET_ENV}.txt"
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
        sh '''
          set -eux
          cd "${TF_DIR}"
          terraform apply -auto-approve "tfplan-${TARGET_ENV}"
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
        archiveArtifacts artifacts: 'infra-outputs*.json,artifacts/tfplan-*.txt', fingerprint: true
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'artifacts/**', allowEmptyArchive: true
    }

    failure {
      sh '''
        set +e
        echo "Terraform pipeline FAILED. Check validation/plan logs and archived artifacts."
      '''
    }

    cleanup {
      sh '''
        set +e
        rm -rf artifacts || true
      '''
    }
  }
}