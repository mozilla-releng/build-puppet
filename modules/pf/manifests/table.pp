# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define pf::table ( $cidr_array ) {

    include ::pf

    concat::fragment { "table_${name}":
        target  => "${::pf::pf_dir}/tables.conf",
        content => template('pf/table.erb'),
    }
}
