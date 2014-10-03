Summary:        Test files for signmar
Name:           mozilla-signing-test-files
Version:        1.1
Release:        1
# License is a compulsory field so you have to put something there.
License:        none
Source0:        test.exe
Source1:        test.mar
Source2:        test.tar.gz
Source3:        test.zip
Source4:        test64.exe
BuildArch:      noarch
BuildRoot:      %{_tmppath}/%{name}-build
Group:          mozilla

%description
Test files for signmar

%prep
# nothing

%build
# nothing

%install
base=$RPM_BUILD_ROOT/tools/signing-test-files
mkdir -p $base
install -m 755 %{SOURCE0} $base
install -m 755 %{SOURCE1} $base
install -m 755 %{SOURCE2} $base
install -m 755 %{SOURCE3} $base
install -m 755 %{SOURCE3\4} $base

%post
# nothing

%clean
rm -rf $RPM_BUILD_ROOT
rm -rf %{_tmppath}/%{name}
rm -rf %{_topdir}/BUILD/%{name}

# list files owned by the package here
%files
%defattr(-,root,root)
/tools/signing-test-files/test.exe
/tools/signing-test-files/test64.exe
/tools/signing-test-files/test.mar
/tools/signing-test-files/test.tar.gz
/tools/signing-test-files/test.zip
