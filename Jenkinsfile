// CI Pipeline for droplets project
// The stack consists of:
// - Jenkins server with docker
// - Nexus as a private repo
// - SonarQube
// - Fossa API
// BEFORE RUNNING THE PIPELINE:
// - set up credentials for sonar and nexus
// - configure sonar tool
// - configure docker cloud
pipeline {
    environment {
        scannerServer = '<>'
        gitRepo = 'https://github.com/Filip3Kx/droplets-ci'
        gitBranch = 'master'
        scannerHome = tool '<>'
        fossaApiKey = '<>'
    }
    agent any
    stages {
        stage("Git Checkout") {
            steps {
                git branch: "${gitBranch}", url: "${gitRepo}"
            }
        }
        stage("Build") {
            steps {
                sh 'export GOCACHE=~/'
                sh 'export GOPATH=~/'
                sh 'make all'
            }
        }
        stage("Fossa analysis") {
            steps {
                sh 'curl -H \'Cache-Control: no-cache\' https://raw.githubusercontent.com/fossas/fossa-cli/master/install-latest.sh | bash'
                sh "FOSSA_API_KEY=${fossaApiKey} fossa analyze"
            }
        }
        stage("SonarQube analysis") {
            steps {
                withSonarQubeEnv('sonar_server') {
                    sh """${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=droplets \
                    -Dsonar.projectName=droplets \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=. \
                    """
                }
            }
        }
        stage('FOSSA Quality Gate') {
            steps {
                sh "FOSSA_API_KEY=${fossaApiKey} fossa test"
            }
        }
        stage('SonarQube Quality Gate') {
            steps{
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage("Archive artifacts"){
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '<nexus url>',
                    groupId: 'Prod',
                    version: "${env.BUILD_ID}_${env.BUILD_TIMESTAMP}",
                    repository: 'droplets-repo',
                    credentialsId: 'nexus',
                    artifacts: [
                        [artifactId: 'droplets-pipeline',
                        classifier: '',
                        file: 'bin/droplets',
                        type: 'bin']
                    ]
                )
            }
        }
        stage("Build & Push Docker image to nexus") {
            steps{
                withCredentials([usernamePassword(credentialsId: 'nexus', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                    sh "docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWORD <nexus url>"
                }
                sh 'docker build -t droplets-web-container .'
                sh 'docker tag droplets-web-container <nexus url>/droplets-web-container'
                sh 'docker push <nexus url>/droplets-web-container'
            }
        }
    }
    post {
        always {
            mail bcc: '', body: "Build ${env.BUILD_ID} has ended with a ${currentBuild.currentResult} \\n More info at ${env.BUILD_URL}", cc: '', from: '', replyTo: '', subject: "Jenkins job | ${env.BUILD_ID}", to: '<recipients>'
        }
    }
}
