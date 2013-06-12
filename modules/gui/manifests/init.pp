# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class gui($on_gpu) {
    include config
    include users::builder
    include gui::appearance

    $screen_width = 1600
    $screen_height = 1200
    $screen_depth = 32
    $refresh = 60
    $nvidia_version = '310.32'
    $gpu_bus_id = "PCI:01:00:0"

    case $::operatingsystem {
        Darwin: {
            # $on_gpu is irrelevant on Darwin - everything's onscreen, and
            # GPU-accelerated due to the EDID box plugged into the host.  So
            # just set the resolution
            class {
                'screenresolution':
                    width => $screen_width,
                    height => $screen_height,
                    depth => $screen_depth,
                    refresh => $refresh;
            }
        }
        Ubuntu: {
            # install the window manager and its prereqs
            include packages::linux_desktop

            # and the latest version of gnome-settings-daemon; older versions crash
            # (Bug 846348)
            include packages::gnome_settings_daemon
            # Bug 859972: xrestop is needed for talos data collection
            include packages::xrestop

            #nu install the nvidia driver if we're using a GPU
            if ($on_gpu) {
                include packages::nvidia_drivers
            }

            file {
                "/etc/init/x11.conf":
                    content => template("${module_name}/x11.conf.erb"),
                    notify => Service['x11'];
                "/etc/init.d/x11":
                    ensure  => link,
                    target  => "/lib/init/upstart-job";
                "/etc/init/xvfb.conf":
                    content => template("${module_name}/xvfb.conf.erb"),
                    notify => Service['xvfb'];
                "/etc/init.d/xvfb":
                    ensure  => link,
                    target  => "/lib/init/upstart-job";
                "/etc/X11/xorg.conf":
                    content => template("${module_name}/xorg.conf.erb"),
                    notify => Service['x11'];
                "/etc/X11/Xwrapper.config":
                    content => template("${module_name}/Xwrapper.config.erb"),
                    notify => Service['x11'];

                # this is the EDID data from an Extron EDID adapter configured for 1200x1600
                "/etc/X11/edid.bin":
                    source => "puppet:///modules/${module_name}/edid.bin";
                # Bug 859867: prevent nvidia drivers to use sched_yield(), what makes compiz use 100% CPU
                "/etc/X11/Xsession.d/98nvidia":
                    content => "export __GL_YIELD=NOTHING\n",
                    notify => Service['x11'];
            }
            # start x11 *or* xvfb, depending on whether we have a GPU or not
            service {
                'x11':
                    ensure => $on_gpu ? { true => running, default => stopped },
                    enable => $on_gpu ? { true => true, default => false },
                    require => File['/etc/init.d/x11'],
                    notify => Service['Xsession'];
                'xvfb':
                    ensure => $on_gpu ? { true => stopped, default => running },
                    enable => $on_gpu ? { true => false, default => true },
                    require => File['/etc/init.d/xvfb'],
                    notify => Service['Xsession'];
            }

            file {
                "/etc/init/Xsession.conf":
                    content => template("${module_name}/Xsession.conf.erb"),
                    notify => Service['Xsession'];
                "/etc/init.d/Xsession":
                    ensure  => link,
                    target  => "/lib/init/upstart-job";

                "${users::builder::home}/.xsessionrc":
                    content => "DESKTOP_SESSION=ubuntu\n",
                    owner => $::users::builder::username,
                    group => $::users::builder::group,
                    mode => 0644,
                    notify => Service['x11'];

                # make sure the builder user doesn't have any funny business
                ["${users::builder::home}/.xsession",
                 "${users::builder::home}/.xinitrc",
                 "${users::builder::home}/.Xsession"]:
                    ensure => absent;
            }
            service {
                'Xsession':
                    ensure => running,
                    enable => true,
                    require => File['/etc/init.d/Xsession'];
            }
        }
        default: {
            fail("gui is not supported on $::operatingsystem")
        }
    }
}
