# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::install {
    include packages::mercurial
    include packages::mozilla::git
    include packages::mozilla::git_remote_hg

    # dpkg includes dpkg-scanpackages
    include packages::dpkg

    # packages::httpd is handled by the httpd module
    include packages::mod_ssl
    include packages::mod_passenger
    include packages::puppetserver
    include packages::procmail

    # By default we ship mercurial 1.4. Lets install the version for Python 2.7 for now
    include packages::mozilla::py27_mercurial

    # taskcluster-host-secrets service
    include taskcluster_host_secrets
}
