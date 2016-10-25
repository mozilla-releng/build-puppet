class beetmover_scriptworker::settings {
    include ::config

    $root = $config::beetmover_scriptworker_root
    $beetmoverscript_dir = $config::beetmover_scriptworker_beetmoverscript_dir
}
