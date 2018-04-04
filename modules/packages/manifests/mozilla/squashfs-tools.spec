%define realname squashfs-tools
%define squashfsver 4.3


Summary: Utility for the creation of squashfs filesystems
Name: mozilla-%{realname}
Version: %{squashfsver}
Release: 0.21.gitaae0aff4%{?dist}
Summary:	This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

License: GPLv2+
Group: mozilla
URL: http://squashfs.sourceforge.net/
# [RedHat] For now, using a prerelease version obtained by:
# git clone git://git.kernel.org/pub/scm/fs/squashfs/squashfs-tools.git
# cd squashfs-tools
# git archive --format=tar --prefix=squashfs4.3/ aae0aff4f0b3081bd1dfc058c867033a89c11aac | gzip > squashfs4.3.tar.gz
Source0: squashfs%{version}.tar.gz
#Source0: http://downloads.sourceforge.net/squashfs/squashfs%{version}.tar.gz
# manpages from http://ftp.debian.org/debian/pool/main/s/squashfs-tools/squashfs-tools_4.2+20121212-1.debian.tar.xz
Source1: mksquashfs.1
Source2: unsquashfs.1
Patch1: squashfs-tools-file_size-fix.patch
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: zlib-devel
BuildRequires: xz-devel
BuildRequires: lzo-devel
BuildRequires: libattr-devel

%description
%{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

%prep
%setup -q -n squashfs%{version}
%patch1 -p1 -b .file_size

%build
pushd squashfs-tools
CFLAGS="%{optflags}" XZ_SUPPORT=1 LZO_SUPPORT=1 LZMA_XZ_SUPPORT=1 make %{?_smp_mflags}

%install
mkdir -p %{buildroot}%{_sbindir} %{buildroot}%{_mandir}/man1
install -m 755 squashfs-tools/mksquashfs %{buildroot}%{_sbindir}/mksquashfs
install -m 755 squashfs-tools/unsquashfs %{buildroot}%{_sbindir}/unsquashfs
install -m 644 %{SOURCE1} %{buildroot}%{_mandir}/man1/mksquashfs.1
install -m 644 %{SOURCE2} %{buildroot}%{_mandir}/man1/unsquashfs.1

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
# Until there is a real release only READ is available
#%doc README ACKNOWLEDGEMENTS DONATIONS PERFORMANCE.README README-4.2 CHANGES pseudo-file.example COPYING
%doc README
%{_mandir}/man1/*

%{_sbindir}/mksquashfs
%{_sbindir}/unsquashfs

%changelog
* Thu Mar 29 2018 Johan Lorenzo <jlorenzo+rpm@m.c> 4.3-0.21.gitaae0aff4
- initial commit, copied from CentOS 7 RPM.
