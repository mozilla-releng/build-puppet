# Setup extlookup which we only use for config magic
$extlookup_datadir = "$settings::manifestdir/extlookup"
$extlookup_precedence = ["local-config", "default-config", "secrets"]

# basic top-level classes with basic settings
import "stages.pp"
import "nodes.pp"

# Default to root:root 0644 ownership
File {
    owner => 0,
    group => 0,
    mode => "0644",
    backup => false,
}
