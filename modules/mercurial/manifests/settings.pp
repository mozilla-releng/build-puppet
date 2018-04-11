# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mercurial::settings {
    # Bug 1336535 - Changing http://hg.mozilla.org to https:// everywhere (relops-puppet edition)
    define change_file() {
        exec { $title:
            command => "sed -i -e 's/default = http:/default = https:/g' `find ${title} -maxdepth 4 -mtime +1 -name hgrc -exec grep -l 'default = http:' {} \\;`",
            path    => ['/bin', '/sbin', '/usr/bin', '/usr/local/bin'],
            # if the directory exist (ls directory|wc -l) is greater that 0
            # and the find command return a list of files
            onlyif  => ["test `ls ${title}|wc -l` -gt 0", "test `find ${title} -maxdepth 4 -mtime +1 -name hgrc -exec grep -l 'default = http:' {} \\;|wc -l` -gt 0"]
        }
    }
    case $::operatingsystem {
        CentOS, Ubuntu, Darwin: {
            $hgext_dir       = '/usr/local/lib/hgext'
            $hgrc            = '/etc/mercurial/hgrc'
            $hgrc_parentdirs = ['/etc/mercurial']
            $search_paths = ['/etc/puppet/environments/', '/home/buildduty/', '/tmp/*/buildbot-configs/.hg/hgr', '/builds/buildbot/', '/home/*/']
            # Bug 1336535 - Changing http://hg.mozilla.org to https:// everywhere (relops-puppet edition)
            # Check for any occurance of 'default = http:' string in all hgrc file, the search s limited only to the directory
            # set in $search_paths and replace this string with 'default = https:' string
            change_file{$search_paths: }
        }
        # Setting up for future use and to prevent failures
        Windows: {
            $hgext_dir       = "C:\\mozilla-build\\hg\\"
            $hgrc            = "C:\\mozilla-build\\hg\\mercurial.ini"
            $hgrc_parentdirs = ["C:\\mozilla-build\\hg"]
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
