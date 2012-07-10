# We do this to avoid stomping on distro-provided packages
%define realname git
# We also want to install all custom software to alternate locations
%define _prefix /tools/%{realname}

Name:       mozilla-%{realname}
Version:    1.7.9.4
Release:    3%{?dist}
Summary:    This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

Group:      mozilla
License:    GPLv2
URL:        http://git-scm.com/
Source0:    http://git-core.googlecode.com/files/%{realname}-%{version}.tar.gz
BuildRoot:  %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)


# For CentOS 5X, this is curl-devel but we don't care in this spec file
BuildRequires:  libcurl-devel
BuildRequires:  expat-devel
BuildRequires:  gettext
BuildRequires:  pcre-devel
BuildRequires:  openssl-devel
BuildRequires:  zlib-devel >= 1.2
BuildRequires:  perl-ExtUtils-MakeMaker

Requires:       less
Requires:       openssh-clients
Requires:       rsync
Requires:       zlib >= 1.2


%description
%{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

%prep
# We have the -n because by default, rpmbuild will use %name-%version.
# Because we do %name of 'mozilla-%realname', we need a new default
%setup -q -n %{realname}-%{version}


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
# We don't want to bring in too many dependencies
# and these aren't useful on a CI slave
rm -rf $RPM_BUILD_ROOT/%{_datadir}/git-gui
rm -rf $RPM_BUILD_ROOT/%{_datadir}/gitk
rm -rf $RPM_BUILD_ROOT/%{_datadir}/gitweb

# add /usr/local/bin links
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
(
    cd $RPM_BUILD_ROOT/%{_prefix}/bin/
    for f in *; do
        ln -s %{_prefix}/bin/$f $RPM_BUILD_ROOT/usr/local/bin
    done
)

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
%_prefix
/usr/local/bin

%changelog
* Mon Jul 09 2012 Dustin J. Mitchell <dustin mozilla com> 1.7.9.4-3
- add links from /usr/local/bin to all binaries

* Tue Mar 13 2012 John Ford <jhford mozilla com> - 1.7.9.4-2
- remove link from 1.7.9.4-2 and remove version from prefix

* Tue Mar 13 2012 John Ford <jhford mozilla com> - 1.7.9.4-2
- create a link in /tools/ to the real name of the package

* Tue Mar 13 2012 John Ford <jhford mozilla com> - 1.7.9.4-1
- initial specfile
