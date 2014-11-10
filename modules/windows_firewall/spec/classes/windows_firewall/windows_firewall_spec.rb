require 'spec_helper'

describe 'windows_firewall', :type => :class do
  
  
  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "with OS: #{os}, ensure: running" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :params do
       { :ensure => 'running' }
     end
     
     it { should contain_service('windows_firewall').with(
       'name'   => 'SharedAccess',
       'ensure' => 'running',
       'enable' => 'true' 
     )}
     
     it { should contain_registry_value('EnableFirewall').with(
       'ensure' => 'present',
       'path'   => 'HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
       'data'   => '1'  
     ) } 
    end
  end
  
  ['Windows 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "with OS: #{os}, ensure: running" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :params do
       { :ensure => 'running' }
     end     
     it { should contain_service('windows_firewall').with(
       'name'   => 'MpsSvc',
       'ensure' => 'running',
       'enable' => 'true' 
     )}
     
     it { should contain_registry_value('EnableFirewall').with(
       'ensure' => 'present',
       'path'   => 'HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
       'data'   => '1'  
     ) }  
    end
  end
  
  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "with OS: #{os}, ensure: stopped" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :params do
       { :ensure => 'stopped' }
     end 
          
     it { should contain_service('windows_firewall').with(
       'name'   => 'SharedAccess',
       'ensure' => 'stopped',
       'enable' => 'false' 
     )} 
     
     it { should contain_registry_value('EnableFirewall').with(
       'ensure' => 'present',
       'path'   => 'HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
       'data'   => '0'  
     ) } 
    end
  end
  
  ['Windows 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "with OS: #{os}, ensure: stopped" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :params do
       { :ensure => 'stopped' }
     end     
     it { should contain_service('windows_firewall').with(
       'name'   => 'MpsSvc',
       'ensure' => 'stopped',
       'enable' => 'false' 
     )}
     
     it { should contain_registry_value('EnableFirewall').with(
       'ensure' => 'present',
       'path'   => 'HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
       'data'   => '0'  
     ) }  
    end
  end
  
  context "passing invalid param ensure: fubar" do
    let :params do
      { :ensure => 'fubar' }
    end
    it do
      expect {
       should contain_registry_value('EnableFirewall')
      }.to raise_error(Puppet::Error)
    end
  end
  
end