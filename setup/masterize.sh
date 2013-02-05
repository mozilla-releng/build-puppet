#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

## utilities

get_local_config() {
    local var="${1}"
    local local_config_link="$PWD/manifests/extlookup/local-config.csv"
    grep "^${var}," "${local_config_link}" | cut -d, -f 2-
}

## phase handling

PHASES=()

add_phase() {
    PHASES=("${PHASES[@]}" "${1}")
}

run_phases() {
    local ignore_until="${1}"

    for phase in "${PHASES[@]}"; do
        if [ -n "${ignore_until}" ] && [ "${phase}" != "${ignore_until}" ]; then
            continue
        fi
        ignore_until=

        echo "==== ${phase} ===="
        if ! ${phase}; then
            echo "Fix the errors above and then restart at this phase with"
            echo "./setup/masterize.sh $phase"
            exit 1
        fi
    done
}

## action

for script in setup/masterize/*; do
    source "$script" || exit 1
done
run_phases "${@}"
