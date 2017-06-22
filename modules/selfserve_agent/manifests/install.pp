# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class selfserve_agent::install {
    include ::config
    include dirs::builds
    include users::builder
    include packages::mozilla::python27
    include packages::gcc
    include packages::make
    include packages::mysql_devel
    include selfserve_agent::settings
    python::virtualenv {
        $selfserve_agent::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                'anyjson==0.3.3',
                'Beaker==1.5.4',
                'FormEncode==1.2.4',
                'Mako==0.4.1',
                'MarkupSafe==0.12',
                'MySQL-python==1.2.3',
                'Paste==1.7.5.1',
                'PasteDeploy==1.5.0',
                'PasteScript==1.7.3',
                'Pygments==1.4',
                'Pylons==1.0',
                'amqp==1.4.3',
                'buildapi==0.3.25',
                'buildbot==0.8.4-pre-moz1',
                'decorator==3.3.1',
                'distribute==0.6.14',
                'kombu==3.0.12',
                'Routes==1.12.3',
                'SQLAlchemy==0.6.8',
                'Tempita==0.5.1',
                'Twisted==10.1.0',
                'WebError==0.10.3',
                'WebHelpers==1.3',
                'WebOb==1.0.8',
                'WebTest==1.2.3',
                'meld3==0.6.5',
                'nose==1.0.0',
                'pytz==2011d',
                'redis==2.4.10',
                'simplejson==2.1.6',
                'wsgiref==0.1.2',
                'zope.interface==3.6.1',
            ];
    }
}
