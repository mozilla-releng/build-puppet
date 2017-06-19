# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class proxxy::settings {
    $cache_dir         = '/var/cache/proxxy'
    $nginx_conf        = '/etc/nginx/nginx.conf'
    $nginx_vhosts_conf = '/etc/nginx/sites-enabled/proxxy'

    # see http://nginx.org/en/docs/syslog.html
    $syslog_server = 'unix:/dev/log'

    $backends = {
        'ftp.mozilla.org' => {
            path => 'https://ftp.mozilla.org/',
            size => '16g',
            ttl => '1d',
        },
        's3' => {
            path => 'https://s3.amazonaws.com/',
            size => '16g',
            ttl => '1d',
        },
        'pypi.pub.build.mozilla.org' => {
            path => 'http://pypi.pub.build.mozilla.org/',
            size => '16g',
            ttl => '1d',
        },
        'pypi.pvt.build.mozilla.org' => {
            path => 'http://pypi.pvt.build.mozilla.org/',
            size => '16g',
            ttl => '1d',
        },
        'runtime-binaries.pvt.build.mozilla.org' => {
            path => 'http://runtime-binaries.pvt.build.mozilla.org/',
            size => '16g',
            ttl => '1d',
        },
        'tooltool.pvt.build.mozilla.org' => {
            path => 'http://tooltool.pvt.build.mozilla.org/',
            size => '16g',
            ttl => '1d',
        },
        's3-us-west-2.amazonaws.com' => {
            path => 'https://s3-us-west-2.amazonaws.com/',
            size => '16g',
            ttl => '1d',
        },
        's3-us-west-1.amazonaws.com' => {
            path => 'https://s3-us-west-1.amazonaws.com/',
            size => '16g',
            ttl => '1d',
        },
    }
}
