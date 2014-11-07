test_name "Install ACL Module on Master"

step "Install PE"
install_pe

step "Install Git on Master"
git = case master['platform']
      when /debian|ubuntu/ then 'git-core'
      when /el/            then 'git'
      end
install_package master, git

step "Clone Git Repo on Master"
on(master, "git clone https://github.com/puppetlabs/puppetlabs-acl.git /etc/puppetlabs/puppet/modules/acl")

step "Plug-in Sync Each Agent"
with_puppet_running_on master, :main => { :verbose => true, :daemonize => true } do
  on agents, puppet("plugin download --server #{master}")
end
