pipeline {
    agent any
    environment {
        PCF_CREDS = credentials('pcfpez-dte-dev-creds')
    }
    stages {
        stage('Copy Archive') {
            steps {
                script {
                    step ([
                        $class: 'CopyArtifact',
                        projectName: 'dte-web-app-demo-dev',
                        fingerprintArtifacts: true,
                        selector: [$class: 'StatusBuildSelector', stable: true, $class: 'TriggeredBuildSelector', fallbackToLastSuccessful: true]
                    ]);
                }
            }
        }
        stage('Deploy Stage Green') {
            steps {
                sh '''

                    cf login --skip-ssl-validation -a https://api.run.haas-202.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-demo -s prod

                    cf rename dte-web-app-demo dte-web-app-demo-previous

                    cf push -f ci/manifest-prod-temp.yml
                '''
            }
        }
        stage('Smoke Test Green') {
            steps {
                sh '''
                    ENV=prod BROWSER=chrome TEMP_ROUTE=temp ./gradlew test
                '''
            }
        }

        stage('Go Blue') {
            steps {
                sh '''
                    cf login --skip-ssl-validation -a https://api.run.haas-202.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-demo -s prod
                    cf map-route dte-web-app-demo cfapps.haas-202.pez.pivotal.io -n dte-web-app-demo-prod
                 '''
                sh '''
                    cf login --skip-ssl-validation -a https://api.run.haas-202.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-demo -s prod

                    cf unmap-route dte-web-app-demo cfapps.haas-202.pez.pivotal.io -n dte-web-app-demo-prod-temp
                    cf unmap-route dte-web-app-demo-previous cfapps.haas-202.pez.pivotal.io -n dte-web-app-demo-prod
                 '''
            }
        }
        stage('Smoke Test Blue') {
            steps {
                sh '''
                    ENV=prod BROWSER=chrome ./gradlew test
                '''
            }
        }
        stage('Cleanup Previous') {
            steps {
                sh '''
                    cf login --skip-ssl-validation -a https://api.run.haas-202.pez.pivotal.io -u ${PCF_CREDS_USR} -p ${PCF_CREDS_PSW} -o dte-demo -s prod
                    cf delete dte-web-app-demo-previous -f
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
