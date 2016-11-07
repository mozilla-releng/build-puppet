# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster {
    include puppetmaster::manifests
    include puppetmaster::install
    include puppetmaster::config
    include puppetmaster::httpd
    include puppetmaster::data
    include puppetmaster::ssl
    include puppetmaster::dirs
    include puppetmaster::deploy
    include puppetmaster::hiera
    include puppetmaster::extsyncs
    include puppetmaster::foreman_facts
    include nrpe::check::puppetmaster_certs
}
