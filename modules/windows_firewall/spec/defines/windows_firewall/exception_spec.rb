require 'spec_helper'

describe 'windows_firewall::exception', :type => :define do

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "port rule with OS: #{os}, ensure: present" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
         :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe firewall add portopening name="Windows Remote Management" mode=ENABLE protocol=TCP port=5985',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "port rule with OS: #{os}, ensure: present" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
         :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Windows Remote Management" description="Inbound rule for WinRM" dir=in action=allow enable=yes protocol=TCP localport=5985',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "program rule with OS: #{os}, ensure: present" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'present', :direction => 'in', :action => 'allow',
         :enabled => 'yes', :program => 'C:\\foo.exe', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe firewall add allowedprogram name="Windows Remote Management" mode=ENABLE program="C:\\foo.exe"',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "program rule with OS: #{os}, ensure: present" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'present', :direction => 'in', :action => 'allow',
         :enabled => 'yes', :program => 'C:\\foo.exe', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Windows Remote Management" description="Inbound rule for WinRM" dir=in action=allow enable=yes program="C:\\foo.exe"',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "port rule with OS: #{os}, ensure: absent" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'absent', :direction => 'in', :action => 'allow', :enabled => 'yes',
         :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe firewall delete portopening name="Windows Remote Management" mode=ENABLE protocol=TCP port=5985',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "port rule with OS: #{os}, ensure: absent" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'absent', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it { should contain_exec('set rule Windows Remote Management').with(
        'command' => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall delete rule name="Windows Remote Management" description="Inbound rule for WinRM" dir=in action=allow enable=yes protocol=TCP localport=5985',
        'provider' => 'windows'
      ) }
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "program rule with OS: #{os}, ensure: absent" do
     let :facts do
       { :operatingsystemversion => os }
     end
     let :title do 'Windows Remote Management' end
     let :params do
       { :ensure => 'absent', :direction => 'in', :action => 'allow',
         :enabled => 'yes', :program => 'C:\\foo.exe', :key_name => 'WINRM-HTTP-In-TCP',
         :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
       }
     end

     it { should contain_exec('set rule Windows Remote Management').with(
       'command' => 'C:\\Windows\\System32\\netsh.exe firewall delete allowedprogram name="Windows Remote Management" mode=ENABLE program="C:\\foo.exe"',
       'provider' => 'windows'
     ) }
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "program rule with OS: #{os}, ensure: absent" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'absent', :direction => 'in', :action => 'allow',
          :enabled => 'yes', :program => 'C:\\foo.exe', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it { should contain_exec('set rule Windows Remote Management').with(
        'command' => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall delete rule name="Windows Remote Management" description="Inbound rule for WinRM" dir=in action=allow enable=yes program="C:\\foo.exe"',
        'provider' => 'windows'
      ) }
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, ensure => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'fubar', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, display_name => >255" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end

      $long_display_name = <<-long
        kbqsCQPnQKYPOWEUItAj72ldtdGqBBK1etCZycAVsuNNY8fNCF4av4yaDppQ1upex5moV5RHd88rHdG5DegNEYR2b7DI3thTewgP
        1RTgW7xawfeDOZOZh2CbmV7zPOqbF8rXxFwxtugUBIpxmpQ8TCk93wF04RicJidwhhiKQz5YXwTbMbREXtQz25mhkPxOI6cyA9QJ
        kQmssLmRxKxxtQ1YKithCfinHOQeDpDXxAtcRsHyKCjjDTt8bZREKexMxx2t
      long

      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => $long_display_name, :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, enabled => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'fubar',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, protocol => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'fubar', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, local_port => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => 'fubar', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows Server 2003 R2', 'Windows Server 2003', 'Windows 8','Windows 7','Windows Vista', 'Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, key_name => >255" do
      let :facts do
        { :operatingsystemversion => 'Windows Server 2008 R2' }
      end
      let :title do 'Windows Remote Management' end

      $long_key_name = <<-long
        kbqsCQPnQKYPOWEUItAj72ldtdGqBBK1etCZycAVsuNNY8fNCF4av4yaDppQ1upex5moV5RHd88rHdG5DegNEYR2b7DI3thTewgP
        1RTgW7xawfeDOZOZh2CbmV7zPOqbF8rXxFwxtugUBIpxmpQ8TCk93wF04RicJidwhhiKQz5YXwTbMbREXtQz25mhkPxOI6cyA9QJ
        kQmssLmRxKxxtQ1YKithCfinHOQeDpDXxAtcRsHyKCjjDTt8bZREKexMxx2t
      long

      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => $long_key_name,
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "with invalid custom param: os => #{os}, description => >255" do
      let :facts do
        { :operatingsystemversion => 'Windows Server 2008 R2' }
      end
      let :title do 'Windows Remote Management' end

      $long_description = <<-long
        kbqsCQPnQKYPOWEUItAj72ldtdGqBBK1etCZycAVsuNNY8fNCF4av4yaDppQ1upex5moV5RHd88rHdG5DegNEYR2b7DI3thTewgP
        1RTgW7xawfeDOZOZh2CbmV7zPOqbF8rXxFwxtugUBIpxmpQ8TCk93wF04RicJidwhhiKQz5YXwTbMbREXtQz25mhkPxOI6cyA9QJ
        kQmssLmRxKxxtQ1YKithCfinHOQeDpDXxAtcRsHyKCjjDTt8bZREKexMxx2t
      long

      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => $long_description }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, description => >255" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end

      $long_description = <<-long
        kbqsCQPnQKYPOWEUItAj72ldtdGqBBK1etCZycAVsuNNY8fNCF4av4yaDppQ1upex5moV5RHd88rHdG5DegNEYR2b7DI3thTewgP
        1RTgW7xawfeDOZOZh2CbmV7zPOqbF8rXxFwxtugUBIpxmpQ8TCk93wF04RicJidwhhiKQz5YXwTbMbREXtQz25mhkPxOI6cyA9QJ
        kQmssLmRxKxxtQ1YKithCfinHOQeDpDXxAtcRsHyKCjjDTt8bZREKexMxx2t
      long

      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => $long_description }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.not_to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "with invalid custom param: os => #{os}, direction => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'fubar', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, direction => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'fubar', :action => 'allow', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.not_to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2012', 'Windows Server 2008','Windows Server 2008 R2','Windows 8','Windows 7','Windows Vista'].each do |os|
    context "with invalid custom param: os => #{os}, action => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'fubar', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  ['Windows Server 2003','Windows Server 2003 R2','Windows XP'].each do |os|
    context "with invalid custom param: os => #{os}, action => fubar" do
      let :facts do
        { :operatingsystemversion => os }
      end
      let :title do 'Windows Remote Management' end
      let :params do
        { :ensure => 'present', :direction => 'in', :action => 'fubar', :enabled => 'yes',
          :protocol => 'TCP', :local_port => '5985', :key_name => 'WINRM-HTTP-In-TCP',
          :display_name => 'Windows Remote Management', :description => 'Inbound rule for WinRM'
        }
      end

      it do
        expect {
          should contain_exec('set rule Windows Remote Management')
        }.not_to raise_error(Puppet::Error)
      end
    end
  end
end
