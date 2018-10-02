# http://fedoraproject.org/wiki/Packaging:Python
# We do this to avoid stomping on distro-provided packages
%define realname mercurial
# This is the 'real' name of the python to build with e.g. python26
%define pyrealname python27
%define pyver 2.7

# This is the top level directory of the python installation
# we'll use
%define pyhome /tools/%{pyrealname}

# We also want to install all custom software to alternate locations
%define _prefix /tools/%{pyrealname}-%{realname}
%define _libdir %{_prefix}/lib

# We redefine the standard RPM macros provided by the system
# since they are all wrong for what we want
%define __python %{pyhome}/bin/python%{pyver}
%define __python3 /bin/false
%define python_sitelib %{pyhome}/lib/python%{pyver}/site-packages
%define python_sitearch %{pyhome}/lib/python%{pyver}/site-packages
%define python3_sitelib /does/not/exist
%define python3_sitearch /does/not/exist
%define py3dir /does/not/exist

# We define some things useful for installing the module to an
# alternate prefix
%define package_sitelib %{_libdir}/python%{pyver}/site-packages
%define package_sitearch %{_libdir}/python%{pyver}/site-packages

Name:       mozilla-%{pyrealname}-%{realname}
Version:    3.9.1
Release:	1%{?dist}
Summary:	This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

Group:	    mozilla
License:	GPLv2+
URL:		https://www.mercurial-scm.org/
Source0:	%{realname}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires:  mozilla-%{pyrealname}
Requires:	    mozilla-%{pyrealname}

%description
%{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

%prep
# We have the -n because by default, rpmbuild will use %name-%version.
# Because we do %name of 'mozilla-%realname', we need a new default
%setup -q -n %{realname}-%{version}


%build
export CFLAGS="$RPM_OPT_FLAGS"
export CXXFLAGS="$RPM_OPT_FLAGS"
%{__python} setup.py build


%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install -O1  --prefix=%{_prefix} --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES
mkdir -p $RPM_BUILD_ROOT/%{python_sitelib}
echo %{package_sitelib} > $RPM_BUILD_ROOT/%{python_sitelib}/%{realname}.pth

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


%files -f INSTALLED_FILES
%defattr(-,root,root,-)
%{python_sitelib}/%{realname}.pth
%{_prefix}
/usr/local/bin


%changelog
* Mon Sep 24 2018 Dragos Crisan <dcrisan mozilla com> 4.7.1-1
- update to hg 4.7.1

* Thu Nov 16 2017 Dragos Crisan <dcrisan mozilla com> 4.4.1-1
- update to hg 4.4.1

* Tue Sep 13 2016 Alin Selagea <aselagea mozilla com> 3.9.1-1
- update to hg 3.9.1

* Mon Apr 04 2016 Jake Watkins <jwatkins mozilla com> 3.7.3-1
- update to hg 3.7.3

* Mon Nov 24 2014 Justin Wood <jwood mozilla com> 3.2.1-1
- update to hg 3.2.1 and drop unused pyrel from spec

* Fri Oct 08 2014 Simone Bruno <sbruno mozilla com> 3.1.2-1
- update to hg 3.1.2 and fix pyrel

* Tue Apr 30 2013 Justin Wood <jwood mozilla com> 2.5.4-1
- Update to hg 2.5.4 and fix pyrel

* Mon Jul 09 2012 Dustin J. Mitchell <dustin mozilla com> 2.1.1-4
- add links from /usr/local/bin to all binaries

* Wed Mar 14 2012 John Ford <jhford mozilla com> 2.1.1-3
- install pth files to allow interpreter to import modules

* Tue Mar 13 2012 John Ford <jhford mozilla com> 2.1.1-2
- fix the directory the package is installed to

* Tue Mar 13 2012 John Ford <jhford mozilla com> 2.1.1-1
- initial commit

