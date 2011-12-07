# Setup extlookup which we only use for config magic
$extlookup_datadir = "$settings::manifestdir/extlookup"
$extlookup_precedence = ["local-config", "default-config"]

# basic top-level classes with basic settings
import "secrets.pp"
import "stages.pp"
import "nodes.pp"
