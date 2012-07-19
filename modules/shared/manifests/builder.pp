class shared::builder {

#files are owned by staff group on macosx
    $group = $operatingsystem ? {
        Darwin => 'staff',
        default => $config::builder_username
    }
    
     $uid = $operatingsystem ? {
        Darwin => 501,
        default => 500
    }
}
