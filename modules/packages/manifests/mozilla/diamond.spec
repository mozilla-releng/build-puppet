%define name diamond
%define version 3.4.266
%define unmangled_version 3.4.266
%define release 0

Summary: Smart data producer for graphite graphing package
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{unmangled_version}.tar.gz
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
%setup -n %{name}-%{unmangled_version}

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
