require 'spec_helper'

describe 'ntp' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "ntp class without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ntp') }
          it { is_expected.to contain_class('ntp::params') }
          it { is_expected.to contain_class('ntp::install').that_comes_before('ntp::config') }
          it { is_expected.to contain_class('ntp::config') }
          it { is_expected.to contain_class('ntp::service').that_subscribes_to('ntp::config') }
          it { is_expected.to contain_package('ntp').with_ensure('present') }

          case facts[:osfamily]
					when 'Debian'
            it { is_expected.to contain_service('ntp') }
          when 'RedHat'
            it { is_expected.to contain_service('ntpd') }
          end

          it { is_expected.to contain_file('/etc/ntp.conf').with({
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644'
          })
          }

          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/0.us.pool.ntp.org/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/1.us.pool.ntp.org/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/2.us.pool.ntp.org/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/3.us.pool.ntp.org/) }


        end

        context "ntp class with overriden server parameter" do
          let(:params) { {:servers => ['time1.example.com','time2.example.com']} }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ntp') }
          it { is_expected.to contain_class('ntp::params') }
          it { is_expected.to contain_class('ntp::install').that_comes_before('ntp::config') }
          it { is_expected.to contain_class('ntp::config') }
          it { is_expected.to contain_class('ntp::service').that_subscribes_to('ntp::config') }
          it { is_expected.to contain_package('ntp').with_ensure('present') }

          case facts[:osfamily]
					when 'Debian'
            it { is_expected.to contain_service('ntp') }
          when 'RedHat'
            it { is_expected.to contain_service('ntpd') }
          end

          it { is_expected.to contain_file('/etc/ntp.conf').with({
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644'
          })
          }

          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/time1.example.com/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .with_content(/time2.example.com/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .without_content(/0.us.pool.ntp.org/) }
          it { is_expected.to contain_file('/etc/ntp.conf')\
               .without_content(/1.us.pool.ntp.org/) }
        end


      end
    end
  end

  context 'unsupported operating system' do
    describe 'ntp class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('ntp') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
