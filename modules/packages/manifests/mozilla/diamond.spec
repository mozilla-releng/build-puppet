%define name diamond
%define version 3.4.266
%define release 0

Summary: Smart data producer for graphite graphing package
Name: %{name}
Version: %{version}
Release: %{release}
# note that pypi does not have every version of diamond; build this from an sdist tarball if necessary
Source0: http://pypi.python.org/packages/source/d/diamond/%{name}-%{version}.tar.gz
Patch0: limit-network-collector-stats.diff
License: MIT License
Group: Development/Libraries
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Prefix: %{_prefix}
BuildArch: noarch
Vendor: The Diamond Team <https://github.com/BrightcoveOS/Diamond>
Requires: python-configobj
Url: https://github.com/BrightcoveOS/Diamond

%description
UNKNOWN

%prep
%setup -n %{name}-%{version}
%patch0 -p1

%build
python setup.py build

%install
%{__python} setup.py install -O1 --root=$RPM_BUILD_ROOT --record=INSTALLED_FILES

%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib(1))")}
%endif


%clean
rm -rf $RPM_BUILD_ROOT

%post


%preun


%files -f INSTALLED_FILES
%defattr(-,root,root)
