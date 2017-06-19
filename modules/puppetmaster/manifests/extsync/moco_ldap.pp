# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::extsync::moco_ldap($ensure, $moco_ldap_uri, $moco_ldap_root,
                $moco_ldap_dn, $moco_ldap_pass, $users_in_groups={}) {
    include packages::pyyaml
    include packages::python_ldap

    # the shell script snippet below runs this python script
    $py_script = '/usr/local/sbin/extsync-moco_ldap.py'
    file {
        $py_script:
            show_diff => false,
            content   => template("${module_name}/extsync/moco_ldap.py.erb");
    }

    puppetmaster::extsync_crontask {
        'moco_ldap':
            ensure            => $ensure,
            minute            => '5',
            generation_script => "python ${py_script} > \${OUTPUT}";
    }
}
