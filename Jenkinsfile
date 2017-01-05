
node {
  dir('util') {
    git 'git@github.com:ipcrm/pfparser.git'
  }

  dir('ipcrm-ntp') {
    git 'git@github.com:ipcrm/ipcrm-ntp.git'

    stage('Lint and unit tests') {
      withEnv(['PATH=/usr/local/bin:$PATH']) {
        ansiColor('xterm') {
          sh '''
          source ~/.bash_profile
          rbenv global 2.3.1
          eval "$(rbenv init -)"
          bundle install
          bundle exec rake lint
          bundle exec rake spec
          '''
        }
      }
    }

    stage('Beaker Acceptance Test') {
      withCredentials([
        string(credentialsId: 'OS_AUTH_URL', variable: 'OS_AUTH_URL'),
        string(credentialsId: 'OS_KEYNAME', variable: 'OS_KEYNAME'),
        string(credentialsId: 'OS_NETWORK', variable: 'OS_NETWORK'),
        string(credentialsId: 'OS_PASSWORD', variable: 'OS_PASSWORD'),
        string(credentialsId: 'OS_TENANT_NAME', variable: 'OS_TENANT_NAME'),
        string(credentialsId: 'OS_USERNAME', variable: 'OS_USERNAME')
      ]) {
          withEnv(['PATH=/usr/local/bin:$PATH']) {
            ansiColor('xterm') {
              sh '''
                source ~/.bash_profile
                rbenv global 2.3.1
                eval "$(rbenv init -)"
                bundle install
                export OS_VOL_SUPPORT=false
                bundle exec rake beaker:centos7-openstack
              '''
            }
          }
      }
    }

    stage('Set Tag Data'){
      sh '''
        git tag $BUILD_TAG
        git push --tags
      '''
    }

    stage('Deploy Latest Version'){
      build job: 'pipeline-demo_control', parameters: [
        [$class: 'StringParameterValue',name: 'TAG',value: env.BUILD_TAG],
        [$class: 'StringParameterValue',name: 'MODULE',value: 'ntp'],
        [$class: 'StringParameterValue',name: 'PARAM', value: ':ref']
      ]
    }

  }
}
