
node {
  dir('util') {
    git 'git@github.com:ipcrm/pfparser.git'
  }


  dir('ipcrm-ntp') {
    git 'git@github.com:ipcrm/ipcrm-ntp.git'

    stage 'Lint and unit tests'
    withEnv(['PATH=/usr/local/bin:$PATH']) {
      ansiColor('xterm') {
        sh """
          source ~/.bash_profile
          rbenv global 2.3.1
          eval "$(rbenv init -)"
          bundle install
          bundle exec rake lint
          bundle exec rake spec
        """
      }
    }

#    stage 'Beaker Acceptance Test'
#    withEnv(['PATH=/usr/local/bin:$PATH']) {
#      ansiColor('xterm') {
#        sh """
#          source ~/.bash_profile
#          rbenv global 2.3.1
#          eval "$(rbenv init -)"
#          bundle install
#          export OS_VOL_SUPPORT=false
#          bundle exec rake beaker:centos7-openstack
#        """
#      }
#    }
#
    stage 'Set Build Data'
    def tag = sh(returnStdout: true, script: "git tag --sort version:refname | tail -1").trim()
    if tag == null {
      def tag = sh(returnStdout: true, script: "git rev-parse --short HEAD")
    }
  }

  dir('control-repo') {
    git 'git@github.com:ipcrm/demo_control.git'
    stage 'Update Control Repo'
    withEnv(['PATH=/usr/local/bin:$PATH']) {
      ansiColor('xterm') {
        sh """
          ruby ../util/pfparser/pfparser.rb -f Puppetfile -m 'ntp' -p 'ref' -d tag
        """
      }
    }

#    stage 'Promote to Prod'
#    puppet.credentials 'pe-access-token'
#    puppet.codeDeploy 'production'


  }
}
