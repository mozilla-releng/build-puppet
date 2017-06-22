# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Check if current AMI is up to date
class runner::tasks::check_ami($runlevel=0) {
    include runner
    include packages::pyyaml

    case $::operatingsystem {
        'Windows': {
            runner::task {
                "${runlevel}-check_ami.bat":
                    source => 'puppet:///modules/runner/tasks/check_ami.bat';
            }
            file {
                "C:/opt/runner/check_ami.py" :
                    source => 'puppet:///modules/runner/check_ami.py';
            }
        }
        default: {
            runner::task {
                "${runlevel}-check_ami":
                    source => 'puppet:///modules/runner/check_ami.py';
            }
        }
    }
}
