%define rbname hiera-eyaml
%define version 2.0.0
%define release 1

Summary: OpenSSL Encryption backend for Hiera
Name: rubygem-%{rbname}

Version: %{version}
Release: %{release}
Group: Mozilla
License: MIT
URL: http://github.com/TomPoulton/hiera-eyaml
Source0: %{rbname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: ruby 
Requires: rubygems >= 1.3.7
Requires: rubygem-trollop >= 2.0
Requires: rubygem-highline >= 1.6.19
BuildRequires: ruby 
BuildRequires: rubygems >= 1.3.7
BuildArch: noarch
Provides: ruby(Hiera-eyaml) = %{version}

%define gemdir /usr/lib/ruby/gems/1.8
%define gembuilddir %{buildroot}%{gemdir}

%description
Hiera backend for decrypting encrypted yaml properties


%prep
%setup -T -c

%build

%install
%{__rm} -rf %{buildroot}
mkdir -p %{gembuilddir}
gem install --local --install-dir %{gembuilddir} --force %{SOURCE0}
mkdir -p %{buildroot}/%{_bindir}
mv %{gembuilddir}/bin/* %{buildroot}/%{_bindir}
rmdir %{gembuilddir}/bin

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{_bindir}/eyaml
%{gemdir}/gems/hiera-eyaml-%{version}


%doc %{gemdir}/doc/hiera-eyaml-%{version}
%{gemdir}/cache/hiera-eyaml-%{version}.gem
%{gemdir}/specifications/hiera-eyaml-%{version}.gemspec

%changelog

* Tue Dec 17 2013 Dustin J. Mitchell <dustin@mozilla.com> 2.0.0
- Update to 2.0.0
