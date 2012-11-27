# XXX Hacks to work around the fact we don't yet have private DNS working
class network::aws {
    host {
        "repos":
            ensure => present,
            ip => $serverip;
        "puppet":
            ensure => present,
            ip => $serverip;
    }
}
