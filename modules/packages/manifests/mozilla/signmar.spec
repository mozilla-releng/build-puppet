Summary:        signmar tool from mozilla-central
Name:           signmar
Version:        19.0
Release:        1%{?dist}
URL:            http://www.mozilla.org/projects/firefox/
License:        MPLv1.1 or GPLv2+ or LGPLv2+
Group:          mozilla
Source0:        https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/%{version}/source/firefox-%{version}.source.tar.bz2
# this may need to be different if you're building from a nightly
%define tarballdir mozilla-release

BuildRequires: zip gtk2 gtk2-devel glib dbus dbus-devel dbus-glib-devel yasm libXt-devel mesa-libGL-devel curl-devel alsa-lib-devel

%description

This is the signmar tool, used to sign Mozilla Archives.

%prep
%setup -q -c

%build
cd %{tarballdir}

cat <<EOF >.mozconfig
ac_add_options --enable-build-app=none
ac_add_options --without-system-ply
ac_add_options --without-system-libxul
ac_add_options --without-system-libevent
ac_add_options --without-system-nspr
ac_add_options --without-system-nss
ac_add_options --without-system-jpeg
ac_add_options --without-system-zlib
ac_add_options --without-system-bz2
ac_add_options --without-system-png
ac_add_options --disable-system-hunspell
ac_add_options --disable-system-ffi
ac_add_options --without-system-libvpx
ac_add_options --disable-system-sqlite
ac_add_options --disable-system-cairo
ac_add_options --disable-system-pixman
# any of these cause the build to fail
#ac_add_options --disable-crashreporter
#ac_add_options --disable-webm
#ac_add_options --disable-ogg
ac_add_options --disable-wave
ac_add_options --enable-signmar
EOF

make -f client.mk

%install
cd %{tarballdir}/obj-*

install -dm 755 $RPM_BUILD_ROOT%{_bindir}
install -m 755 dist/bin/signmar $RPM_BUILD_ROOT%{_bindir}/signmar

# rpm should figure out the deps from ldd on signmar

%files
%defattr(-,root,root,-)
%{_bindir}/signmar
