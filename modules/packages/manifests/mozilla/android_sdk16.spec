#### NOTE: canonical copy is at
####       http://hg.mozilla.org/build/rpm-sources/raw-file/tip/android-sdk/centos5-i686/android-sdk16.spec

%define debug_package %{nil}
%define upstream_name android-sdk
%define upstream_ver r16
%define install_dir_name %{upstream_name}-%{upstream_ver}
Name: android-sdk16
Summary: An interpreted, interactive, object-oriented programming language.
Version: %{upstream_ver}
Release: 0moz1
License: ???
Group: Java
# This isn't the original source package but rather a Mozilla-built tarball.
#
# The original source package comes from Google and has to be un-tar'd and
# a GUI tool run to then install the proper SDK platforms.
#
# Full instructions for prepping the tarball can be found here:
# https://wiki.mozilla.org/ReleaseEngineering/How_To/Build_An_Android_SDK_rpm
#
Source0: %{upstream_name}_%{upstream_ver}-linux.tgz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
AutoReqProv: no

%define __os_install_post %{nil}
%define __strip /bin/true

%description
%{name}

%prep
%setup -q -n %{upstream_name}-linux

%build
chmod -R a+rX *

%install
rm -fr $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/tools/%{install_dir_name}
cp -a * $RPM_BUILD_ROOT/tools/%{install_dir_name}

%clean
rm -fr $RPM_BUILD_ROOT

%files
%defattr(-, root, root)
/tools/%{install_dir_name}
