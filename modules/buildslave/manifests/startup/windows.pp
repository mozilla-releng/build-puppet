# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class buildslave::startup::windows {
    include users::builder
    include dirs::programdata::puppetagain

    $builder_username = $users::builder::username
    $puppet_semaphore = 'C:\ProgramData\PuppetAgain\puppetcomplete.semaphore'
    # Batch file to start buildbot
    # Batch files varies slightly between AWS and datacenter machines 
    case $::fqdn {
        /.*\.releng\.(use1|usw2)\.mozilla\.com$/: {
            include instance_metadata
            file {
                'c:/programdata/puppetagain/start-buildbot.bat':
                    content => template("${module_name}/EC2_start-buildbot.bat.erb"),
                    require => Class[instance_metadata];
            }
        }
        default: {
            file {
                'c:/programdata/puppetagain/start-buildbot.bat':
                    content  => template("${module_name}/start-buildbot.bat.erb");
            }
        }
    }

    # XML file to set up a schedule task to to launch buildbot on builder log in.
    # XML file needs to exported from the task scheduler gui. Also note when using the XML import be aware of machine specific values such as name will need to be replaced with a variable.
    # Hence the need for the template.
    file {
        'c:/programdata/puppetagain/start-buildbot.xml':
            content => template('buildslave/start-buildbot.xml.erb');
    }
    # Importing the XML file using schtasks
    # Refrence http://technet.microsoft.com/en-us/library/cc725744.aspx and http://technet.microsoft.com/en-us/library/cc722156.aspx
    $schtasks = 'C:\Windows\system32\schtasks.exe'
    shared::execonce { 'startbuildbot':
        command => "${schtasks} /Create /XML c:\\programdata\\puppetagain\\start-buildbot.xml /tn StartBuildbot",
        require => File['c:/programdata/puppetagain/start-buildbot.xml'],
    }
}
