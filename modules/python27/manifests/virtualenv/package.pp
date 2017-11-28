# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
#
# Install the given Python package into the given virtualenv.
define python27::virtualenv::package($user) {
    include python27::virtualenv::settings
    include python27::misc_python_dir
    include python27::pip_check_py
    include users::root

    # extract the virtualenv and tarball from the title
    $virtualenv   = regsubst($title, '\|\|.*$', '')
    $pkg          = regsubst($title, '^.*\|\|', '')

    $pip_check_py = $python27::pip_check_py::file
    # give a --find-links option for each data server, so pip will search them all.
    $data_server  = $config::data_server
    $data_servers = $config::data_servers

    $pip_options  = inline_template("--no-deps --no-index <%
servers = [ @data_server ] + Array(@data_servers)
servers.uniq.each do |mirror_server| -%> --find-links=http://<%= mirror_server %>/python/packages --trusted-host=<%= mirror_server %> <%
end
-%>")
    if ($user == 'root') {
        $home_dir = $::users::root::home
    } else {
        $home_dir = $::operatingsystem ? {
            Darwin  => "/Users/${user}",
            default => "/home/${user}"
        }
    }
    $ve_bin_dir = $::operatingsystem ? {
        windows => "${virtualenv}\\Scripts\\",
        default => "${virtualenv}/bin/",
    }
    $exe = $::operatingsystem ? {
        windows => '.exe',
        default => ''
    }
    exec {
        # point pip at the package directory so that it can select the best option
        "pip ${title}":
            name        => "${ve_bin_dir}pip${exe} install ${pip_options} ${pkg}",
            logoutput   => on_failure,
            onlyif      => "${ve_bin_dir}python${exe} ${pip_check_py} ${pkg}",
            user        => $user,
            environment => [
                "HOME=${home_dir}",
                'PIP_CONFIG_FILE=/dev/null' # because sudo will sometimes lead pip to ~administrator/.pip
            ],
            require     => [
                Class['python27::pip_check_py'],
                Exec["virtualenv ${virtualenv}"],
                Class['users::root'], # for pip.conf
            ];
    }
}
