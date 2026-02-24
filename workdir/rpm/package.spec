#
# spec file for package nginx
#
# Copyright (c) 2024 Fei Yang <io@feiyang.eu.org>
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

Name:           nginx
Version:        1.0.0
Release:        0
Summary:        A HTTP server and IMAP/POP3 proxy server
License:        BSD-2-Clause
Group:          Productivity/Networking/Web/Proxy
URL:            https://nginx.org
Provides:       httpd

%description
nginx [engine x] is a HTTP server and IMAP/POP3 proxy server written by Igor Sysoev.
It has been running on many heavily loaded Russian sites for more than two years.

%setup

%install
echo "/usr/bin/printf '$(sed ':a;N;$!ba;s/\n/\\n/g' ../../../conf/%{name}.sysusers)' | /usr/bin/systemd-sysusers --replace=%{_prefix}/lib/sysusers.d/%{name}.conf -" > %{name}.pre

install -Dm644 ../../../conf/%{name}.service %{buildroot}%{_prefix}/lib/systemd/system/%{name}.service
install -Dm644 ../../../conf/%{name}.sysusers %{buildroot}%{_prefix}/lib/sysusers.d/%{name}.conf
%make_install -C ..
install -dm750 %{buildroot}%{_localstatedir}/lib/%{name}
install -dm750 %{buildroot}%{_localstatedir}/log/%{name}

%pre -f %{name}.pre

%files
%{_sbindir}/%{name}
%{_prefix}/lib/systemd/system/%{name}.service
%{_prefix}/lib/sysusers.d/%{name}.conf
%dir %{_prefix}/html
%{_prefix}/html/50x.html
%{_prefix}/html/index.html
%dir %{_sysconfdir}/%{name}
%config %{_sysconfdir}/%{name}/fastcgi.conf.default
%config %{_sysconfdir}/%{name}/fastcgi_params.default
%config %{_sysconfdir}/%{name}/mime.types.default
%config %{_sysconfdir}/%{name}/nginx.conf.default
%config %{_sysconfdir}/%{name}/scgi_params.default
%config %{_sysconfdir}/%{name}/uwsgi_params.default
%config(noreplace) %{_sysconfdir}/%{name}/fastcgi.conf
%config(noreplace) %{_sysconfdir}/%{name}/fastcgi_params
%config(noreplace) %{_sysconfdir}/%{name}/koi-utf
%config(noreplace) %{_sysconfdir}/%{name}/koi-win
%config(noreplace) %{_sysconfdir}/%{name}/mime.types
%config(noreplace) %{_sysconfdir}/%{name}/nginx.conf
%config(noreplace) %{_sysconfdir}/%{name}/scgi_params
%config(noreplace) %{_sysconfdir}/%{name}/uwsgi_params
%config(noreplace) %{_sysconfdir}/%{name}/win-utf
%dir %attr(750, nginx, nginx) %{_localstatedir}/lib/%{name}
%dir %attr(750, nginx, nginx) %{_localstatedir}/log/%{name}
