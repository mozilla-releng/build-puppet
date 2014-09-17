class aws::instance_storage {
    case $::operatingsystem {
        # On Linux systems, manage instance storage
        CentOS: {
            include packages::mozilla::py27_mercurial
            $python = $::packages::mozilla::python27::python

            file {
                "/etc/init.d/instance_storage":
                    require => File["/usr/local/bin/manage_instance_storage.py"],
                    content => template("aws/instance_storage.initd.erb"),
                    mode    => 0755,
                    owner   => "root",
                    notify  => Service["instance_storage"];
                "/usr/local/bin/manage_instance_storage.py":
                    owner  => "root",
                    mode   => 0755,
                    source => "puppet:///modules/aws/manage_instance_storage.py";
            }
            service {
                "instance_storage":
                    require => [
                        File["/etc/init.d/instance_storage"],
                        File["/usr/local/bin/manage_instance_storage.py"],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
    }
}
