# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
from __future__ import print_function

import sys
import pkg_resources
import traceback

# check for the package, exiting with 1 if found, and 0 otherwise -- note that
# this is the reverse of what you might think, but works with the 'onlyif'
# parameter in modules/python/manifests/virtualenv.pp.

# For background on the Python stuff, see
# http://peak.telecommunity.com/DevCenter/PkgResources#basic-workingset-methods

pkg_name = sys.argv[1]
try:
    # use find() instead of require(), since it does not follow dependencies
    req = pkg_resources.Requirement.parse(pkg_name)
    dist = pkg_resources.working_set.find(req)
    if dist:
        print("found - exit status 1")
        sys.exit(1) # found!
except (pkg_resources.DistributionNotFound, pkg_resources.VersionConflict):
    traceback.print_exc()
except Exception:
    # exit with 0 on any other exceptions, too - this will cause pip to try to
    # install the package, which will hopefully lead to a failure that puppet
    # will report on
    traceback.print_exc()

print("not found - exit status 0")
