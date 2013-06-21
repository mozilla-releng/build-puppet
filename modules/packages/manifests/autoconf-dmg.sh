#! /bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# set up a clean build dir
if test -d build; then
    rm -rf build
fi
mkdir build
BUILD=$PWD/build
cd $BUILD

set -e

curl -LO http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz
tar zxf autoconf-2.13.tar.gz
cd autoconf-2.13
# back in the autoconf-2.13 days, DESTDIR wasn't in the GNU coding standards, so autoconf
# didn't support it.  So we patch in support.
patch -p1 <<'EOF'
--- a/Makefile.in	1999-01-05 05:27:16.000000000 -0800
+++ b/Makefile.in	2013-05-17 08:57:03.000000000 -0700
@@ -137,23 +137,23 @@
	cd testsuite && ${MAKE} AUTOCONF=${bindir}/autoconf $@

 installdirs:
-	$(SHELL) ${srcdir}/mkinstalldirs $(bindir) $(infodir) $(acdatadir)
+	$(SHELL) ${srcdir}/mkinstalldirs $(DESTDIR)/$(bindir) $(DESTDIR)/$(infodir) $(DESTDIR)/$(acdatadir)

 install: all $(M4FILES) acconfig.h installdirs install-info
	for p in $(ASCRIPTS); do \
-	  $(INSTALL_PROGRAM) $$p $(bindir)/`echo $$p|sed '$(transform)'`; \
+	  $(INSTALL_PROGRAM) $$p $(DESTDIR)/$(bindir)/`echo $$p|sed '$(transform)'`; \
	done
	for i in $(M4FROZEN); do \
-	  $(INSTALL_DATA) $$i $(acdatadir)/$$i; \
+	  $(INSTALL_DATA) $$i $(DESTDIR)/$(acdatadir)/$$i; \
	done
	for i in $(M4FILES) acconfig.h; do \
-	  $(INSTALL_DATA) $(srcdir)/$$i $(acdatadir)/$$i; \
+	  $(INSTALL_DATA) $(srcdir)/$$i $(DESTDIR)/$(acdatadir)/$$i; \
	done
	-if test -f autoscan; then \
-	$(INSTALL_PROGRAM) autoscan $(bindir)/`echo autoscan|sed '$(transform)'`; \
+	$(INSTALL_PROGRAM) autoscan $(DESTDIR)/$(bindir)/`echo autoscan|sed '$(transform)'`; \
	for i in acfunctions acheaders acidentifiers acprograms \
	  acmakevars; do \
-	$(INSTALL_DATA) $(srcdir)/$$i $(acdatadir)/$$i; \
+	$(INSTALL_DATA) $(srcdir)/$$i $(DESTDIR)/$(acdatadir)/$$i; \
	done; \
	else :; fi

@@ -161,11 +161,11 @@
 install-info: info installdirs
	if test -f autoconf.info; then \
	  for i in *.info*; do \
-	    $(INSTALL_DATA) $$i $(infodir)/$$i; \
+	    $(INSTALL_DATA) $$i $(DESTDIR)/$(infodir)/$$i; \
	  done; \
	else \
	  for i in $(srcdir)/*.info*; do \
-	    $(INSTALL_DATA) $$i $(infodir)/`echo $$i | sed 's|^$(srcdir)/||'`; \
+	    $(INSTALL_DATA) $$i $(DESTDIR)/$(infodir)/`echo $$i | sed 's|^$(srcdir)/||'`; \
	  done; \
	fi

EOF
./configure --prefix=/usr/local  --program-suffix=213
make
make install DESTDIR=installroot

# make 'autoconf-2.13' equivalent to 'autoconf213'
ln -s /usr/local/bin/autoconf213 installroot/usr/local/bin/autoconf-2.13

find installroot

# -- create-dmg.sh

PACKAGE_MAKER="/Developer/usr/bin/packagemaker"

DIR_TO_PACKAGE=installroot/usr/local/
PACKAGE_BASENAME=autoconf-2.13
PACKAGE_SHORTNAME=autoconf213
INSTALLDIR=/usr/

if [[ -z $DIR_TO_PACKAGE || -z $PACKAGE_BASENAME || -z $PACKAGE_SHORTNAME || -z $INSTALLDIR ]]; then
    echo "Usage: $0 dir-to-package package-base-name package-short-name installdir"
    exit 1
fi
if [[ ! -x $PACKAGE_MAKER ]]; then
    echo "Couldn't find packagemaker"
    exit 1
fi
if [[ ! -d $DIR_TO_PACKAGE ]]; then
    echo "$DIR_TO_PACKAGE doesn't exist or isn't readable"
    exit 1
fi
if [[ -e $PACKAGE_BASENAME.dmg ]]; then
    echo "$PACKAGE_BASENAME.dmg already exists"
    exit 1
fi

DIR_TO_PACKAGE=${DIR_TO_PACKAGE%/}
tmp=`mktemp -d -t magic`

trap "rm -rf $tmp" EXIT

rsync -av $DIR_TO_PACKAGE $tmp
echo $PACKAGE_MAKER -r $tmp -v -i com.mozilla.$PACKAGE_SHORTNAME -o $tmp/$PACKAGE_BASENAME.pkg -l $INSTALLDIR
$PACKAGE_MAKER -r $tmp -v -i com.mozilla.$PACKAGE_SHORTNAME -o $tmp/$PACKAGE_BASENAME.pkg -l $INSTALLDIR
rm -rf $tmp/`basename $DIR_TO_PACKAGE`
echo hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
hdiutil makehybrid -hfs -hfs-volume-name "Mozilla $PACKAGE_BASENAME" -o ./$PACKAGE_BASENAME.dmg $tmp
