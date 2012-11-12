# XXX Hacks to work around the fact we don't yet have private DNS working
class network::aws {
    host {
        "repos":
            ensure => present,
            ip => $serverip;
        "puppet":
            ensure => present,
            ip => $serverip;
        # Bug 810948, can be removed once all slaves get the hosts removed
        ["hg.mozilla.org", "ntp.build.mozilla.org"]:
            ensure => absent;
    }
}
