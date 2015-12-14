# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define mercurial::hgrc($path=$title, $owner, $group)  {
    include mercurial::settings

    case $::operatingsystem {
        # Keeping the two templates separate due to the high quantity of noise in the mercurial.ini
        'Windows': {
            file {
                "$settings::hgrc_parentdirs\\mercurial.ini":
                    content => template("mercurial/mercurial.ini.erb");
            }
        }
        default: {
            file {
                $path:
                    mode => filemode(0644),
                    owner => $owner,
                    group => $group,
                    content => template("mercurial/hgrc.erb");
            }
        }
    }
}
