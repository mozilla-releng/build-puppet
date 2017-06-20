# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::people {
    include ::config
    include users::homeclean
    include ssh::keys

    # define virtual resources for all users who have keys
    $all_users = keys($ssh::keys::by_name)
    @users::person {
        $all_users: ;
    }

    # then instantiate everyone who should have an account, both users and
    # admins.  Duplicates between the two lists don't hurt.
    realize(Users::Person[$::config::admin_users, $::config::users])

    # and give the admins sudo access
    sudoers::customfile {
        'admin_users':
            content => template("${module_name}/admin_users.erb");
    }
}
