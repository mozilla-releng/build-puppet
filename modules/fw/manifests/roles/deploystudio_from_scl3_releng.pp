# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::deploystudio_from_scl3_releng {
    include fw::networks

    # Technicially it's BSDP. See https://static.afp548.com/mactips/bootpd.html
    fw::rules { 'allow_dhcp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'dhcp_server'
    }
    # TFTP so client can get booter file
    fw::rules { 'allow_tftp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'tftp'
    }
    # RPC(portmapper)/NFS. Used to during netboot for NBI system image
    fw::rules { 'allow_rpc_udp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'rpc_udp'
    }
    fw::rules { 'allow_rpc_tcp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'rpc_tcp'
    }
    # Set static in /etc/nfs.conf
    fw::rules { 'allow_stat_udp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'stat_udp'
    }
    fw::rules { 'allow_stat_tcp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'stat_tcp'
    }
    fw::rules { 'allow_nfs_udp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'nfs_udp'
    }
    fw::rules { 'allow_nfs_tcp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'nfs_tcp'
    }
    # SMB/AFP used by DS client (images, logs, etc)
    fw::rules { 'allow_smb_udp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'smb_udp'
    }
    fw::rules { 'allow_smb_tcp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'smb_tcp'
    }
    # SMB over IP
    fw::rules { 'allow_smb_ip_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'smb_ip'
    }
    fw::rules { 'allow_afp_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'afp'
    }
    # http(s) is the main DS port
    fw::rules { 'allow_ds_http_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'ds_http'
    }
    fw::rules { 'allow_ds_https_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'ds_https'
    }
    # Used if NBI is set to netboot via http
    fw::rules { 'allow_http_from_scl3_releng':
        sources => $::fw::networks::scl3_releng,
        app     => 'http'
    }
}
