# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Stages
# if you add a new key here, add it to the wiki as well!

# The following stages are available, aside from 'main', the default stage.

# packagesetup
stage { 'packagesetup': before => Stage['users']; }
#
# This stage should handle any preliminaries required for package installations,
# so that subsequent package installations do not need to require them explicitly.

# users
stage { 'users': before => Stage['main']; }
#
# This stage creates user accounts; while this is normally automatically required,
# the requirement doesn't work with the temporary 'darwinuser' type.
