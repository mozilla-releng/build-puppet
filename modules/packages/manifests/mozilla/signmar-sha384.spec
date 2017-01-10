%define realname firefox
%define debug_package %{nil}
# Do not strip the binaries, it breaks patchelf
%define __spec_install_post %{nil}
# Do not generate debug RPMs
%define __os_install_post %{_dbpath}/brp-compress

Summary:        signmar tool from Firefox (SHA384)
Name:           signmar-sha384
Version:        53.0a1
Release:        1%{?dist}
URL:            http://www.mozilla.org/projects/firefox/
License:        MPLv2.0
Group:          mozilla
Source0:        https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/%{version}/source/%{realname}-%{version}.source.tar.xz
# The following patch has to be applied explicitly, because we need to deploy
# signmar changes to the signing servers before we can land it to
# mozilla-central
Patch0:         signmar-sha384.diff

BuildRequires: zip yasm patchelf freetype-devel libpng-devel libXrender-devel
BuildRequires: autoconf213 libXext-devel libXinerama-devel libXi-devel libXrandr-devel
BuildRequires: libXcursor-devel libXcomposite-devel libXdamage-devel gtk2-devel libXt-devel
BuildRequires: mozilla-python27

%description
This is the signmar tool (SHA384 version), used to sign Mozilla Archives.

%prep
%setup -q -n %{realname}-%{version}
%patch0 -p1
# Fetch required GCC, rustc, GTK3
taskcluster/docker/recipes/tooltool.py fetch --unpack -m browser/config/tooltool-manifests/linux64/releng.manifest

# HACK: to make the build work properly, I had to copy gtk3/usr/local contents
# to /usr/local, because the pc files use absolute references to the headers
# and libraries. This is why the mozconfig below references /usr/local. None of
# the GTK3 libraries are required by signmar, they are just required by the
# build system.

%build

cat <<EOF >.mozconfig
CC="\$topsrcdir/gcc/bin/gcc"
CXX="\$topsrcdir/gcc/bin/g++"
LDFLAGS="-L/usr/local/lib \${LDFLAGS}"
STRIP_FLAGS="--strip-debug"
mk_add_options PATH="\$topsrcdir/gcc/bin:\$topsrcdir/rustc/bin:\$PATH"
mk_add_options "export PANGO_LIBDIR=/usr/local/lib"

ac_add_options --enable-signmar
ac_add_options --enable-verify-mar
ac_add_options --enable-stdcxx-compat

ac_add_options --disable-crashreporter
ac_add_options --disable-elf-hack
ac_add_options --disable-printing
ac_add_options --disable-system-sqlite
ac_add_options --disable-tests
ac_add_options --without-system-bz2
ac_add_options --without-system-nspr
ac_add_options --without-system-nss
ac_add_options --without-system-zlib
EOF

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib64/pkgconfig
rm -rf obj-*
python2.7 mach build

%install
install -dm 755 $RPM_BUILD_ROOT/tools/%{name}/{bin,lib}

cd obj-*
install -m 755 dist/bin/signmar $RPM_BUILD_ROOT/tools/%{name}/bin
install -m 755 dist/bin/{libmozsqlite3,libnspr4,libnss3,libnssutil3,libplc4,libplds4,libsmime3,libssl3}.so \
    $RPM_BUILD_ROOT/tools/%{name}/lib

# Use our shared libraries, not the system wide installed ones
patchelf --set-rpath /tools/%{name}/lib $RPM_BUILD_ROOT/tools/%{name}/bin/signmar

%files
%defattr(-,root,root,-)
/tools/%{name}
