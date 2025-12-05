pipeline {
  agent {
    // LOCAVORA_TODO buildah agent also defined in other Jenkinsfile
    // NOTE demande de 4Gi d'espace éphémère car buildah a besoin de beaucoup d'espace pour construire cette image
    kubernetes {
      label 'jenkins-agent-buildah-remote-harbor'
      idleMinutes 60 // Keep the Pod alive for 60 minutes after the build
      yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: buildah
spec:
  containers:
  - name: buildah
    image: quay.io/buildah/stable:v1.23.1
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
      - name: varlibcontainers
        mountPath: /var/lib/containers
    resources:
      requests:
        memory: "1Gi"
        ephemeral-storage: "4Gi"
  volumes:
  - name: varlibcontainers
  restartPolicy: Never
'''   
    }
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    durabilityHint('PERFORMANCE_OPTIMIZED')
    disableConcurrentBuilds()
  }
  environment {
    // Jenkins UI -> Manage Jenkins -> Credentials
    IMAGE_REGISTRY_CREDS=credentials('harbor-locavora-readwrite')
  }
  stages {
    stage('Build with Buildah using DockerfileWithoutSSL in provided repo') {
      steps {
        container('buildah') {
          // LOCAVORA - STORAGE_DRIVER=vfs needed if fuse not supported in kernel (lsmod | grep fuse)
          // LOCAVORA TEMP - checking if STORAGE_DRIVER=vfs means less I/O usage on Jenkins agent
          sh 'STORAGE_DRIVER=vfs buildah build -f DockerfileWithoutSSL -t harbor.beckn.locavora.org/locavora/ondc-buyer-app-frontend:0.1 .'
        }
      }
    }
    stage('Login to Harbor registry') {
      steps {
        container('buildah') {
          sh 'echo $IMAGE_REGISTRY_CREDS_PSW | buildah login -u $IMAGE_REGISTRY_CREDS_USR --password-stdin harbor.beckn.locavora.org'
        }
      }
    }
    stage('tag image') {
      steps {
        container('buildah') {
          sh 'buildah tag harbor.beckn.locavora.org/locavora/ondc-buyer-app-frontend:0.1 harbor.beckn.locavora.org/locavora/ondc-buyer-app-frontend:latest'
        }
      }
    }
    stage('push image') {
      steps {
        container('buildah') {
          sh 'buildah push harbor.beckn.locavora.org/locavora/ondc-buyer-app-frontend:0.1'
          sh 'buildah push harbor.beckn.locavora.org/locavora/ondc-buyer-app-frontend:latest'
        }
      }
    }
  }
  post {
    always {
      container('buildah') {
        sh 'buildah logout harbor.beckn.locavora.org'
      }
    }
  }
}