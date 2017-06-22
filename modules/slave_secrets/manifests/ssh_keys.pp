# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class slave_secrets::ssh_keys($slave_type) {
    include config

    # calculate the desired keyset based on organization
    case $config::org {
        moco: {
            # a table of keysets by environment (from slavealloc) and $slave_trustlevel
            $staging_keyset = {
                'trybld_dsa' => 'builder_ssh_key_staging_trybld_dsa',
                'ffxbld_rsa' => 'builder_ssh_key_staging_ffxbld_rsa',
                'tbirdbld_dsa' => 'builder_ssh_key_staging_tbirdbld_dsa',
            }
            $prod_try_keyset = {
                'trybld_dsa' => 'builder_ssh_key_try_trybld_dsa',
            }
            $prod_core_keyset = {
                'ffxbld_rsa' => 'builder_ssh_key_prod_ffxbld_rsa',
                'tbirdbld_dsa' => 'builder_ssh_key_prod_tbirdbld_dsa',
            }
            $environment = slavealloc_environment($clientcert)
            case $slave_type {
                test: {
                    # no keys for test slaves
                    $keyset = {}
                }
                build: {
                    case $environment {
                        'dev/pp': {
                            $keyset = $staging_keyset
                        }
                        'prod': {
                            case $slave_trustlevel {
                                try: {
                                    $keyset = $prod_try_keyset
                                }
                                core: {
                                    $keyset = $prod_core_keyset
                                }
                                default: {
                                    fail("Unknown slave_trustlevel ${slave_trustlevel}")
                                }
                            }
                        }
                        none: {
                            $keyset = {}
                        }
                        default: {
                            fail("unknown slavealloc environment ${environment}")
                        }
                    }
                }
            }
        }
        seamonkey: {
            # a table of keysets by environment (from slavealloc) and $slave_trustlevel
            $staging_keyset = {}
            $prod_core_keyset = {
                'id_dsa' => 'builder_ssh_key_prod_id_dsa',
                'seabld_dsa' => 'builder_ssh_key_prod_seabld_dsa',
            }
            $environment = slavealloc_environment($clientcert)
            case $slave_type {
                test: {
                    # no keys for test slaves
                    $keyset = {}
                }
                build: {
                    case $environment {
                        'dev/pp': {
                            $keyset = $staging_keyset
                        }
                        'prod': {
                            case $slave_trustlevel {
                                core: {
                                    $keyset = $prod_core_keyset
                                }
                                default: {
                                    fail("unknown slave_trustlevel ${slave_trustlevel}")
                                }
                            }
                        }
                        none: {
                            $keyset = {}
                        }
                        default: {
                            fail("unknown slavealloc environment ${environment}")
                        }
                    }
                }
            }
        }
        relabs: {
            $keyset = {
                'testy' => 'builder_ssh_key_prod_testy',
            }
        }
        default: {
            fail("no slave_secrets::ssh_key configuration for ${config::org}")
        }
    }

    # the keyset is a map from key name to secret name
    if (!is_hash($keyset)) {
        fail("keyset must be a hash; got ${keyset}")
    }

    $key_names = keys($keyset)
    slave_secrets::ssh_key {
        $key_names:
            slave_keyset => $keyset;
    }
}
