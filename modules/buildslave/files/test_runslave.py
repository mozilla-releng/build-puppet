# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import base64
import os
import socket
import runslave
import unittest
import textwrap
import urllib2
import StringIO
import shutil
import tempfile

# to run these tests:
#  - change into this directory
#  - run 'trial test_runslave.py' (or whatever test-runner you prefer)

class BuildbotTac(unittest.TestCase):

    def setUp(self):
        self.old_urlopen = urllib2.urlopen
        self.old_os_path_exists = os.path.exists
        self.basedir = tempfile.mkdtemp('-test_runslave', dir=os.path.abspath('.'))
        if os.path.exists(self.basedir):
            shutil.rmtree(self.basedir)
        os.makedirs(self.basedir)

    def tearDown(self):
        urllib2.urlopen = self.old_urlopen
        os.path.exists = self.old_os_path_exists
        if os.path.exists(self.basedir):
            shutil.rmtree(self.basedir)

    def patch_urlopen(self, exp_url, result=None, raise_exc=False):
        def urlopen(url):
            self.assertEqual(url, exp_url)
            if raise_exc:
                raise RuntimeError("couldn't fetch that page, sry")
            return StringIO.StringIO(result)
        urllib2.urlopen = urlopen

    def patch_os_path_exists(self, *existing_paths):
        def exists(path):
            return path in existing_paths
        os.path.exists = exists

    def make_options(self, basedir=None, slavename='random-slave13'):
        class Options: pass
        options = Options()
        options.basedir = basedir
        options.slavename = slavename
        options.allocator_url = 'http://allocator/SLAVE'
        options.verbose = False
        return options

    # get_basedir tests

    def test_get_basedir_options(self):
        # options are preferred
        bt = runslave.BuildbotTac(self.make_options(basedir='/given/basedir'))
        bt.extract_basedir = lambda page : '/extracted/basedir'
        bt.guess_basedir = lambda slavename : '/guessed/basedir'
        self.assertEqual(bt.get_basedir(), '/given/basedir')

    def test_get_basedir_extract(self):
        # extraction is used if the basedir option is not set
        bt = runslave.BuildbotTac(self.make_options())
        bt.extract_basedir = lambda page : '/extracted/basedir'
        bt.guess_basedir = lambda slavename : '/guessed/basedir'
        self.assertEqual(bt.get_basedir(), '/extracted/basedir')

    def test_get_basedir_guess(self):
        # if there are no options and extraction fails, use a guess
        bt = runslave.BuildbotTac(self.make_options())
        bt.extract_basedir = lambda page : None
        bt.guess_basedir = lambda slavename : '/guessed/basedir'
        self.assertEqual(bt.get_basedir(), '/guessed/basedir')

    def test_get_basedir_cached(self):
        # if there are no options and extraction fails, use a guess
        bt = runslave.BuildbotTac(self.make_options())
        bt.extract_basedir = lambda page : None
        bt.guess_basedir = lambda slavename : '/guessed/basedir'
        self.assertEqual(bt.get_basedir(), '/guessed/basedir')
        bt.guess_basedir = lambda slavename : 'SHOULD NOT BE CALLED'
        self.assertEqual(bt.get_basedir(), '/guessed/basedir')

    def test_get_basedir_failure(self):
        # and if we completely strike out, raise an exception
        bt = runslave.BuildbotTac(self.make_options())
        bt.extract_basedir = lambda page : None
        bt.guess_basedir = lambda slavename : None
        self.assertRaises(runslave.NoBasedirError, lambda : bt.get_basedir())

    # extract_basedir tests

    def test_extract_basedir_unicode(self):
        tacfile = textwrap.dedent("""\
            # AUTOMATICALLY GENERATED - DO NOT MODIFY
            # generated: Tue Feb  8 16:32:01 2011 on euclid.r.igoro.us
            from twisted.application import service
            from buildbot.slave.bot import BuildSlave
            from twisted.python.logfile import LogFile
            from twisted.python.log import ILogObserver, FileLogObserver

            maxdelay = 300
            buildmaster_host = None
            passwd = None
            maxRotatedFiles = None
            basedir = u'/builds/slave'
            umask = 002
            slavename = 'linux-ix-slave01'
            usepty = 1
            rotateLength = 1000000
            port = None
            keepalive = None

            application = service.Application('buildslave')
            logfile = LogFile.fromFullPath("twistd.log", rotateLength=rotateLength,
                                        maxRotatedFiles=maxRotatedFiles)
            application.setComponent(ILogObserver, FileLogObserver(logfile).emit)
            s = BuildSlave(buildmaster_host, port, slavename, passwd, basedir,
                        keepalive, usepty, umask=umask, maxdelay=maxdelay)
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), '/builds/slave')

    def test_extract_basedir_plain(self):
        tacfile = textwrap.dedent("""\
            keepalive = None
            basedir = '/builds/slave'
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), '/builds/slave')

    def test_extract_basedir_tabs(self):
        tacfile = textwrap.dedent("""\
            keepalive = None
            basedir	=	'/builds/slave'
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), '/builds/slave')

    def test_extract_basedir_dblquote(self):
        tacfile = textwrap.dedent("""\
            keepalive = None
            basedir = "/builds/slave"
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), '/builds/slave')

    def test_extract_basedir_double_backslash(self):
        tacfile = textwrap.dedent("""\
            keepalive = None
            basedir = "c:\\\\talos-slave"
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), r'c:\talos-slave')

    def test_extract_basedir_raw(self):
        tacfile = textwrap.dedent("""\
            keepalive = None
            basedir = r'c:\\talos-slave'
            s.setServiceParent(application)""")
        bt = runslave.BuildbotTac(self.make_options())
        self.assertEqual(bt.extract_basedir(tacfile), r'c:\talos-slave')

    # guess_basedir tests

    known_hostname = {
        'bm-xserveNN' : '/builds/slave',
        'linux-ix-slaveNN' : '/builds/slave',
        'linux64-ix-slaveNN' : '/builds/slave',
        'moz2-darwin10-slaveNN' : '/builds/slave',
        'moz2-darwin9-slaveNN' : '/builds/slave',
        'moz2-linux-slaveNN' : '/builds/slave',
        'moz2-linux64-slaveNN' : '/builds/slave',
        'moz2-win32-slaveNN' : 'e:\\builds\\moz2_slave',
        'mv-moz2-linux-ix-slaveNN' : '/builds/slave',
        'mw32-ix-slaveNN' : 'e:\\builds\\moz2_slave',
        'mw64-ix-slaveNN' : 'e:\\builds\\moz2_slave',
        't-r3-w764-NN' : 'c:\\talos-slave',
        'talos-r3-fed-NN' : '/home/cltbld/talos-slave',
        'talos-r3-fed64-NN' : '/home/cltbld/talos-slave',
        'talos-r3-leopard-NN' : '/Users/cltbld/talos-slave',
        'talos-r3-snow-NN' : '/Users/cltbld/talos-slave',
        'talos-r3-w7-NN' : 'c:\\talos-slave',
        'talos-r3-xp-NN' : 'c:\\talos-slave',
        'try-linux-slaveNN' : '/builds/slave',
        'try-linux64-slaveNN' : '/builds/slave',
        'try-mac-slaveNN' : '/builds/slave',
        'try-mac64-slaveNN' : '/builds/slave',
        'try-w32-slaveNN' : 'e:\\builds\\moz2_slave',
        'w32-ix-slaveNN' : 'e:\\builds\\moz2_slave',
        'w64-ix-slaveNN' : 'e:\\builds\\moz2_slave',
        }
    known_basedirs = set(known_hostname.values())

    def test_guess_basedir_known_hostnames(self):
        bt = runslave.BuildbotTac(self.make_options())
        for hostname, basedir in self.known_hostname.iteritems():
            self.assertEqual(bt.guess_basedir(hostname), basedir)

    def test_guess_basedir_known_basedirs(self):
        bt = runslave.BuildbotTac(self.make_options())
        for basedir in self.known_basedirs:
            self.patch_os_path_exists(basedir)
            # pass a bogus hostname, so it falls back to os.path.exists
            self.assertEqual(bt.guess_basedir('randombox'), basedir,
                    "guess for %s" % basedir)

    # download tests

    def test_download_exception(self):
        bt = runslave.BuildbotTac(self.make_options(slavename='slave13'))
        self.patch_urlopen('http://allocator/slave13', raise_exc=True)
        self.assertFalse(bt.download())

    def test_download_bad_result(self):
        bt = runslave.BuildbotTac(self.make_options(slavename='slave13'))
        self.patch_urlopen('http://allocator/slave13', "this is not a tac")
        self.assertFalse(bt.download())

    def test_download_good_result_extract_basedir(self):
        bt = runslave.BuildbotTac(self.make_options(slavename='slave13'))
        bt.get_basedir = lambda : self.basedir
        self.patch_urlopen('http://allocator/slave13',
                textwrap.dedent("""\
                    # AUTOMATICALLY GENERATED - DO NOT MODIFY
                    basedir = %r """ % self.basedir))
        self.assertTrue(bt.download())
        self.assertTrue(os.path.exists(os.path.join(self.basedir, 'buildbot.tac')))

class NSCANotifier(unittest.TestCase):

    maxDiff = 1000

    fromserver_b64 = """
        unvxWHaOSEOA67AxsyjFCCOJ5i2d8pz5uHVA7A2ilccehh+UFWfXlVOIxwawjQ/UFvYBs+mdr
        aET7o4gkCTnrqoHQsBvGlbDoh7KU6vZJ8HQKHW5xiJb2RDq+aAO4U+56ZJ5WKzQHE/u5qKZwM
        pbkPPQSrnzpZMDj42knW7zVlhNubCx
    """
    fromserver = base64.b64decode(fromserver_b64)

    iv_b64 = """
        unvxWHaOSEOA67AxsyjFCCOJ5i2d8pz5uHVA7A2ilccehh+UFWfXlVOIxwawjQ/UFvYBs+mdr
        aET7o4gkCTnrqoHQsBvGlbDoh7KU6vZJ8HQKHW5xiJb2RDq+aAO4U+56ZJ5WKzQHE/u5qKZwM
        pbkPPQSrnzpZMDj42knW7zVlg=
    """
    iv = base64.b64decode(iv_b64)

    def setUp(self):
        class Options(object): pass
        self.options = Options()
        self.notifier = runslave.NSCANotifier(self.options)
        self.forward_dns = {}
        self.reverse_dns = {}

        self.old_socket_gethostbyname = socket.gethostbyname
        def gethostbyname(name):
            if name in self.forward_dns:
                return self.forward_dns[name]
            raise socket.error("fwd fail")
        socket.gethostbyname = gethostbyname

        self.old_socket_gethostbyaddr = socket.gethostbyaddr
        def gethostbyaddr(addr):
            if addr in self.reverse_dns:
                return (self.reverse_dns[addr], 'stuff', 'stuff')
            raise socket.error("reverse fail")
        socket.gethostbyaddr = gethostbyaddr

    def test_nagios_name_bmo(self):
        self.forward_dns['linux-slave10.build.mozilla.org'] = '1.2.3.4'
        self.reverse_dns['1.2.3.4'] = 'linux-slave10.build.mozilla.org'
        self.assertEqual(self.notifier.nagios_name('linux-slave10'),
                         'linux-slave10.build')

    def test_nagios_name_dcname(self):
        self.forward_dns['linux-slave10.build.mozilla.org'] = '1.2.3.4'
        self.reverse_dns['1.2.3.4'] = 'linux-slave10.build.scl1.mozilla.com'
        self.assertEqual(self.notifier.nagios_name('linux-slave10'),
                         'linux-slave10.build.scl1')

    def test_nagios_name_winbuild(self):
        self.forward_dns['w64-ix-slave10.build.mozilla.org'] = '1.2.3.4'
        self.reverse_dns['1.2.3.4'] = 'w64-ix-slave10.winbuild.scl1.mozilla.com'
        self.assertEqual(self.notifier.nagios_name('w64-ix-slave10'),
                         'w64-ix-slave10.winbuild.scl1')

    def test_nagios_name_fwd_fail(self):
        self.reverse_dns['1.2.3.4'] = 'linux-slave10.build.scl1.mozilla.com'
        self.assertEqual(self.notifier.nagios_name('linux-slave10'),
                         'linux-slave10')

    def test_nagios_name_rev_fail(self):
        self.forward_dns['linux-slave10.build.mozilla.org'] = '1.2.3.4'
        self.assertEqual(self.notifier.nagios_name('linux-slave10'),
                         'linux-slave10')

    def test_monitoring_host_from_nagios_name(self):
        tests = [
            ('slave01.build.mtv1', 'bm-admin01.mozilla.org'),
            ('slave01.build.sjc1', 'bm-admin01.mozilla.org'),
            ('slave01.build.scl1', 'admin1.infra.scl1.mozilla.com'),
            ('slave01.winbuild.scl1', 'admin1.infra.scl1.mozilla.com'),
            ('slave01.build', 'bm-admin01.mozilla.org'), # default
            ('slave01.build.tbd1', 'bm-admin01.mozilla.org'), # default
            ('slave01.mozilla.org', 'bm-admin01.mozilla.org'), # default
            ('slave01.build.mozilla.org', 'bm-admin01.mozilla.org'), # default
        ]
        inputs = [ e[0] for e in tests ]
        expected = [ e[1] for e in tests ]
        outputs = [ self.notifier.monitoring_host_from_nagios_name(i) for i in inputs ]
        self.assertEqual(zip(inputs, expected), zip(inputs, outputs))

    def test_decode_from_server(self):
        iv, timestamp = self.notifier.decode_from_server(self.fromserver)
        iv = [ ord(b) for b in iv ]
        exp = [ ord(b) for b in self.iv ]

        self.assertEqual((iv, timestamp), (exp, 0x4db9b0b1))

    def test_encode_to_server(self):
        iv = base64.b64decode("""
        7ensPMny90d3fCFfruLNODYz6lm855IZDAku6g4Id/zyZDi7VjADzawkLVoH+pM+LX6X6
        WUqA3EzMVxCOtQ+LDh26I6n61xUEImvGINCV7HB75smGZ+YTdD1jwrJzjcBRSCQ7AzsQB
        127zX6Moyr83tHGpXms+O3qHPCckH6c4Y=""")
        timestamp = 1304029911

        exp_pkt = base64.b64decode("""
        7ersPBp/aAE6xcuIruKhUVhGknTVn79qYGhYjz84WZ6HDVTfVjADzawkLVoH+pM+LX6X6
        WUqA3EzMVxCOtQ+LDh26I6n61xUEImvGINCNcSog/9Eduu1PqSU/X7JzjcBRSCQ7AzsQB
        127zX6Moyr83tHGpXms+O3qHPCckH6c4bt6ew8yfL3R3d8IV+u4s04NjPqWbznkhkMCS7
        qDgh3/PJkOLtWMAPNrCQtWgf6kz4tfpfpZSoDcTMxXEI61D4sOHbojqfrXFQQia8Yg0I/
        1K2D9AcZn5hN0PWPCsnONwFFIJDsDOxAHXbvNfoyjKvze0caleaz47eoc8JyQfpzhu3p7
        DzJ8vdHd3whX67izTg2M+pZvOeSGQwJLuoOCHf88mQ4u1YwA82sJC1aB/qTPi1+l+llKg
        NxMzFcQjrUPiw4duiOp+tcVBCJrxiDQlexwe+bJhmfmE3Q9Y8Kyc43AUUgkOwM7EAddu8
        1+jKMq/N7RxqV5rPjt6hzwnJB+nOG7ensPMny90d3fCFfruLNODYz6lm855IZDAku6g4I
        d/zyZDi7VjADzawkLVoH+pM+LX6X6WUqA3EzMVxCOtQ+LDh26I6n61xUEImvGINCV7HB7
        5smGZ+YTdD1jwrJzjcBRSCQ7AzsQB127zX6Moyr83tHGpXms+O3qHPCckH6c4bt6ew8yf
        L3R3d8IV+u4s04NjPqWbznkhkMCS7qDgh3/PJkOLtWMAPNrCQtWgf6kz4tfpfpZSoDcTM
        xXEI61D4sOHbojqfrXFQQia8Yg0JXscHvmyYZn5hN0PWPCsnONwFFIJDsDOxAHXbvNfoy
        jKvze0caleaz47eoc8JyQfpzhu3p7DzJ8vdHd3whX67izTg2M+pZvOeSGQwJLuoOCHf88
        mQ4u1YwA82sJC1aB/qTPi1+l+llKgNxMzFcQjrUPiw4duiOp+tcVBCJrxiDQlex
        """)

        pkt = self.notifier.encode_to_server(iv, timestamp, 0,
                'linux-ix-slave10.build', 'buildbot-start', 'hello!')
        self.assertEqual(
                [ ord(b) for b in exp_pkt ],
                [ ord(b) for b in pkt ])
