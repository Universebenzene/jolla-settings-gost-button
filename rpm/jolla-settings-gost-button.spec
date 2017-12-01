Name:       jolla-settings-gost-button

# >> macros
BuildArch: noarch
# << macros

Summary:    Settings plugin adding gost control button
Version:    0.1.3
Release:    1
Group:      Qt/Qt
License:    TODO
Source0:    %{name}-%{version}.tar.bz2
Requires:   gost
Requires:   pdnsd
Requires:   cutes-js
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.3.0

%description
Settings plugin adding gost control button


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
mkdir -p %{buildroot}/usr/bin
cp -r settings/*.sh %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/jolla-settings/pages/gost
cp -r settings/*.qml %{buildroot}/usr/share/jolla-settings/pages/gost
cp -r settings/*.js %{buildroot}/usr/share/jolla-settings/pages/gost
cp -r settings/*.py %{buildroot}/usr/share/jolla-settings/pages/gost
mkdir -p %{buildroot}/usr/share/jolla-settings/entries
cp -r settings/*.json %{buildroot}/usr/share/jolla-settings/entries
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.0/icons/
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.5-large/icons/
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.25/icons/
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.5/icons/
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.75/icons/
mkdir -p %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z2.0/icons/
cp -r icons/64x64/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.0/icons/
cp -r icons/72x72/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.5-large/icons/
cp -r icons/80x80/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.25/icons/
cp -r icons/96x96/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.5/icons/
cp -r icons/112x112/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z1.75/icons/
cp -r icons/128x128/*.png %{buildroot}/usr/share/themes/sailfish-default/meegotouch/z2.0/icons/
# << install pre

# >> install post
# << install post

%files
%defattr(-,root,root,-)
%attr(0755, root, root) %{_bindir}/*
%{_datadir}/jolla-settings/entries
%{_datadir}/jolla-settings/pages
%{_datadir}/themes/sailfish-default/meegotouch/z1.0/icons/*.png
%{_datadir}/themes/sailfish-default/meegotouch/z1.25/icons/*.png
%{_datadir}/themes/sailfish-default/meegotouch/z1.5/icons/*.png
%{_datadir}/themes/sailfish-default/meegotouch/z1.5-large/icons/*.png
%{_datadir}/themes/sailfish-default/meegotouch/z1.75/icons/*.png
%{_datadir}/themes/sailfish-default/meegotouch/z2.0/icons/*.png

# >> files
# << files
