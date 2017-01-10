# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# (private)
class scriptworker::instance::settings {
    $git_key_repo_url = "https://github.com/mozilla-releng/cot-gpg-keys.git"
    $provisioner_id = "scriptworker-prov-v1"
    $temp_prov_id = "test-dummy-provisioner"
    $temp_worker_id = "dummy-worker-mtabara1"
}
