
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

  }

  dir('control-repo') {
    git url: 'git@github.com:ipcrm/demo_control.git', branch: 'production'

    stage('Update Control Repo'){
      withEnv(['PATH=/usr/local/bin:$PATH']) {
        ansiColor('xterm') {
          previous_version = sh(returnStdout: true, script: '''
            source ~/.bash_profile
            rbenv global 2.3.1
            eval "$(rbenv init -)"
            ruby ../util/pfparser.rb -r -f Puppetfile -m ntp -p ':ref' -d $BUILD_TAG
          ''')
        }
      }
      withEnv(['PATH=/usr/local/bin:$PATH']) {
        ansiColor('xterm') {
          sh '''
          git add Puppetfile
          git commit -m "${BUILD_TAG}"
          git push origin $BUILD_BRANCH
          '''
        }
      }
    }

    stage('Promote to Prod'){
      puppet.credentials 'pe-access-token'
      puppet.codeDeploy 'production'
    }

    try {
      stage('Prod: Canary Test'){
        puppet.credentials 'pe-access-token'
        puppet.job 'production', query: 'nodes { facts { name = "canary" and value = true }}'
      }
    } catch (error) {

      stage('Revert Control Repo'){
        env.TAG=previous_version
        withEnv(['PATH=/usr/local/bin:$PATH']) {
          ansiColor('xterm') {
            sh '''
              source ~/.bash_profile
              rbenv global 2.3.1
              eval "$(rbenv init -)"
              ruby ../util/pfparser.rb -r -f Puppetfile -m $MODULE -p $PARAM -d $TAG
            '''
          }
        }
        withEnv(['PATH=/usr/local/bin:$PATH']) {
          ansiColor('xterm') {
            sh '''
            git add Puppetfile
            git commit -m "${BUILD_TAG}"
            git push origin $BUILD_BRANCH
            '''
          }
        }
      }

      stage('Downgrade Production'){
        puppet.credentials 'pe-access-token'
        puppet.codeDeploy 'production'
      }

      stage('Prod: Canary Test'){
        puppet.credentials 'pe-access-token'
        puppet.job 'production', query: 'nodes { facts { name = "canary" and value = true }}'
      }

      currentBuild.result = 'FAILURE'
    }

  }

}
