# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class hardware::ec2_config {
    case $::fqdn {
        /.*\.releng\.(use1|usw2)\.mozilla\.com$/: {
            # This config file enables/disables various plugin execution by the EC2 config service
            # The file below does not contain the Mozilla license header because commented portion breaks the ec2 config service
            file {
                'C:/Program Files/Amazon/Ec2ConfigService/Settings/config.xml':
                    content => file("${module_name}/EC2_config.xml"),
            }
        }
    }
}
