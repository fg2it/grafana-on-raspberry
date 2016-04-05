# grafana-on-raspberry
[Grafana](http://grafana.org) *unofficial* packages for arm based raspberry pi 2.

Grafana doesn't provide packages for arm, so these packages are here
to allow easy install.

Packages were build on a raspberry pi 2 running raspbian from the Grafana
[source](https://github.com/grafana/grafana). Each directory contains a README.md
file that discribes how packages were build and so, how you can do it yourself
if you are not confortable with unofficial packages. 

I expect the .deb packages work on wheezy and jessie : the only thing I am sure
will fail is feature creating png files from your graph. For this, `grafana`
relies on `PhantomJS` and the binaries included in these .deb won't work on both
wheezy and jessie. Beside this, it should work but I didn't test it.

Grafana [license](https://github.com/grafana/grafana/blob/master/LICENSE.md).
