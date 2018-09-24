# [2018-09-21] NOTE from jlorenzo: The original file comes from https://github.com/jmacd/xdelta/issues/224#issuecomment-355830395
#
# I couldn't get the devtoolset repo to work, so I ended up manually downloading all deps
# from http://mirror.centos.org/centos/6.10/sclo/x86_64/rh/devtoolset-3/.
#
# Moreover, for an unknown reason, `rpmbuild -ba xdelta.spec` was always failing because
# *all* deps were not installed (even though they really were). I had to comment out all
# BuildRequires entries.
#
# There was a tiny bug in this file, too. I swapped `make DESTDIR=%RPM_BUILD_ROOT install` to `make DESTDIR=$RPM_BUILD_ROOT install`.
#
# Finally, I built the package within the docker image "centos:centos6" (which is
# "CentOS release 6.10 (Final)"). This image couldn't start on my regular Linux host
# (there was some crash due to systemd). I worked around it by running docker within a
# Ubuntu 16.04 VM. 

# ORIGINAL NOTE: This spec file was written on on CentOS 6 for EL6-based distros.
# If building on an EL6-based distro, you need EPEL and CERN's devtoolset:
# https://fedoraproject.org/wiki/EPEL
# http://linuxsoft.cern.ch/cern/devtoolset/slc6-devtoolset.repo
# http://linuxsoft.cern.ch/cern/scl/RPM-GPG-KEY-cern
#
# On other distros, comment out the BuildRequires from those distros then
# uncomment their corresponding "generic" BuildRequires. Also remember to
# comment/uncomment the appropriate lines in %%build .

Name:		xdelta3
Summary:	Compare binary files and produce deltas
License:	APLv2
URL:		https://github.com/jmacd/xdelta
Group:		System/Utilities
Version:	3.1.0
Release:	1%{dist}

BuildRequires:	libtool
BuildRequires:	xz
BuildRequires:	xz-lzma-compat
BuildRequires:	xz-devel
#BuildRequires:	gcc >= 4.8.0
#BuildRequires:	gcc-c++ >= 4.8.0
BuildRequires:	automake
BuildRequires:	autoconf >= 2.68

# From EPEL:
BuildRequires:	autoconf268
# From CERN:
BuildRequires:	devtoolset-3-gcc
BuildRequires:	devtoolset-3-gcc-c++
BuildRequires:	devtoolset-3-toolchain

Source0:	https://github.com/jmacd/xdelta/archive/v%{version}.tar.gz

%description
%{name} can be used to compare binary files and produce compressed deltas
containing the changes.

%prep
%setup -q -n xdelta-%{version}/%{name}

%build
#autoreconf -fvi
autoreconf268 -fvi
%configure \
	--enable-debug-symbols \
	--with-liblzma
make

%install
rm -rf $RPM_BUILD_ROOT

make DESTDIR=$RPM_BUILD_ROOT install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
%doc README.md COPYING
%{_bindir}/*
%{_mandir}/*/*

%changelog
* Sat Jan 06 2018 Anonymous Coward - 3.1.0-1
- Initial RPM
