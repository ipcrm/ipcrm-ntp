require 'spec_helper_acceptance'

describe 'ntp class' do
  context 'default parameters' do
    case fact('osfamily')
    when 'RedHat', 'CentOS'
      servicename = 'ntpd'
    when 'Ubuntu', 'Debian'
      servicename = 'ntp'
    end

    # Using puppet_apply as a helper
    it 'work idempotently with no errors' do
      pp = <<-EOS
      class { 'ntp': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('ntp') do
      it { is_expected.to be_installed }
    end

    describe service(servicename) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
