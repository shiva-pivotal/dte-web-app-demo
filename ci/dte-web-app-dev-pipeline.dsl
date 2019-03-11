pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''
                ./gradlew assemble
               '''
            }
        }
        stage('Deploy Dev') {
            environment {
                PCF_CREDS = credentials('pcfpez-dte-dev-creds')
            }
            steps {
                sh 'pwd'
                sh 'ls'
                sh 'ls build/libs'
                sh 'cf login --skip-ssl-validation -a https://api.run.haas-202.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-demo -s dev'
                sh 'cf push -f ci/manifest-dev.yml'
            }
        }
        stage('Run Smoke Tests') {
            parallel {
                stage('Test On Chrome') {
                    steps {
                        sh '''
                            ENV=dev BROWSER=chrome ./gradlew test
                        '''
                    }
                }
                stage('Test On FireFox') {
                    steps {
                        sh '''
                            ENV=dev BROWSER=firefox ./gradlew test
                        '''
                    }
                }
            }
        }

        stage('Archive Artifacts'){
            steps {
                 archiveArtifacts artifacts: 'build/**/*.*', fingerprint: true
            }
        }
    }
    post {
        always {
          step([$class: 'ClaimPublisher'])
        }
    }
}
