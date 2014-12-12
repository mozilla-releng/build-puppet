# http://fedoraproject.org/wiki/Packaging:Python

# This is the 'real' name of the python to build with e.g. python26
%define pyrealname python27
%define pyver 2.7
%define pyrel 3

# This is the top level directory of the python installation we'll use
%define pyhome /tools/%{pyrealname}
%define python %{pyhome}/bin/python%{pyver}
%define git_libexec /tools/git/libexec/git-core

Name:       git-remote-hg
Version:        185852e
Release:        1%{?dist}
Summary:        This is a packaging of %{realname} %{version}-%{release} for Mozilla Release Engineering infrastructure

Group:      mozilla
License:        GPLv2+
URL:            https://github.com/felipec/git-remote-hg
# Use the release from https://github.com/felipec/git/wiki/git-remote-hg
Source0:        https://github.com/felipec/git-remote-hg/tarball/%{version}
# patch from https://github.com/felipec/git-remote-hg/pull/28/commits
Patch0:     https://github.com/fingolfin/git-remote-hg/commit/e716a9e1a9e460a45663694ba4e9e8894a8452b2.patch

BuildRequires:  mozilla-%{pyrealname} mozilla-git
Requires:           mozilla-%{pyrealname} mozilla-git

%description
A copy of git-remote-hg designed to use the mozilla python and git

%prep
# We have the -n because by default, rpmbuild will use %name-%version.
# Because we do %name of 'mozilla-%realname', we need a new default
%setup -q -n felipec-git-remote-hg-%{version}
%patch0 -p1

%build
sed -i -e '1s|#!.*|#! %{python}|' git-remote-hg

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{git_libexec}
cp git-remote-hg $RPM_BUILD_ROOT/%{git_libexec}/git-remote-hg

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(755,root,root,-)
%{git_libexec}/git-remote-hg

%changelog
* Thu Dec 11 2014 Dustin J. Mitchell <dustin mozilla com> 185852e-1
- Bug 1110311: upgrade to latest version, with a atch for hg-3.2.x compat

* Mon Jul 09 2014 Dustin J. Mitchell <dustin mozilla com> fdac7e0-1
- create package
