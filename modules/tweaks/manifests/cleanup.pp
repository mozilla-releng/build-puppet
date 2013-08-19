# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Clean up things on start
class tweaks::cleanup {
    include users::builder

    # Note that this command will likely fail for runs done when DMGs are
    # mounted from pkgdmg since they mount under /tmp and have really old files
    exec {
        "find /tmp/* -mmin +15 -print | xargs -n1 rm -rf":
            path => "/usr/bin:/usr/sbin:/bin";
    }

    case $::operatingsystem {
        Ubuntu, CentOS: {
            tidy {
                "$::users::builder::home/.mozilla/firefox/console.log":
                    age => 0;
            }
        }
        Darwin: {
            tidy {
                "$::users::builder::home/Library/Application Support/Firefox/console.log":
                    age => 0;
                # some tests fail to clean up after themselves here, so we do it for them; see bug 906706.
                "$::users::builder::home/Library/Caches/TemporaryItems":
                    recurse => true,
                    rmdirs => true,
                    backup => false,
                    age => 0;
            }
        }
    }
}
