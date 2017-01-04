
node {
  dir('util') {
    git 'git@github.com:ipcrm/pfparser.git'
  }

  dir('ipcrm-ntp') {
    git 'git@github.com:ipcrm/ipcrm-ntp.git'

    stage 'Lint and unit tests'
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

    stage 'Beaker Acceptance Test'
    withCredentials([string(credentialsId: 'eae88076-b8d1-410b-9f46-11d7335b7a50', variable: 'OS_AUTH_URL'), string(credentialsId: '1f009c91-c47e-40d0-b9e0-26f28f5d2a3f', variable: 'OS_KEYNAME'), string(credentialsId: 'ce33a944-dce9-4ec6-92fc-63c21a41fc4f', variable: 'OS_NETWORK'), string(credentialsId: '124b241c-a24e-4d12-a23b-105ac88956e3', variable: 'OS_PASSWORD'), string(credentialsId: '555307f6-051a-4de2-9077-43e280b79117', variable: 'OS_TENANT_NAME'), string(credentialsId: '39ee7e34-8ef1-47b3-b955-41969256ee13', variable: 'OS_USERNAME')]) {
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


    stage 'Set Build Data'
    tag = sh(returnStdout: true, script: "git describe --exact-match --tags HEAD 2>/dev/null || git rev-parse HEAD")
  }

  dir('control-repo') {
    git url: 'git@github.com:ipcrm/demo_control.git', branch: 'production'
    stage 'Update Control Repo'
    env.TAG=tag
    withEnv(['PATH=/usr/local/bin:$PATH']) {
      ansiColor('xterm') {
        sh '''
        source ~/.bash_profile
        rbenv global 2.3.1
        eval "$(rbenv init -)"
        ruby ../util/pfparser.rb -f Puppetfile -m 'ntp' -p ':ref' -d $TAG
        '''
      }
    }

//    stage 'Promote to Prod'
//    puppet.credentials 'pe-access-token'
//    puppet.codeDeploy 'production'


  }
}
