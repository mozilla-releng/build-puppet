require 'spec_helper_acceptance'

describe 'telegraf' do
  context 'default server' do
      it 'should work with no errors' do

        pp = <<-EOS
            Exec {
              path => '/bin:/usr/bin:/sbin:/usr/sbin',
            }

            class { '::telegraf':
              hostname  => 'test.vagrant.dev',
              outputs   => {
                  'influxdb' => {
                    'urls'     => [ 'http://localhost:8086' ],
                    'database' => 'telegraf',
                    'username' => 'telegraf',
                    'password' => 'metricsmetricsmetrics',
                  }
              },
              inputs    => {
                  'cpu' => {
                    'percpu'   => true,
                    'totalcpu' => true,
                  },
              }
            }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

      end

      describe package('telegraf') do
        it { should be_installed }
      end

      describe service('telegraf') do
        it { should be_running }
      end

      describe file ('/etc/telegraf/telegraf.conf') do
          it { should be_file }
          it { should contain '[agent]' }
          it { should contain '  hostname = "test.vagrant.dev"' }
          it { should contain '[[outputs.influxdb]]' }
          it { should contain '  urls = ["http://localhost:8086"]' }
          it { should contain '  database = "telegraf"' }
          it { should contain '  username = "telegraf"' }
          it { should contain '  password = "metricsmetricsmetrics"' }
          it { should contain '[[inputs.cpu]]' }
          it { should contain '  percpu = true' }
          it { should contain '  totalcpu = true' }
      end

  end
end
