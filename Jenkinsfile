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
                    nexusUrl: '192.168.1.20:8081',
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
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USERNAME')]) {
                    sh "docker login -u $NEXUS_USERNAME -p $NEXUS_PASSWORD 192.168.1.20:8082"
                }
                sh 'docker build -t droplets-web-container .'
                sh 'docker tag droplets-web-container 192.168.1.20:8082/droplets-web-container'
                sh 'docker push 192.168.1.20:8082/droplets-web-container'
            }
        }
    }
    post {
        always {
            emailext body: 'A Test EMail', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: 'Test'

        }
    }
}
