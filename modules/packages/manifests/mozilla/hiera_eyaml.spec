# Generated from hiera-eyaml-1.1.4.gem by gem2rpm -*- rpm-spec -*-
%define rbname hiera-eyaml
%define version 1.1.4
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
%{_bindir}/regem.sh
%{gemdir}/gems/hiera-eyaml-1.1.4/.gitignore
%{gemdir}/gems/hiera-eyaml-1.1.4/Gemfile
%{gemdir}/gems/hiera-eyaml-1.1.4/Gemfile.lock
%{gemdir}/gems/hiera-eyaml-1.1.4/LICENSE.txt
%{gemdir}/gems/hiera-eyaml-1.1.4/README.md
%{gemdir}/gems/hiera-eyaml-1.1.4/Rakefile
%{gemdir}/gems/hiera-eyaml-1.1.4/bin/eyaml
%{gemdir}/gems/hiera-eyaml-1.1.4/bin/regem.sh
%{gemdir}/gems/hiera-eyaml-1.1.4/hiera-eyaml.gemspec
%{gemdir}/gems/hiera-eyaml-1.1.4/keys/.keepme
%{gemdir}/gems/hiera-eyaml-1.1.4/lib/hiera/backend/eyaml_backend.rb
%{gemdir}/gems/hiera-eyaml-1.1.4/lib/hiera/backend/version.rb


%doc %{gemdir}/doc/hiera-eyaml-1.1.4
%{gemdir}/cache/hiera-eyaml-1.1.4.gem
%{gemdir}/specifications/hiera-eyaml-1.1.4.gemspec

%changelog
