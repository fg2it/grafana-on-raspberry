# grafana-on-raspberry [![Release](https://img.shields.io/github/release/fg2it/grafana-on-raspberry.svg)](https://github.com/fg2it/grafana-on-raspberry/releases/latest)
[Grafana](http://grafana.org) *unofficial* packages for arm based raspberry pi 2.

Grafana doesn't provide packages for arm, so these packages are here
to allow easy install.

Packages were build on a raspberry pi 2 running raspbian from the Grafana
[source](https://github.com/grafana/grafana). Each directory contains a README.md
file that discribes how packages were build and so, how you can do it yourself
if you are not confortable with unofficial packages.

## `wheezy/` and `jessie/`
The .deb packages in `wheezy/` and `jessie/` subfolder should essentially work
on both wheezy and jessie distro, but at least one feature won't : creating png
files from your graph. For this, `grafana` relies on `PhantomJS` and the
binaries included in these .deb won't work on both wheezy and jessie. Beside
this, it should work but I didn't test it.

## `wheezy-jessie/`
The `wheezy-jessie/` folder contains packages that do not have the aforementioned
problem. They use a different PhantomJS build, which works fine on both distro.

## `docker/`
The `docker/` folder contains `Dockerfile` and related files to build images
running grafana for armhf.



Grafana [license](https://github.com/grafana/grafana/blob/master/LICENSE.md).
