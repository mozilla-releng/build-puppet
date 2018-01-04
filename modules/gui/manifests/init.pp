# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class gui(
    $on_gpu,
    $screen_width,
    $screen_height,
    $screen_depth,
    $refresh
) {
    include config
    include users::builder
    include gui::appearance

    $nvidia_version = '361.42'

    if ($::manufacturer == 'HP' and $::boardproductname =~ /ProLiant m710x/) {
        # The new moonshot hardware GPU workers have an intel gpu.
        $use_nvidia = false
        # Remove the nvidia packages so they do not conflict with intel.
        package {
            'nvidia-*':
                ensure => absent;
        }
    } else {
        # Before the moonshots, we used nvidia for all gpu hardware.
        $use_nvidia = $on_gpu and $::virtual == 'physical'
    }

    case $::operatingsystem {
        Darwin: {
            # $on_gpu is irrelevant on Darwin - everything's onscreen, and
            # GPU-accelerated due to the EDID box plugged into the host.  So
            # just set the resolution
            class {
                'screenresolution':
                    width   => $screen_width,
                    height  => $screen_height,
                    depth   => $screen_depth,
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

            if (!$on_gpu) {
                # We only run b2g reftests on EC2 machines via xvfb
                include packages::mesa
            }

            if ($use_nvidia) {
                include packages::nvidia_drivers
            }

            file {
                # Bug 1027345
                # Auto-detection of X settings works fine, but it would be
                # better to have all needed settings generated from the template.
                # Special-casing NVidia GPUs for now.
                '/etc/X11/Xwrapper.config':
                    content => template("${module_name}/Xwrapper.config.erb"),
                    notify  => Service['x11'];

                # this is the EDID data from an Extron EDID adapter configured for 1200x1600
                '/etc/X11/edid.bin':
                    source => "puppet:///modules/${module_name}/edid.bin";

                # Bug 859867: prevent nvidia drivers to use sched_yield(),
                # what makes compiz use 100% CPU
                '/etc/X11/Xsession.d/98nvidia':
                    ensure  => $use_nvidia ? {
                                    true    => present,
                                    default => absent },
                    content => "export __GL_YIELD=NOTHING\n",
                    notify  => Service['x11'];

                '/etc/xdg/autostart/jockey-gtk.desktop':
                    content => template("${module_name}/jockey-gtk.desktop");

                '/etc/xdg/autostart/deja-dup-monitor.desktop':
                    content => template("${module_name}/deja-dup-monitor.desktop");

                "${users::builder::home}/.xsessionrc":
                    content => "DESKTOP_SESSION=ubuntu\n",
                    owner   => $::users::builder::username,
                    group   => $::users::builder::group,
                    mode    => '0644',
                    notify  => Service['x11'];

                # make sure the builder user doesn't have any funny business
                [ "${users::builder::home}/.xsession",
                  "${users::builder::home}/.xinitrc",
                  "${users::builder::home}/.Xsession"]:
                    ensure => absent;
            }

            case $::operatingsystemrelease {
                12.04,14.04: {
                    $gpu_bus_id = 'PCI:01:00:0'
                    file {
                        '/etc/X11/xorg.conf':
                            ensure  => $use_nvidia ? {
                                            true    => present,
                                            default => absent },
                            content => template("${module_name}/xorg.conf.erb"),
                            notify  => Service['x11'];
                        '/etc/init.d/x11':
                            ensure => link,
                            target => '/lib/init/upstart-job';
                        '/etc/init.d/xvfb':
                            ensure => link,
                            target => '/lib/init/upstart-job';
                        '/etc/init.d/Xsession':
                            ensure => link,
                            target => '/lib/init/upstart-job';
                        '/etc/init/x11.conf':
                            content => template("${module_name}/x11.conf.erb"),
                            notify  => Service['x11'];
                        '/etc/init/xvfb.conf':
                            content => template("${module_name}/xvfb.conf.erb"),
                            notify  => Service['xvfb'];
                        '/etc/init/Xsession.conf':
                            content => template("${module_name}/Xsession.conf.erb"),
                            notify  => Service['Xsession'];
                    }

                    # start x11 *or* xvfb, depending on whether we have a GPU or not
                    service {
                        'x11':
                            ensure  => $on_gpu ? {
                                          true    => undef,
                                          default => stopped },
                            enable  => $on_gpu ? {
                                          true    => true,
                                          default => false },
                            require => File['/etc/init.d/x11'],
                            notify  => Service['Xsession'];

                        'xvfb':
                            ensure  => $on_gpu ? {
                                          true    => stopped,
                                          default => undef },
                            enable  => $on_gpu ? {
                                          true    => false,
                                          default => true },
                            require => File['/etc/init.d/xvfb'],
                            notify  => Service['Xsession'];
                        'Xsession':
                            # we do not ensure this is running; the system will start
                            # it after puppet is done
                            enable  => true,
                            require => File['/etc/init.d/Xsession'];
                    }
                }
                16.04: {
                    $gpu_bus_id = 'PCI:0:02:0'
                    file {
                        '/etc/X11/xorg.conf':
                            ensure  => present,
                            content => template("${module_name}/xorg.conf.u16.erb"),
                            notify  => Service['x11'];
                        '/lib/systemd/system/x11.service':
                            content => template("${module_name}/x11.service.erb"),
                            notify  => Service['x11'];
                        '/lib/systemd/system/xvfb.service':
                            content => template("${module_name}/xvfb.service.erb"),
                            notify  => Service['xvfb'];
                        '/lib/systemd/system/Xsession.service':
                            content => template("${module_name}/Xsession.service.erb"),
                            notify  => Service['Xsession'];
                        '/lib/systemd/system/changeresolution.service':
                            content => template("${module_name}/changeresolution.service.erb"),
                            notify  => Service['changeresolution'];
                        '/usr/local/bin/changeresolution.sh':
                            source => 'puppet:///modules/gui/changeresolution.sh',
                            notify => Service['changeresolution'];
                    }
                    # start x11 *or* xvfb, depending on whether we have a GPU or not
                    service {
                        'x11':
                            ensure   => $on_gpu ? {
                                            true    => undef,
                                            default => stopped },
                            provider => 'systemd',
                            enable   => $on_gpu ? {
                                            true    => true,
                                            default => false },
                            require  => File['/lib/systemd/system/x11.service'],
                            notify   => Service['Xsession'];
                        'xvfb':
                            ensure   => $on_gpu ? {
                                            true    => stopped,
                                            default => undef },
                            provider => 'systemd',
                            enable   => $on_gpu ? {
                                            true    => false,
                                            default => true },
                            require  => File['/lib/systemd/system/xvfb.service'],
                            notify   => Service['Xsession'];
                        'Xsession':
                            # we do not ensure this is running; the system will start
                            # it after puppet is done
                            provider => 'systemd',
                            enable   => true,
                            require  => File['/lib/systemd/system/Xsession.service'];
                        'changeresolution':
                            # To force resolution to 1600x1200 for Intel driver, we will use a service to run some xrander
                            # commands after the Xsession service will be started
                            provider => 'systemd',
                            enable   => true,
                            require  => File['/lib/systemd/system/changeresolution.service'];
                    }
                }
                default: {
                    fail ("Cannot install on Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("gui is not supported on ${::operatingsystem}")
        }
    }
}
