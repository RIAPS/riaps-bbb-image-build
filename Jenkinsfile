pipeline {
  agent any
  options {
    buildDiscarder logRotator(daysToKeepStr: '30', numToKeepStr: '10')
  }
  stages {
    stage('build') {
      steps {
        sh 'chmod +x build.sh'
        sh './build.sh'
      }
    }
  }
  post {
    success {
      archiveArtifacts artifacts: '*.img', fingerprint: true
    }
  }
}