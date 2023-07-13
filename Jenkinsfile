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
        scannerServer = 'sonar_server'
        dockerImage = 'docker-private/droplets_ci:latest'
        gitRepo = 'https://github.com/Filip3Kx/droplets-ci'
        gitBranch = 'master'
        scannerHome = tool 'sonar4.8'
        fossaApiKey = 'e5c6d376d251417922f5af4a93fd85ee'
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
    }
}