class packages::setup {
    # Manage these in the packagesetup stage so that they are in place by the
    # time any Package resources are managed.
    class {
        'yum-repo::base': stage => packagesetup;
        'yum-repo::updates': stage => packagesetup;
        'yum-repo::epel': stage => packagesetup;
        'yum-repo::releng-public': stage => packagesetup;
    }
}
