class balrog_scriptworker::settings {
    include ::config

    $root = $config::balrog_scriptworker_root
    $balrogscript_repo = $config::balrog_scriptworker_git_balrogscript_repo
    $tools_repo = $config::balrog_scriptworker_hg_tools_repo
    $tools_branch = $config::balrog_scriptworker_hg_tools_branch
}
