class balrog_scriptworker::settings {
    include ::config

    $base = $config::balrog_scriptworker_base
    $root = $config::balrog_scriptworker_root
    $py27venv = $config::balrog_scriptworker_py27venv
    $py35venv = $config::balrog_scriptworker_py35venv
    $tools_path = $config::balrog_scriptworker_hg_tools_path
    $tools_repo = $config::balrog_scriptworker_hg_tools_repo
    $tools_branch = $config::balrog_scriptworker_hg_tools_branch
    $balrogscript_path = $config::balrog_scriptworker_git_balrogscript_path
    $balrogscript_keys = $config::balrog_scriptworker_git_balrogscript_keys
    $balrogscript_repo = $config::balrog_scriptworker_git_balrogscript_repo
}
