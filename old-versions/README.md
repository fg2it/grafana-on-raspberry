# Notes on building previous version of [Grafana](http://grafana.org) for arm based raspberry pi 2 and pi 3.


Grafana doesn't provide packages for arm, so these notes are here to explain how
you can build Grafana. The main focus is to try to use the exact
[source](https://github.com/grafana/grafana) from Grafana.

Each directory contains a README.md file that discribes how you can build
grafana, depending on the version and your plateform target.

If you are not interested in building Grafana your self, have a look to the
[release](https://github.com/fg2it/grafana-on-raspberry/releases) section.
See also the wiki for install from a deb repo.

## `wheezy/` and `jessie/`
The notes in `wheezy/` and `jessie/` subdirectories should essentially work on
both wheezy and jessie distro, but at least one feature won't : creating png
files from your graph. For this, `grafana` relies on `PhantomJS` and the
binaries I used won't work on both wheezy and jessie. Beside this, it should
work but I didn't test it.

## `wheezy-jessie/`
The `wheezy-jessie/` directory contains notes that do not have the aforementioned
problem. They use a different PhantomJS build, which works fine on both distro.


Grafana [license](https://github.com/grafana/grafana/blob/master/LICENSE.md).
