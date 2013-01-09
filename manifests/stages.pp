# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Stages
# if you add a new key here, add it to the wiki as well!

# The following stages are available, aside from 'main', the default stage.

stage {
    # network:
    # This stage should handle any network related configurations for some
    # specific cases (like AWS)
    'network':
        before => Stage['packagesetup'];

    # packagesetup:
    # This stage should handle any preliminaries required for package
    # installations, so that subsequent package installations do not need to
    # require them explicitly.
    'packagesetup':
        before => Stage['users'];

    # users:
    # This stage creates user accounts; while this is normally automatically
    # required, the requirement doesn't work with the temporary 'darwinuser'
    # type.
    'users':
        before => Stage['main'];
}
