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
                PCF_CREDS = credentials('pcf-pws-creds')
            }
            steps {
                sh 'pwd'
                sh 'ls'
                sh 'ls build/libs'
                sh 'cf login -a https://donotuseapi.run.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-dev -s development'
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
