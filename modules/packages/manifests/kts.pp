# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

# ZIP is from http://www.kpym.com/2/kpym/index.htm

class packages::kts {
    if ($::operatingsystem != 'windows') {
        fail('KTS is only available on Windows')
    }

    packages::pkgzip {
        'kts119c.zip':
            zip        => 'kts119c.zip',
            target_dir => '"C:\Program Files"',
            notify     => Exec['move-kts-to-correct-dir'];
    }

    # The unzip operation creates C:\Program Files\kts119c; we want C:\Program Files\KTS.
    exec {
        'move-kts-to-correct-dir':
            # MOVE appears to be a CMD.EXE built-in
            command     => 'C:\WINDOWS\SYSTEM32\CMD.EXE /C MOVE kts119c KTS',
            cwd         => 'C:\Program Files',
            refreshonly => true,
            creates     => 'C:\Program Files\KTS';
    }

    file {
        # create the KTS dir and its "Scripts" subdir; this exists only
        # to ensure that the package is installed before anything tries
        # to write to this directory.
        ['C:/Program Files/KTS', 'C:/Program Files/KTS/Scripts']:
            ensure  => directory,
            require => Exec['move-kts-to-correct-dir'];
    }
}
