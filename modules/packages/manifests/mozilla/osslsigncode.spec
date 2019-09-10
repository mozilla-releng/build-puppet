Summary: Tool for Authenticode signing of EXE/CAB files
Name: osslsigncode
Version: 1.7.1
Release: 3moz1
License: GPLv2+
Group: Applications/System
URL: https://github.com/theuni/osslsigncode
Source: https://sourceforge.net/code-snapshots/git/o/os/osslsigncode/osslsigncode.git/osslsigncode-osslsigncode-e72a1937d1a13e87074e4584f012f13e03fc1d64.zip
BuildRoot: %{_tmppath}/%{name}-%{name}-%{version}
BuildRequires: openssl-devel
BuildRequires: curl-devel
BuildRequires: libgsf-devel

%description
Tool for Authenticode signing of EXE/CAB files.

%prep
%setup -n osslsigncode-osslsigncode-e72a1937d1a13e87074e4584f012f13e03fc1d64

%build
./autogen.sh
%configure
%{__make} %{?_smp_mflags}


%install
%{__rm} -rf %{buildroot}
%makeinstall


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/osslsigncode


%changelog
* Fri Aug 30 2019 Chris AtLee <catlee@mozilla.com> 1.7.1-moz0
- Update to 1.7.1 for Mozilla

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

