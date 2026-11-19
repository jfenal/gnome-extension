%global uuid gnome@netbird.io
%global extdir %{_datadir}/gnome-shell/extensions/%{uuid}

Name:           gnome-shell-extension-netbird
Version:        5
Release:        1%{?dist}
Summary:        Control the local NetBird daemon from GNOME Quick Settings

License:        GPL-3.0-or-later AND BSD-3-Clause
URL:            https://github.com/netbirdio/gnome-extension
Source0:        %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildArch:      noarch

BuildRequires:  gjs

Requires:       gnome-shell >= 46
# Needs the daemon's HTTP/JSON socket, available from NetBird 0.76.0.
# Fedora ships it as netbird-client; NetBird's own repo as netbird.
Recommends:     (netbird-client >= 0.76.0 or netbird >= 0.76.0)

%description
GNOME Shell extension to control the local NetBird daemon: a Quick Settings
toggle to connect, disconnect and switch profiles, plus a native GTK window
for peers, network resources, exit nodes, profile settings and debug bundles.

It talks to NetBird's local HTTP/JSON Unix socket, which is disabled by
default. Enable it once with:

  sudo netbird service reconfigure --enable-json-socket

%prep
%autosetup -n %{name}-%{version}

%build
# Nothing to build.

%install
install -d %{buildroot}%{extdir}
install -pm 0644 metadata.json extension.js prefs.js %{buildroot}%{extdir}/
cp -pr icons netbird prefs shell %{buildroot}%{extdir}/

%check
gjs -m tests/api.test.js
gjs -m tests/settings-controller.test.js
gjs -m tests/status-controller.test.js
gjs -m tests/status-icons.test.js
gjs -m tests/window-activation.test.js

%files
%license LICENSE LICENSES/NetBird-BSD-3-Clause.txt
%doc README.md
%{extdir}/

%changelog
* Thu Nov 19 2026 Jérôme Fenal <jfenal@redhat.com> - 5-1
- Initial package
