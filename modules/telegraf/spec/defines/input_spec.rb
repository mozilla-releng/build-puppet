require 'spec_helper'

describe 'telegraf::input' do
  let(:title) { 'my_influxdb' }
  let(:params) {{
    :plugin_type => 'influxdb',
    :options => {
      "urls" => ["http://localhost:8086",],
    },
  }}
  let(:filename) { "/etc/telegraf/telegraf.d/#{title}.conf" }

  describe "configuration file /etc/telegraf/telegraf.d/my_influxdb.conf input" do
    it 'is declared with the correct content' do
      should contain_file(filename).with_content(/\[\[inputs.influxdb\]\]/)
      should contain_file(filename).with_content(/  urls = \["http:\/\/localhost:8086"\]/)
    end

    it 'requires telegraf to be installed' do
      should contain_file(filename).that_requires('Class[telegraf::install]')
    end

    it 'notifies the telegraf daemon' do
      should contain_file(filename).that_notifies("Class[telegraf::service]")
    end
  end
end

describe 'telegraf::input' do
  let(:title) { 'my_snmp' }
  let(:params) {{
    :plugin_type => 'snmp',
    :options => {
      "interval" => "60s",
    },
    :single_section => {
      "snmp.tags" => {
        "environment" => "development",
      },
    },
    :sections => {
      "snmp.host" => {
        "address"   => "snmp_host1:161",
        "community" => "read_only",
        "version"   => 2,
        "get_oids"  => ["1.3.6.1.2.1.1.5",],
      },
    },
  }}
  let(:filename) { "/etc/telegraf/telegraf.d/#{title}.conf" }

  describe 'configuration file /etc/telegraf/telegraf.d/my_snmp.conf input with sections' do
    it 'is declared with the correct content' do
      should contain_file(filename).with_content(/\[\[inputs.snmp\]\]/)
      should contain_file(filename).with_content(/  interval = "60s"/)
      should contain_file(filename).with_content(/\[inputs.snmp.tags\]/)
      should contain_file(filename).with_content(/  environment = "development"/)
      should contain_file(filename).with_content(/\[\[inputs.snmp.host\]\]/)
      should contain_file(filename).with_content(/  address = "snmp_host1:161"/)
      should contain_file(filename).with_content(/  community = "read_only"/)
      should contain_file(filename).with_content(/  get_oids = \["1.3.6.1.2.1.1.5"\]/)
      should contain_file(filename).with_content(/  version = 2/)
    end

    it 'requires telegraf to be installed' do
      should contain_file(filename).that_requires('Class[telegraf::install]')
    end

    it 'notifies the telegraf daemon' do
      should contain_file(filename).that_notifies("Class[telegraf::service]")
    end
  end
end

describe 'telegraf::input' do
  let(:title) { 'my_haproxy' }
  let(:params) {{
    :plugin_type => 'haproxy',
  }}
  let(:filename) { "/etc/telegraf/telegraf.d/#{title}.conf" }

  describe 'configuration file /etc/telegraf/telegraf.d/my_haproxy.conf input with no options or sections' do
    it 'is declared with the correct content' do
      should contain_file(filename).with_content(/\[\[inputs.haproxy\]\]/)
    end

    it 'requires telegraf to be installed' do
      should contain_file(filename).that_requires('Class[telegraf::install]')
    end

    it 'notifies the telegraf daemon' do
      should contain_file(filename).that_notifies("Class[telegraf::service]")
    end
  end
end
