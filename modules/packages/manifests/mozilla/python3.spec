%define realname python36
%define pyver 3.6
%define pyrel 5
%define _prefix /tools/%{realname}
# We set lib explicitly to avoid lib64 issues
%define _libdir %{_prefix}/lib

Name:       mozilla-%{realname}
Version:        %{pyver}.%{pyrel}
Release:        2%{?dist}
Summary:        This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

Group:          mozilla
License:        Python
URL:            https://python.org
Source0:        https://python.org/ftp/python/%{pyver}.%{pyrel}/Python-%{pyver}.%{pyrel}.tar.xz
# this cgi patch avoids pulling in a /usr/local/bin/python dependency
Patch0:         python-2.6-fix-cgi.patch
BuildRoot:      %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

# Needed to build a full-featured python
BuildRequires: readline-devel, openssl-devel, gmp-devel
BuildRequires: ncurses-devel, gdbm-devel, zlib-devel, expat-devel
BuildRequires: libGL-devel tk tix gcc-c++ libX11-devel glibc-devel
BuildRequires: bzip2 tar findutils pkgconfig
BuildRequires: tix-devel bzip2-devel sqlite-devel
BuildRequires: autoconf
BuildRequires: db4-devel
BuildRequires: libffi-devel
BuildRequires: xz-devel

%description
%{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

%prep
%setup -q -n Python-%{pyver}.%{pyrel}
%patch0


%build
# We need to specify the runtime library path to avoid loading the
# system python.  Because the resolution is only "libpython.MAJOR.MINOR.so"
# we need to make sure that when the system python has the same MAJOR and
# MINOR numbers that we look in the correct directory.
export LDFLAGS="-Wl,-rpath=%{_libdir}"

# Forcing a libdir of with lib instead of lib64 make things
# work properly on x86_64 linux
%configure --enable-ipv6 --enable-shared --with-system-ffi --with-system-expat
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make altinstall DESTDIR=$RPM_BUILD_ROOT

# add /usr/local/bin links
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
set -x
ln -s %{_prefix}/bin/python%{pyver} $RPM_BUILD_ROOT/usr/local/bin/python%{pyver}
ln -s %{_prefix}/bin/python%{pyver} $RPM_BUILD_ROOT%{_prefix}/bin/python

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%dir %_prefix
%_prefix/*
/usr/local/bin/python%{pyver}
%doc /usr/share/man/man1/python3.6.1.gz

%changelog
* Mon Sep 24 2018 Aki Sasaki <aki mozilla com> 3.6.5-2
- add lzma support
* Fri Apr 13 2018 Ben Hearsum <bhearsum mozilla com> 3.6.5-1
- initial commit, copied from py35
