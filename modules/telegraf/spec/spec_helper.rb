require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end

  c.default_facts = {
    :osfamily                  => 'RedHat',
    :architecture              => 'x86_64',
    :kernel                    => 'Linux',
    :operatingsystem           => 'RedHat',
    :operatingsystemrelease    => 7,
    :operatingsystemmajrelease => 7,
    :role                      => 'telegraf'
  }

  c.hiera_config = 'spec/hiera.yaml'

end
