# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# This class is overridden by the org-specific config symlinked from manifests/config.pp

class config::base {
    # the name of the puppetagain organization (e.g., 'qa' or 'seamonkey')
    $org = undef

    ##
    ## puppet environment
    ##

    # hostname of the puppet server that hosts should connect to first, and the entire list of
    # servers to try if that one fails.  This can either name a single puppetmaster, use a DNS
    # alias ('puppet'), or some complex function to determine the correct puppetmaster.  See
    # manifests/moco-config.pp for an advanced usage.
    $puppet_server = "puppet"
    $puppet_servers = [$puppet_server]

    # The repository and branch that puppetmasters should follow to get the latest
    # manifests
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet"
    $puppet_again_branch = "production"

    # The fqdn of the "distinguished" puppetmaster.  This master serves as the
    # hub in the hub-and-spoke architecture for synchronizing masters and also
    # handles a number of single-host crontasks.  Its failure will not stop
    # puppet jobs from being correctly processed by other masters, but will
    # temporarily halt synchronizations.  There is no default - set this to the
    # hostname of your master.
    $distinguished_puppetmaster = ''

    # If set, these are the external syncs that puppet should perform.  See
    # https://wiki.mozilla.org/index.php?title=ReleaseEngineering/PuppetAgain/Extsync
    $puppetmaster_extsyncs = {}

    # A list of fqdns for puppetmasters that should serve a public mirror of
    # the non-private parts of the puppetagain data.
    $puppetmaster_public_mirror_hosts = []

    # The email address to which puppet-related mail should be sent
    $puppet_notif_email = "nobody@mozilla.com"

    # The report types to send.  The default, 'tagmail', sends mail only on failed
    # puppet runs
    $puppet_server_reports = "tagmail"

    # the puppet 'reporturl' configuration parameter
    $puppet_server_reporturl = ""

    # the URL at which puppet facts are sent to Foreman
    $puppet_server_facturl = ""

    # the hostname of a centralized syslog server puppetmasters should forward to
    $puppetmaster_syslog_server = ""

    ##
    ## packages and data
    ##

    # similar to puppet server, but used to find data (package repos, binary blobs, etc.)
    $data_server = "repos"
    $data_servers = [$data_server]

    # The hostname of the server on which the Apt repositories are located.
    # Apt does not support client configuration of multiple mirrors, so if the
    # org only has one puppet server, it is safe to point this variable to that
    # server (the default).  Otherwise, to get resiliency to a master failing,
    # point this to a hostname with an A record for each puppet master.  Apt
    # will use the multiple A records as a list of mirror hosts for the
    # repository.
    $apt_repo_server = $data_server

    # the arguments to and source URL for the upstream mirror from which to rsync data.
    # To point to Mozilla's repositories, use
    #   $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    # and to exclude e.g., the Ubuntu repositories (which are large!),
    #   $puppetmaster_upstream_rsync_args = '--exclude=repos/apt'
    $puppetmaster_upstream_rsync_args = ''
    $puppetmaster_upstream_rsync_source = ''

    ##
    ## basic host configuration
    ##

    # NTP server to use for time sync
    $ntp_server = "pool.ntp.org"

    # The host through which to relay mail; this goes to postfix's relayhost
    # parameter, so put [..] around it to avoid doing an MX lookup
    $relayhost = undef

    # Whether puppet should manage /etc/sysconfig/network-scripts/ifcfg-eth0,
    # forcing use of DHCP.  Set this to false to set up static IPs on each host
    # by hand.
    $manage_ifcfg = true

    # Configuration for VMware tools.  This gives the version number and hash
    # of the tarball that will be installed.  Note that you must supply the
    # tarball for this in the 'repos/private/vmware' data directory - see
    # https://github.com/craigwatson/puppet-vmwar
    $vmwaretools_md5 = ""
    $vmwaretools_version = ""

    # a comma-separated list of hosts which can connect to the NRPE daemon
    $nrpe_allowed_hosts = '127.0.0.1'

    # a hash of collectd write modules and there configurations.
    # If undef, module is disabled
    $collectd_write = undef

    # Those are the host and port of the HTTP/HTTPS/FTP proxy through which all
    # outgoing access will be routed. If the URL is not set, no proxy is used.
    # The exceptions are a list of hostnames or .-prefixed hostname suffixes
    # which will not be routed through the proxy.
    $web_proxy_host = ''
    $web_proxy_port = ''
    $web_proxy_exceptions = ['localhost', '127.0.0.1', 'localaddress', '.localdomain.com']

    # Physical location of the node, for organizations that need to distinguish
    # between them.
    $node_location = 'unknown'

    # a flag the controls which nodes should install and run MIG Agent
    $enable_mig_agent = false

    ##
    ## users
    ##

    # Usernames of users who can login to all servers, but are not admins.
    $users = []

    # Usernames of users who are granted admin rights: local accounts, sudo
    # access, and SSH keys in root's authorized_keys.  These users are
    # automatically considered members of $users.
    $admin_users = []

    # a list of pypi mirrors that should be included in every user's pip.conf.  The
    # default points to Release Engineering's mirror, which is not a complete mirror
    # of pypi
    $user_python_repositories = [ "http://pypi.pub.build.mozilla.org/pub" ]

    ##
    ## application-specific configs
    ##

    # buildslave

    # the username under which all building and testing operations take place
    $builder_username = 'cltbld'
    # true if secret("google_api_key") should be installed at /builds/gapi.key
    $install_google_api_key = false
    # true if ceph access keys should be installed on build slaves
    $install_ceph_cfg = false
    # true if secret("mozilla_api_key") should be installed at /builds/mozilla-api.key
    $install_mozilla_api_key = false

    # signingserver

    # username of the user that perfoms signing operations
    $signer_username = 'cltsign'
    # The list IP ranges (in CIDR notation) allowed to request that an object be signed
    $signing_allowed_ips = []
    # the MAC ID for signing
    $signing_mac_id = ''
    # The list of IPs allowed to generate new signing tokens (buildmasters)
    $signing_new_token_allowed_ips = []
    # The mercurial repository from which to pull the signing tools code
    $signing_tools_repo = 'https://hg.mozilla.org/build/tools'

    # buildmaster

    # email address to which buildbot-related mail should be sent
    $buildbot_mail_to = "nobody@mozilla.com"
    # mercurial repository and branch from which to check out buildbot-configs
    $buildbot_configs_hg_repo = "https://hg.mozilla.org/build/buildbot-configs"
    $buildbot_configs_branch = "production"
    # mercurial repository for tools
    $buildbot_tools_hg_repo = "https://hg.mozilla.org/build/tools"
    # the branch of buildbot-custom to follow
    $buildbotcustom_branch = "production-0.8"
    # URL for masters.json (note the confusion about plurality!), listing all masters
    # used by buildmaster
    $master_json = ""
    # a list of ssh key names that should exist on every buildmaster.  This
    # list contains bare key names (e.g., caminobld_dsa), while the
    # corresponding secrets have a "buildmaster_ssh_key_" prefix, e.g.,
    # buildmaster_ssh_key_caminobld_dsa.
    $buildmaster_ssh_keys = []

    # releaserunner

    # fqdn:port of the buildmaster with which to invoke 'buildbot sendchange'
    $releaserunner_sendchange_master = ""
    # hg host name used in release-runner
    $releaserunner_hg_host = ""
    # ssh username and key to use to make commits to hg
    $releaserunner_hg_username = ""
    $releaserunner_hg_ssh_key = ""
    # email to/from addresses and smtp server to use to send notifications
    $releaserunner_notify_from = ""
    $releaserunner_notify_to = ""
    $releaserunner_smtp_server = ""
    # ssh username and (hand-installed) key to use to login to all buildmasters
    # and perform updates and reconfigs
    $releaserunner_ssh_username = ""
    # URL for masters.json, defaulting to $master_json from above
    $releaserunner_production_masters = $master_json
    # mercurial repository and branch for buildbot-configs
    $releaserunner_buildbot_configs_branch = "production"
    $releaserunner_buildbot_configs = "https://hg.mozilla.org/build/buildbot-configs"
    # mercurial repository and branch for buildbotcustom
    $releaserunner_buildbotcustom_branch = "production-0.8"
    $releaserunner_buildbotcustom = "https://hg.mozilla.org/build/buildbotcustom"
    # mercurial repository and branch for tools
    $releaserunner_tools = "https://hg.mozilla.org/build/tools"
    $releaserunner_tools_branch = "default"
    # root directory for releaserunner; this must be under /builds
    $releaserunner_root = "/builds/releaserunner"

    # selfserve (buildapi agent)

    # fqdn:port of the buildmaster with which to invoke 'buildbot sendchange'
    $selfserve_agent_sendchange_master = ""
    # URL for masters.json, defaulting to $master_json from above
    $selfserve_agent_masters_json = $master_json
    # URL for branches.json
    $selfserve_agent_branches_json = ""
    # API URL for clobberer
    $selfserve_agent_clobberer_url = ""
    # carrot (rabbitmq) credentials
    $selfserve_agent_carrot_hostname = ""
    $selfserve_agent_carrot_vhost = ""
    $selfserve_agent_carrot_userid = ""
    $selfserve_agent_carrot_exchange = ""
    $selfserve_agent_carrot_queue = ""
    # root directory for selfserve; this must be under /builds
    $selfserve_agent_root = "/builds/selfserve-agent"

    # slaveapi

    # url for the slavealloc API (should end in '/api/')
    $slaveapi_slavealloc_url = ""
    # url and username to access the Inventory app (https://github.com/mozilla/inventory)
    $slaveapi_inventory_url = ""
    $slaveapi_inventory_username = ""
    # username, hostname, and API URLs to access Bugzilla
    $slaveapi_default_domain = "build.mozilla.org"
    $slaveapi_bugzilla_username = "slaveapi@mozilla.releng.tld"
    $slaveapi_bugzilla_dev_url = "https://bugzilla-dev.allizom.org/rest/"
    $slaveapi_bugzilla_prod_url = "https://bugzilla.mozilla.org/rest/"
    # username to access IMPI interfaces on suitable hosts
    $slaveapi_ipmi_username = "releng"

    # AWS management

    # the username under which all operations take place
    $buildduty_username = 'buildduty'
    # root directory for aws_manager; this must be under /builds
    $aws_manager_root = "/builds/aws_manager"
    # s3 bucket for s3 aws_manager logs parsing
    $cloudtrail_s3_bucket = ""
    # s3 prefix name for aws_manager log parsing
    $cloudtrail_s3_base_prefix = ""
    # mercurial repository and branch for cloud-tools
    $cloud_tools_hg_repo = "http://hg.mozilla.org/build/cloud-tools"
    $cloud_tools_hg_branch = "default"
    $aws_manager_mail_to = "nobody@mozilla.com"
    # slaverebooter
    $slaverebooter_mail_to = "nobody@mozilla.com"
    $slaverebooter_root = "/builds/slaverebooter"

    # mercurial repo and branch for tools
    $slaverebooter_tools = "https://hg.mozilla.org/build/tools"
    $slaverebooter_tools_branch = "default"

    # slaveapi instance that slaverebooter should talk to.
    $slaverebooter_slaveapi = ""

    # The version of xcode to install with packages::xcode. See that package
    # for the availible options.  If different hosts need different versions,
    # it's fine to use a ternary operator here; see moco-config.pp for an
    # example.
    $xcode_version = undef
}
