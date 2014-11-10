test_name "Install Foss"

version = ENV['PUPPET_VERSION'] || '3.6.2-1066-g5010aba-x64'
download_url = ENV['WIN_DOWNLOAD_URL'] || 'http://builds.puppetlabs.lan/puppet/5010aba1b89f04788736dd49227c46617516bb92/artifacts/windows/'
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
hosts.each do |host|
  if host['platform'] =~ /windows/
    step "Install foss from MSI"
    install_puppet_from_msi(host,
                            {
                                :win_download_url => download_url,
                                :version => version
                            })

    on host, "mkdir -p #{host['distmoduledir']}/acl"
    result = on host, "echo #{host['distmoduledir']}/acl"
    target = result.raw_output.chomp
    step "Install ACL to host"
    %w(lib manifests metadata.json).each do |file|
      scp_to host, "#{proj_root}/#{file}", "#{target}"
    end
  end
end
