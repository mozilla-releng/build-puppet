# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# buildbot master

class toplevel::server::buildmaster inherits toplevel::server {
    include security
    include nrpe::base
    include users::builder
    include dirs::builds::buildbot
    include packages::gcc
    include packages::make
    include packages::mercurial
    include packages::mysql_devel
    include packages::mozilla::git
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include packages::patch

    assert {
      'buildmaster-high-security':
        condition => $::security::high;
    }
}

