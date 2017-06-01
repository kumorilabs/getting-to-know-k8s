#!groovy​
podTemplate(label: 'pod-hugo-app', containers: [
    containerTemplate(name: 'hugo', image: 'smesch/hugo', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'html-proofer', image: 'smesch/html-proofer', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'kubectl', image: 'smesch/kubectl', ttyEnabled: true, command: 'cat',
        volumes: [secretVolume(secretName: 'kube-config', mountPath: '/root/.kube')]),
    containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat',
        envVars: [containerEnvVar(key: 'DOCKER_CONFIG', value: '/tmp/'),])],
        volumes: [secretVolume(secretName: 'docker-config', mountPath: '/tmp'),
                  hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
  ]) {

    node('pod-hugo-app') {

        def DOCKER_HUB_ACCOUNT = 'smesch'
        def DOCKER_IMAGE_NAME = 'hugo-app-jenkins'
        def K8S_DEPLOYMENT_NAME = 'hugo-app'

        stage('Clone Hugo App Repository') {
            checkout scm
 
            container('hugo') {
                stage('Build Hugo Site') {
                    sh ("hugo --uglyURLs")
                }
            }
    
            container('html-proofer') {
                stage('Validate HTML') {
                    sh ("htmlproofer public --internal-domains ${env.JOB_NAME} --external_only --only-4xx")
                }
            }

            container('docker') {
                stage('Docker Build & Push Current & Latest Versions') {
                    sh ("docker build -t ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} .")
                    sh ("docker push ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                    sh ("docker tag ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:latest")
                    sh ("docker push ${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:latest")
                }
            }

            container('kubectl') {
                stage('Deploy New Build To Kubernetes') {
                    sh ("kubectl set image deployment/${K8S_DEPLOYMENT_NAME} ${K8S_DEPLOYMENT_NAME}=${DOCKER_HUB_ACCOUNT}/${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }

        }        
    }
}