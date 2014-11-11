# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All buildbot slaves (both build and test) are subclasses of this class.
class toplevel::slave::releng inherits toplevel::slave {
    include dirs::builds::slave
    include buildslave
    include instance_metadata
    include clean::appstate

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::mozilla::py27_mercurial
    include packages::wget
    
    if ($::operatingsystem == Windows) {
        include tweaks::disablejit
        include tweaks::memory_paging
        include tweaks::nouac
        include tweaks::ntfs_options
        include tweaks::process_priority
        include tweaks::pwrshell_options
        include tweaks::server_initialize 
        include tweaks::shutdown_tracker
        include packages::binscope
        include packages::psutil
        include packages::mapi_headers
        include fw::windows_exceptions
        include fw::windows_settings
    }
}
