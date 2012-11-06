#!/usr/bin/python

# MOZILLA DEPLOYMENT NOTES
# - This file is distributed to all buildslaves by Puppet, placed at
#   /usr/local/bin/runslave.py on POSIX systems (linux, darwin) and
#   C:\runslave.py on Windows systems
# - It lives in the 'buildslave' puppet module

import time
import sys
import os
import re
import itertools
import binascii
import socket
import struct
import traceback
import subprocess
import textwrap
import urllib2

class RunslaveError(Exception): pass
class NoBasedirError(RunslaveError): pass
class NoBuildbotTacError(RunslaveError): pass

class BuildbotTac:
    def __init__(self, options):
        self.options = options
        self.page = None
        self.basedir = None

    def get_basedir(self):
        """Get the basedir, using (starting with most preferred):
           - cached value (C{self.basedir})
           - C{self.options.basedir}
           - basedir extracted from C{self.page}
           - guess_basedir
        This method either returns a basedir, or raises a NoBasedirError.
        """
        if self.basedir:
            return self.basedir

        if self.options.basedir:
            self.basedir = self.options.basedir
            return self.basedir

        extracted = self.extract_basedir(self.page)
        if extracted:
            self.basedir = extracted
            return self.basedir

        guessed = self.guess_basedir(self.options.slavename)
        if guessed:
            self.basedir = guessed
            return self.basedir

        raise NoBasedirError("Cannot determine basedir for slave %s" % self.options.slavename)

    def ensure_basedir_exists(self):
        '''
        Ensures that the basedir exists
        '''
        basedir = self.get_basedir()
        if not os.path.exists(basedir):
            try:
                os.makedirs(basedir)
            except ValueError:
                print "ERROR: We were not able to create the basedir: %s" % ValueError
                sys.exit(1)

    # When the allocator is up, try to extract the basedir from the resulting
    # .tac file.  Note, however, that it's possible to get tac files which do
    # not contain a basedir, e.g., a disabled slave.  This just returns None
    # in such a case.
    def extract_basedir(self, page):
        if not page:
            return None
        mo = re.search("^basedir\\s*=\\s*([ur]?['\"].*['\"])", page, re.M|re.I)
        if mo:
            basedir_cmd = mo.group(1)
            extracted = eval(basedir_cmd.strip())
            return extracted

    # When the allocator is down, we're on our own to start the buildslave.  The
    # general approach is to try to start the slave at all costs, on the assumption
    # that if we fail then this slave will be detected as hung and will be manually
    # touched. The hard part is remembering where the buildslave's basedir should
    # be.  We can often tell based on the slave name, but barring that we'll just
    # search for a basedir that exists.
    def guess_basedir(self, slavename):
        def slave_matches(*parts):
            "True if any of PARTS appears in options.slavename"
            for part in parts:
                if part in slavename:
                    return True
            return False

        dirs = dict(
            posix_build='/builds/slave',
            windows_build=r'e:\builds\moz2_slave',
            linux_test='/home/cltbld/talos-slave',
            mac_test='/Users/cltbld/talos-slave',
            win_test=r'c:\talos-slave',
            new_win_test=r'c:\slave',
        )

        # first try to guess based on the slave name
        basedir = None
        if slave_matches('slave', 'xserve'):
            if slave_matches('linux', 'darwin', 'mac', 'xserve'):
                basedir = dirs['posix_build']
            elif slave_matches('win', 'w32', 'w64'):
                basedir = dirs['windows_build']
        elif slave_matches('talos', '-try', 'r3'):
            if slave_matches('linux', 'ubuntu', 'fed'):
                basedir = dirs['linux_test']
            elif slave_matches('tiger', 'leopard', 'snow'):
                basedir = dirs['mac_test']
            elif slave_matches('xp', 'w7', 'w764'):
                basedir = dirs['win_test']
        elif slave_matches('-w864-'):
            basedir = dirs['new_win_test']

        # failing that, find a directory that exists
        if not basedir:
            for d in dirs.values():
                if os.path.exists(d):
                    basedir = d
                    break

        if basedir is None:
            print >>sys.stderr, "runslave.py could not guess basedir for %s" % slavename
            sys.exit(1)

        return basedir

    def get_filename(self):
        basedir = self.get_basedir()
        return os.path.join(basedir, "buildbot.tac")

    def download(self):
        url = self.options.allocator_url
        slavename = self.options.slavename
        slavename = slavename.split('.', 1)[0]

        # create a full URL based on the slave name
        full_url = url.replace('SLAVE', slavename)

        try:
            # clear out any cached self.basedir, since we might get a new value
            self.basedir = None

            # set the socket timeout
            socket.setdefaulttimeout(self.options.timeout)

            # download the page
            page_file = urllib2.urlopen(full_url)
            page = self.page = page_file.read()

            # check that it's (likely to be) valid
            if 'AUTOMATICALLY GENERATED - DO NOT MODIFY' not in page:
                print >>sys.stderr, "WARNING: downloaded page did not contain validity-check string"
                return False

            # ensure the basedir exists so we can write the temp file
            self.ensure_basedir_exists()
            # tuck it away in buildbot.tac, safely
            filename = self.get_filename()
            if self.options.verbose:
                print "writing", filename
            tmpfile = '%s.tmp' % filename
            f = open(tmpfile, "w")
            f.write(page)
            f.close()
            # windows can't do a rename over an existing file atomically
            if sys.platform == 'win32':
                if os.path.exists(filename):
                    os.unlink(filename)
            os.rename(tmpfile, filename)
            return True
        except Exception, e:
            # This error message was changed because it did not mention that a failure to replace
            # the file *as well as* failing to fetch the file would be caught here.  This can be
            # triggered by chmod 0 on the build slave directory so this process can't write the tac
            print >>sys.stderr, "WARNING: error fetching and/or replacing buildbot.tac file ", full_url
            # Lets actually print out useful information in the error message
            print >>sys.stderr, "Full exception: %s" % e
            if self.options.verbose:
                traceback.print_exc()
            # oh noes!  No worries, we'll just use the existing .tac file
            return False

    def delete_pidfile(self):
        # based on bug 648665, it looks like it's a better idea to kill the pidfile
        # every time, since our method of restarting slaves tends to leave stale pidfiles
        # around from a previous boot, and thus occasionally fails to start up due to pid
        # collisions
        basedir = self.get_basedir()
        pidfile = os.path.join(basedir, "twistd.pid")
        if os.path.exists(pidfile):
            print >>sys.stderr, "removing old pidfile without checking for a running process"
            try:
                os.unlink(pidfile)
            except:
                print >>sys.stderr, "..removal failed"

    def run(self):
        if not os.path.exists(self.get_filename()):
            raise NoBuildbotTacError("no buildbot.tac found; cannot start")
        self.delete_pidfile()
        rv = subprocess.call(
            self.options.twistd_cmd + 
                    [ '--no_save',
                      '--logfile', os.path.join(self.get_basedir(), 'twistd.log'),
                      '--python', self.get_filename(),
                    ],
            cwd=self.get_basedir())

        # sleep for long enough to let twistd daemonize; otherwise, launchd may
        # spot the partially-daemonized process and kill it as a "stray process
        # with PGID equal to this dead job: <runslave.py's pid>" - see bug
        # 644310
        if rv == 0:
            time.sleep(10)
        sys.exit(rv)

class NSCANotifier(object):
    """
    Class to send notifications to a Nagios server via NSCA.  This *only*
    supports XOR encryption.  This is fairly specific to the releng enviroment.
    """

    monitoring_port = 5667
    svc_description = 'buildbot-start'
    status = 0
    output = 'hello!'

    # map by datacenter (from DNS); default is None
    monitoring_hosts = {
        'scl1': 'admin1.infra.scl1.mozilla.com',
        'sjc1': 'bm-admin01.mozilla.org',
        'mtv1': 'bm-admin01.mozilla.org',
        None: 'bm-admin01.mozilla.org',
    }

    class TimeoutError(Exception): pass

    proto_version = 3
    fromserver_fmt = "!128sL"
    fromserver_fmt_size = struct.calcsize(fromserver_fmt)
    toserver_fmt = "!HxxlLH64s128s514s"
    toserver_fmt_size = struct.calcsize(toserver_fmt)

    def __init__(self, options):
        self.options = options

    # You'll be shocked to learn that the DNS resolver on Windows is broken -
    # it returns the system's own notion of its hostname, rather than
    # performing a DNS query, if the IP matches a configured interface.
    # Luckily, nslookup queries the DNS server directly, so on windows we
    # substitute win_resolve for gethostbyaddr.  See bug #656450 for details.
    name_re = re.compile(r"^Name: *(.*)$")
    def win_resolve(self, ip):
        args = [ 'nslookup', ip ]
        try:
            p = subprocess.Popen(args,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
            out = p.communicate()[0]
        except:
            return None

        # for a reverse lookup, the first "Name:" line contains
        # our target.
        for line in out.split('\r\n'):
            mo = self.name_re.match(line)
            if mo:
                return mo.group(1).strip()

    def nagios_name(self, bare_hostname, verbose=False):
        """
        Calculate the "nagios name" based on the bare hostname.  This is
        done by finding the fully qualified hostname from reverse DNS, and then
        removing .mozilla, .int, .com, and .org.
        """
        try:
            ip = socket.gethostbyname(bare_hostname + '.build.mozilla.org')
            hostname = socket.gethostbyaddr(ip)[0]
        except socket.error:
            if verbose:
                print "could not calculate nagios hostname: %r" % (sys.exc_info()[1],)
            return bare_hostname

        # on win32, gethostbyaddr doesn't work for our own IP, so re-resolve that
        if sys.platform == "win32":
            nslookup_hostname = self.win_resolve(ip)
            if nslookup_hostname:
                hostname = nslookup_hostname

        hostname = hostname.replace('.int', '')
        hostname = hostname.replace('.com', '')
        hostname = hostname.replace('.org', '')
        hostname = hostname.replace('.mozilla', '')
        if verbose:
            print "calculated nagios hostname '%s'" % hostname
        return hostname

    def monitoring_host_from_nagios_name(self, nagios_name, verbose=False):
        dc = None
        if '.' in nagios_name:
            dc = nagios_name.split('.')[-1]
            # might leave 'build'; this will be caught below

        if dc not in self.monitoring_hosts:
            dc = None

        monitoring_host = self.monitoring_hosts[dc]
        if verbose:
            print "reporting to NSCA daemon on '%s'" % monitoring_host

        return monitoring_host

    def decode_from_server(self, bytes):
        iv, timestamp = struct.unpack(self.fromserver_fmt, bytes)
        return iv, timestamp

    def encode_to_server(self, iv, timestamp, return_code, host_name,
                         svc_description, plugin_output):
        # note that this will pad the strings with 0's instead of random digits.  Oh well.
        toserver = [
                self.proto_version,
                0, # crc32_value
                timestamp,
                return_code,
                host_name,
                svc_description,
                plugin_output,
        ]

        # calculate crc32 and insert into the list
        crc32 = binascii.crc32(struct.pack(self.toserver_fmt, *toserver))
        toserver[1] = crc32

        # convert to bytes
        toserver_pkt = struct.pack(self.toserver_fmt, *toserver)

        # and XOR with the IV
        toserver_pkt = ''.join([chr(p^i)
                        for p,i in itertools.izip(
                                itertools.imap(ord, toserver_pkt),
                                itertools.imap(ord, itertools.cycle(iv)))])

        return toserver_pkt

    def do_send_notice(self):
        host_name = self.nagios_name(self.options.slavename, verbose=self.options.verbose)
        monitoring_host = self.monitoring_host_from_nagios_name(host_name,
                                            verbose=self.options.verbose)

        sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sk.connect((monitoring_host, self.monitoring_port))

        # read packet
        buf = ''
        while len(buf) < self.fromserver_fmt_size:
            data = sk.recv(self.fromserver_fmt_size - len(buf))
            if not data:
                break
            buf += data

        # make up reply
        iv, timestamp = self.decode_from_server(buf)
        toserver_pkt = self.encode_to_server(iv, timestamp, 0, host_name,
                self.svc_description, 'runslave.py executed')

        # and send it
        sk.send(toserver_pkt)

    def try_send_notice(self):
        try:
            self.do_send_notice()
        except:
            print >>sys.stderr, "Error sending notice to nagios (ignored)"
            if self.options.verbose:
                traceback.print_exc()

def guess_twistd_cmd():
    if sys.platform == 'win32':
        # first look for a buildbot virtualenv (buildbotve)
        for buildbotve in [
                r'C:\mozilla-build\buildbotve',
                r'D:\mozilla-build\buildbotve',
            ]:
            python_exe = os.path.join(buildbotve, r'scripts\python.exe')
            if os.path.exists(python_exe):
                return [
                    python_exe,
                    os.path.join(buildbotve, r'scripts\twistd.py')
                ]

        # failing that, try the old way, where buildbot was installed in the
        # mozilla-build Python
        for path in [
                r'C:\mozilla-build\python25',
                r'D:\mozilla-build\python25',
                # newer mozilla-build installs in here
                r'C:\mozilla-build\python',
                r'D:\mozilla-build\python',
            ]:
            python_exe = os.path.join(path, 'python.exe')
            if os.path.exists(python_exe):
                return [
                    python_exe,
                    os.path.join(path, r'scripts\twistd.py')
                ]
        raise RuntimeError("Can't find twistd.bat")
    else:
        # All POSIX slaves are consistent about the location.  Woo!
        return [ '/tools/buildbot/bin/twistd' ]

default_allocator_url = "http://slavealloc.build.mozilla.org/gettac/SLAVE"
def main():
    from optparse import OptionParser

    parser = OptionParser(usage=textwrap.dedent("""\
        usage:
            %%prog [--verbose] [--allocator-url URL] [--twistd-cmd CMD]
                        [--basedir BASEDIR] [--slavename SLAVE]
                        [--no-start] [--timeout=TIMEOUT]

        Attempt to download a .tac file from the allocator, or use a locally cached
        version if an error occurs.  The slave name is used to determine the basedir,
        and is calculated from gethostname() if not given on the command line.

        The slave name, if not specified, is determined via gethostname().

        The basedir, if not specified, and the allocator is not available, then
        the basedir is calculated from the slave name; see the code for
        details.

        The allocator URL defaults to
          %(default_allocator_url)s
        The URL will have the string 'SLAVE' replaced with the unqualified
        slavename.  The resulting page should be the plain-text .tac file to be
        written to disk.  It must contain the string
          AUTOMATICALLY GENERATED - DO NOT MODIFY
        (as a safety check that it's valid).

        Once the .tac file is set up, this invokes the twisted given in
        --twistd-cmd; this is calculated based on the slave name if not
        specified.  The twistd daemon is not started if --no-start is
        provided.

    """ % dict(default_allocator_url=default_allocator_url)))
    parser.add_option("-a", "--allocator-url", action="store", dest="allocator_url")
    parser.add_option("-c", "--twistd-cmd", action="store", dest="twistd_cmd")
    parser.add_option("-d", "--basedir", action="store", dest="basedir")
    parser.add_option("-n", "--slavename", action="store", dest="slavename")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose")
    parser.add_option(      "--no-start", action="store_true", dest="no_start")
    parser.add_option(      "--timeout", action="store", dest="timeout", type='int')
    parser.set_defaults(allocator_url=default_allocator_url, timeout=60)

    (options, args) = parser.parse_args()

    # apply some defaults
    if not options.slavename:
        options.slavename = socket.gethostname().split('.')[0]

    # convert twistd_cmd into an args tuple
    if options.twistd_cmd:
        options.twistd_cmd = [ options.twistd_cmd ]
    else:
        options.twistd_cmd = guess_twistd_cmd()

    # set up the .tac file
    try:
        tac = BuildbotTac(options)
        ok = tac.download()
        if not ok:
            print >>sys.stderr, "WARNING: falling back to existing buildbot.tac"

        if not options.no_start:
            notif = NSCANotifier(options)
            notif.try_send_notice()
            tac.run()
    except RunslaveError, error:
        print >>sys.stderr, "FATAL: %s" % str(error)

if __name__ == '__main__':
    main()
