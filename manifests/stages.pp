# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Stages
# if you add a new key here, add it to the wiki as well!

# The following stages are available, aside from 'main', the default stage.

# packagesetup
stage { 'packagesetup': before => Stage['main']; }
#
# This stage should handle any preliminaries required for package installations,
# so that subsequent package installations do not need to require them explicitly.
