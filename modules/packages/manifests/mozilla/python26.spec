%define realname python26
%define pyver 2.6
%define pyrel 7
%define _prefix /tools/%{realname}
# We set lib explicitly to avoid lib64 issues
%define _libdir %{_prefix}/lib

Name:       mozilla-%{realname}
Version:	%{pyver}.%{pyrel}
Release:	5%{?dist}
Summary:	This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

Group:		mozilla
License:	Python
URL:		http://python.org
Source0:	http://python.org/ftp/python/%{pyver}.%{pyrel}/Python-%{pyver}.%{pyrel}.tar.bz2
Patch0:     python-2.6-fix-cgi.patch
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

# Needed to build a full-featured python (copied from python27.spec)
BuildRequires: readline-devel, openssl-devel, gmp-devel
BuildRequires: ncurses-devel, gdbm-devel, zlib-devel, expat-devel
BuildRequires: libGL-devel tk tix gcc-c++ libX11-devel glibc-devel
BuildRequires: bzip2 tar findutils pkgconfig tcl-devel tk-devel
BuildRequires: tix-devel bzip2-devel sqlite-devel
BuildRequires: autoconf
BuildRequires: db4-devel
BuildRequires: libffi-devel
Requires: tcl tk


%description
%{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure


%prep
%setup -q -n Python-%{pyver}.%{pyrel}
%patch0


%build
# Forcing a libdir of with lib instead of lib64 make things
# work properly on x86_64 linux

# We need to specify the runtime library path to avoid loading the
# system python.  Because the resolution is only "libpython.MAJOR.MINOR.so"
# we need to make sure that when the system python has the same MAJOR and
# MINOR numbers that we look in the correct directory.
export LDFLAGS="-Wl,-rpath=%{_libdir}"
%configure --enable-ipv6 --enable-shared --with-system-ffi --with-system-expat
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make altinstall DESTDIR=$RPM_BUILD_ROOT
# This file doesn't seem to respect the _prefix
mkdir -p $RPM_BUILD_ROOT/%{_prefix}/share/man/
# This file needs to writable for stripping
# instead of %_libdir, because we override this value
#chmod +w $RPM_BUILD_ROOT/%{_libdir}/libpython%{pyver}.a

# add a /usr/local/bin link for the versioned python executable
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
ln -s %{_prefix}/bin/python%{pyver} $RPM_BUILD_ROOT/usr/local/bin/python%{pyver}


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%_prefix
/usr/local/bin/python%{pyver}


%changelog
* Tue Jul 10 2012 Dustin J. Mitchell <dustin mozilla com> 2.6.7-5
- only add the versioned python link; others conflict between 2.6 and 2.7

* Tue Jul 10 2012 Dustin J. Mitchell <dustin mozilla com> 2.6.7-4
- add links from /usr/local/bin to all binaries

* Tue Mar 13 2012 John Ford <jhford mozilla com> 2.6.7-3
- change prefix to make link from 2.6.7-2 redundant

* Tue Mar 13 2012 John Ford <jhford mozilla com> 2.6.7-2
- create a link in /tools/ to the real name of the package

* Tue Mar 13 2012 John Ford <jhford mozilla com> 2.6.7-1
- initial commit
