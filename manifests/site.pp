# basic top-level classes with basic settings
import "settings.pp"
import "secrets.pp"
import "stages.pp"

# do not use nodes/* here, as the server wil fail to reload when new files are added
import "nodes/abstract.pp"
import "nodes/buildservices.pp"
import "nodes/slaves.pp"
import "nodes/test.pp"
