# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class vnc::ultravnc_ini {
    include packages::ultravnc
    file { 'C:\Program Files\uvnc bvba\UltraVnc\ultravnc.ini':
        require => Class["packages::ultravnc"],
        replace => true,        
        content => template("vnc/ultravnc.ini.erb"), 
    }
}        
