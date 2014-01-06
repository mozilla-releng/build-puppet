class slaverebooter::settings {
    include ::config

    $root = $config::slaverebooter_root
    $config = "${root}/slaverebooter.ini"
    $tools_dst = "${root}/tools"
    $logfile_dst = "${root}/slaverebooter.log"
}
