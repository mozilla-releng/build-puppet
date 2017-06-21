define pf::table ( $cidr_array ) {

    include ::pf

    concat::fragment { "table_${name}":
        target => "${::pf::pf_dir}/tables.conf",
        content => template('pf/table.erb'),
    }
}
