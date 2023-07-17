# droplets-ci

Looked for a repository to practice CI/CD on. 

Here is a pipeline using
- Jenkins to run jobs (port 8080 web app, port 8081 jenkins service)
- Fossa and SonarQube for analysis (port 80)
- Nexus for storing artifacts and docker images for deployment (port 8081, private docker registry 8082)

## CI/CD Pipeline
- After a change in the code is picked up by jenkins it runs the pipeline form [Jenkinsfile](https://github.com/Filip3Kx/droplets-ci/blob/master/Jenkinsfile)
- Git checkout
- Build the app
- Analyze the code with SonarQube
- Use Fossa API for dependencies scan
- Archive in Nexus both the .bin artifact and the docker image created from [Dockerfile](https://github.com/Filip3Kx/droplets-ci/blob/master/Dockerfile)
- Notify whether the build was succesful or not via mail

![image](https://github.com/Filip3Kx/droplets-ci/assets/114138650/bb2a8d5e-1850-4dd4-b52e-f66d684172b0)

I don't want the deployment to be fully automatic for some QA work to be done after the artifact and the docker image is deployed to the Nexus repository. The deployment itself is going to be done from an Ansible playbook that could also be made into a Jenkins project. The process is done in [deployment.sh](https://github.com/Filip3Kx/droplets-ci/blob/master/deployment%2Csh) script

## Configuration
Configure the 3 servers mentioned above. Except for Fossa which is going to be accessed from an API. There are some scripts to help you with physical setup in [srv_setup](https://github.com/Filip3Kx/droplets-ci/tree/master/srv_setup) directory.

With AWS setup is the same except for allowing specified security groups to connect on some ports.
