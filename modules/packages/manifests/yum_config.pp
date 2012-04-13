# this class configures yum to our liking
class packages::yum_config {
    # turn off fastestmirror
    file {
        "/etc/yum/pluginconf.d/fastestmirror.conf":
            content => "[main]\nenabled=0\n";
    }
}
