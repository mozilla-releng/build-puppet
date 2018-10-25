Summary: Tool for Authenticode signing of EXE/CAB files
Name: osslsigncode
Version: 1.7.1
Release: 2%{?dist}
License: GPLv2+
Group: Applications/System
URL: http://sourceforge.net/projects/osslsigncode/
Source: http://downloads.sf.net/osslsigncode/osslsigncode-%{version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: openssl-devel
BuildRequires: curl-devel
BuildRequires: libgsf-devel

%description
Tool for Authenticode signing of EXE/CAB files.


%prep
%setup -q


%build
%{__aclocal}
%{__automake}
%configure
%{__make} %{?_smp_mflags}


%install
%{__rm} -rf %{buildroot}
# make install DESTDIR doesn't work (home made Makefile.in)
%makeinstall


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/osslsigncode


%changelog
* Tue Dec  8 2009 Matthias Saou <http://freshrpms.net/> 1.3.1-1
- Update to 1.3.1.

* Fri Aug 21 2009 Tomas Mraz <tmraz@redhat.com> - 1.3-3
- rebuilt with new openssl

* Sat Jul 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Feb 25 2009 Matthias Saou <http://freshrpms.net/> 1.3-1
- Update to 1.3.
- Remove now included hashfix patch.

* Sat Jan 17 2009 Tomas Mraz <tmraz@redhat.com> - 1.2-5
- rebuild with new openssl

* Tue Feb 19 2008 Fedora Release Engineering <rel-eng@fedoraproject.org> - 1.2-4
- Autorebuild for GCC 4.3

* Wed Dec 05 2007 Release Engineering <rel-eng at fedoraproject dot org> - 1.2-3
 - Rebuild for deps

* Mon Aug 27 2007 Matthias Saou <http://freshrpms.net/> 1.2-2
- Update License field.

* Tue Jan 30 2007 Matthias Saou <http://freshrpms.net/> 1.2-1
- Initial RPM release.

