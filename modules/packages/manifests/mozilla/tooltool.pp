# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::tooltool {
    # this package is simple enough that its source code is embedded in the
    # puppet repo.  It gets the Python intepreter added to its shebang line
    include packages::mozilla::python27

    $python   = $::packages::mozilla::python27::python
    $filename = $::operatingsystem ? {
        windows => 'C:/mozilla-build/tooltool.py',
        default => '/tools/tooltool.py',
    }

    file {
        $filename:
            mode    => filemode(0755),
            content => template('packages/tooltool.py');
    }

    # put a symlink in from /builds/tooltool.py, except where symlinks aren't
    # supported.
    if ($::operatingsystem != 'windows') {
        file {
            '/builds/tooltool.py':
                ensure => 'link',
                target => $filename;
        }
    }
}
