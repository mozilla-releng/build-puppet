# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Ref https://bugzilla.mozilla.org/show_bug.cgi?id=1026870

class tweaks::vs_2013_lnk {
    file {
        'c:/tools/vs2013':
            ensure => link,
            target => 'C:\Program Files (x86)\Microsoft Visual Studio 12.0';
    }
    # cvtres.exe is originally from the Microsoft 2013 Visual Studio install
    # currently we need to be available to VS 2010 
    file {
        'C:/Program Files (x86)/Microsoft Visual Studio 10.0/VC/bin/cvtres.exe' :
            ensure => file,
            source => 'puppet:///repos/private/EXEs/cvtres.exe';
    }
    file {
        'C:/Program Files (x86)/Microsoft Visual Studio 10.0/VC/bin/amd64/cvtres.exe' :
            ensure => file,
            source => 'puppet:///repos/private/EXEs/cvtres.exe';
    }

}

