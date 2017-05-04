#! /bin/bash

# Don't reboot sooner than this time after worker startup.  This avoids tight
# reboot loops, allowing an administrator to get onto the machine in the
# interim. If the worker runs for longer than this time, the reboot is immediate.
MIN_REBOOT_PERIOD=300 # seconds

log() {
    logger -s -t run-tc-worker "${@}"
}

log "starting worker"
/usr/local/bin/taskcluster-worker work /etc/taskcluster-worker.yml 2>&1 | logger -t taskcluster-worker -s

# wait for reboot, if necessary
while [ $SECONDS -lt $MIN_REBOOT_PERIOD ]; do
    log "waiting for minimum reboot period"
    sleep $((MIN_REBOOT_PERIOD - SECONDS))
done

log "rebooting"
sudo /sbin/reboot
