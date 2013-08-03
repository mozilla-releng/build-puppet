# Generated from highline-1.6.19.gem by gem2rpm -*- rpm-spec -*-
%define rbname highline
%define version 1.6.19
%define release 1

Summary: HighLine is a high-level command-line IO library.
Name: rubygem-%{rbname}

Version: %{version}
Release: %{release}
Group: Development/Ruby
License: Distributable
URL: http://highline.rubyforge.org
Source0: %{rbname}-%{version}.gem
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: ruby 
Requires: rubygems >= 1.3.7
BuildRequires: ruby 
BuildRequires: rubygems >= 1.3.7
BuildArch: noarch
Provides: ruby(Highline) = %{version}

%define gemdir /usr/lib/ruby/gems/1.8
%define gembuilddir %{buildroot}%{gemdir}

%description
A high-level IO library that provides validation, type conversion, and more
for
command-line interfaces. HighLine also includes a complete menu system that
can
crank out anything from simple list selection to complete shells with just
minutes of work.


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
%{gemdir}/gems/highline-1.6.19/.gitignore
%{gemdir}/gems/highline-1.6.19/AUTHORS
%doc %{gemdir}/gems/highline-1.6.19/CHANGELOG
%{gemdir}/gems/highline-1.6.19/COPYING
%doc %{gemdir}/gems/highline-1.6.19/INSTALL
%doc %{gemdir}/gems/highline-1.6.19/LICENSE
%doc %{gemdir}/gems/highline-1.6.19/README.rdoc
%{gemdir}/gems/highline-1.6.19/Rakefile
%doc %{gemdir}/gems/highline-1.6.19/TODO
%{gemdir}/gems/highline-1.6.19/doc/.cvsignore
%{gemdir}/gems/highline-1.6.19/examples/ansi_colors.rb
%{gemdir}/gems/highline-1.6.19/examples/asking_for_arrays.rb
%{gemdir}/gems/highline-1.6.19/examples/basic_usage.rb
%{gemdir}/gems/highline-1.6.19/examples/color_scheme.rb
%{gemdir}/gems/highline-1.6.19/examples/get_character.rb
%{gemdir}/gems/highline-1.6.19/examples/limit.rb
%{gemdir}/gems/highline-1.6.19/examples/menus.rb
%{gemdir}/gems/highline-1.6.19/examples/overwrite.rb
%{gemdir}/gems/highline-1.6.19/examples/page_and_wrap.rb
%{gemdir}/gems/highline-1.6.19/examples/password.rb
%{gemdir}/gems/highline-1.6.19/examples/repeat_entry.rb
%{gemdir}/gems/highline-1.6.19/examples/trapping_eof.rb
%{gemdir}/gems/highline-1.6.19/examples/using_readline.rb
%{gemdir}/gems/highline-1.6.19/highline.gemspec
%{gemdir}/gems/highline-1.6.19/lib/highline.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/color_scheme.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/compatibility.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/import.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/menu.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/question.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/simulate.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/string_extensions.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/style.rb
%{gemdir}/gems/highline-1.6.19/lib/highline/system_extensions.rb
%{gemdir}/gems/highline-1.6.19/setup.rb
%{gemdir}/gems/highline-1.6.19/site/.cvsignore
%{gemdir}/gems/highline-1.6.19/site/highline.css
%{gemdir}/gems/highline-1.6.19/site/images/logo.png
%{gemdir}/gems/highline-1.6.19/site/index.html
%{gemdir}/gems/highline-1.6.19/test/string_methods.rb
%{gemdir}/gems/highline-1.6.19/test/tc_color_scheme.rb
%{gemdir}/gems/highline-1.6.19/test/tc_highline.rb
%{gemdir}/gems/highline-1.6.19/test/tc_import.rb
%{gemdir}/gems/highline-1.6.19/test/tc_menu.rb
%{gemdir}/gems/highline-1.6.19/test/tc_string_extension.rb
%{gemdir}/gems/highline-1.6.19/test/tc_string_highline.rb
%{gemdir}/gems/highline-1.6.19/test/tc_style.rb
%{gemdir}/gems/highline-1.6.19/test/ts_all.rb


%doc %{gemdir}/doc/highline-1.6.19
%{gemdir}/cache/highline-1.6.19.gem
%{gemdir}/specifications/highline-1.6.19.gemspec

%changelog
