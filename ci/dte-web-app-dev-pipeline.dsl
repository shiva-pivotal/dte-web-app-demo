pipeline {
    agent any
    stages {
        stage('Unit Test') {
            steps {
                sh '''
                ./gradlew test
               '''
            }
        }
        stage('Build') {
            steps {
                sh '''
                ./gradlew assemble
               '''
            }
        }
        stage('Deploy Dev') {
            environment {
                PCF_CREDS = credentials('pcfpez-student-1-creds')
            }
            steps {
                sh 'pwd'
                sh 'ls'
                sh 'ls build/libs'
                sh 'cf login --skip-ssl-validation -a https://api.run.haas-81.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o student-1 -s student-1'
                sh 'cf push -f ci/manifest-dev.yml'
            }
        }
        stage('Smoke Test') {
            steps {
                sh '''
                   sh ci/smoke-test.sh
                '''
            }
        }
    }
    post {
        always {
          step([$class: 'ClaimPublisher'])
        }
    }
}
