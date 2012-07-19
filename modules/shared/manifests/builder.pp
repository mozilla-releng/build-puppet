class shared::builder {

    #files are owned by staff group on macosx
    $group = $operatingsystem ? {
        Darwin => 'staff',
        default => $config::builder_username
    }
   
     #specifying the uid is temporary util usr is fixed on 10.8 in puppet   
     $uid = $operatingsystem ? {
        Darwin => 501,
        default => 500
    }
}
