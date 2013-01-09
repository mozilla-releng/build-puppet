# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::sync_data {
    file {
        "/etc/cron.d/sync_data.cron":
            content => "15 * * * * root  rsync -a --exclude=lost+found --delete rsync://puppetagain.pub.build.mozilla.org/data/ /data/\n";
    }
}
