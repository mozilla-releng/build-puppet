# Generated from trollop-2.0.gem by gem2rpm -*- rpm-spec -*-
%define rbname trollop
%define version 2.0
%define release 1

Summary: Trollop is a commandline option parser for Ruby that just gets out of your way.
Name: rubygem-%{rbname}

Version: %{version}
Release: %{release}
Group: Development/Ruby
License: Distributable
URL: http://trollop.rubyforge.org
Source0: %{rbname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: ruby 
Requires: rubygems >= 1.3.7
BuildRequires: ruby 
BuildRequires: rubygems >= 1.3.7
BuildArch: noarch
Provides: ruby(Trollop) = %{version}

%define gemdir /usr/lib/ruby/gems/1.8
%define gembuilddir %{buildroot}%{gemdir}

%description
Trollop is a commandline option parser for Ruby that just
gets out of your way. One line of code per option is all you need to write.
For that, you get a nice automatically-generated help page, robust option
parsing, command subcompletion, and sensible defaults for everything you don't
specify.


%prep
%setup -T -c

%build

%install
%{__rm} -rf %{buildroot}
mkdir -p %{gembuilddir}
gem install --local --install-dir %{gembuilddir} --force %{SOURCE0}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{gemdir}/gems/trollop-2.0/lib/trollop.rb
%{gemdir}/gems/trollop-2.0/test/test_trollop.rb
%{gemdir}/gems/trollop-2.0/FAQ.txt
%{gemdir}/gems/trollop-2.0/History.txt
%{gemdir}/gems/trollop-2.0/release-script.txt
%{gemdir}/gems/trollop-2.0/README.txt


%doc %{gemdir}/doc/trollop-2.0
%{gemdir}/cache/trollop-2.0.gem
%{gemdir}/specifications/trollop-2.0.gemspec

%changelog
