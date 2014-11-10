# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class buildslave::startup::windows {
include packages::mozilla::mozilla_build
    #Bat file to start buildbot
    file {
        'C:/mozilla-build/start-buildbot.bat':
            source  => "puppet:///modules/buildslave/start-buildbot.bat",
            require => Class['packages::mozilla::mozilla_build'],
    }
    # XML file to set up a schedule task to to launch buildbot on cltbld log in.
    # XML file needs to exported from the task scheduler gui. Also note when using the XML import be aware of machine specific values such as name will need to be replaced with a variable.
    # Hence the need for the template.
    file {
        'C:/mozilla-build/startbuildbot.xml':
            content => template("buildslave/startbuildbot.xml.erb"),
            require => Class['packages::mozilla::mozilla_build'],
    }
    # Importing the XML file using schtasks
    # Refrence http://technet.microsoft.com/en-us/library/cc725744.aspx and http://technet.microsoft.com/en-us/library/cc722156.aspx
    shared::execonce { "startbuildbot":
        command => '"C:\Windows\winsxs\x86_microsoft-windows-sctasks_31bf3856ad364e35_6.1.7601.17514_none_8c46e17f1398738b\schtasks.exe" /Create  /XML "C:\mozilla-build\startbuild.xml" /tn StartBuildbot',
        require => File['C:/mozilla-build/startbuildbot.xml'],
    }
}
