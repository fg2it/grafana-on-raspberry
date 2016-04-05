# Grafana v2.6.0 release for raspberry pi 2
Build from tag [v2.6.0](https://github.com/grafana/grafana/tree/v2.6.0) with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/master/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)
`phantomjs` binary working on raspberry pi 2 running raspbian/jessie.

`go` version was 1.5.2, `nodejs` was 4.4.1, `npm` was 2.14.20 and `phantomjs` was
some version between 2.0.0 and 2.1.0 release
([b483dd6](https://github.com/ariya/phantomjs/tree/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)).

The packages here can be expected to work on raspbian/wheezy too, except for
features relying on `PhantomJS`.

Should you follow the instructions below with the right binary for PhantomJS,
you would end up with a fully functional build.


## Main problems to overcome
### go
Not really a problem, it is more of a comment. You have two easy ways to get v1.5 :
- First, the easy way with [gvm](https://github.com/moovweb/gvm). See [here](https://github.com/fg2it/grafana-on-raspberry/tree/master/wheezy/f27f028d4495e46e9b509704e1fc52dcd2d0b5e8).
- Second, the very easy way with [hypriot](http://blog.hypriot.com/post/how-to-compile-go-on-arm/)
unofficial tarball, which is what I did here. I am not too much in favor of
unofficial build, but hypriot produces a nice and well establish work on arm,
this is a leap of faith I can take. If you can't, hypriot fully explains how to
produce the package yourself. It is a bit more tedious than the `gvm` way, but once
you have the tarball, it is much more easy and efficient to install it.

### nodejs
You need a recent version of `nodejs` (>=0.12.0 should be fine; 0.12.7 is).

Careful here, `npm` (>=3.0.0) changed its way to layout modules and grafana
build rely on this layout at least to find `phantomjs` binary to be included
in the package (see [here](https://github.com/grafana/grafana/blob/v2.6.0/tasks/options/phantomjs.js)
for gory details). 
The following instructions expect the npm v2 layout. You will need to adapt a
few things in the following instructions and probably some grafana source files
(see [here](https://github.com/grafana/grafana/blob/v3.0-beta1/tasks/options/phantomjs.js)).

### phantomjs
You may want to have `phantomjs` since `grafana` relies on it for the feature
creating png files from your graph.

Moreover, having `phantomjs` allows a cleaner build since, otherwise, some tests run at packaging time
will fail. You will have to modify the file `build.go` (look for the arg processing loop in main() and
change `grunt("release")` to `grunt("--force","release")`) to ignore failures.

## Instructions
### Install Dependencies
```bash
sudo apt-get update
sudo apt-get install curl git ca-certificates
sudo apt-get install binutils gcc make libc-dev
sudo apt-get install ruby ruby-dev  # for fpm
sudo apt-get install rpm            # for rpmbuild, used indirectly by grafana (call to fpm)
sudo apt-get install libfontconfig1 libicu52 libjpeg62-turbo  # for my phantomjs binary !
```
Install go 1.5.2 from hypriot :
```bash
curl -L https://github.com/hypriot/golang-armbuilds/releases/download/v1.5.2/go1.5.2.linux-armv7.tar.gz | tar -xz -C /usr/local
export PATH=/usr/local/go/bin:$PATH
```
Install nodejs :
```bash
cd /tmp
curl -L https://nodejs.org/dist/v4.4.1/node-v4.4.1-linux-armv7l.tar.xz | tar xfJ  -                                                       && \
mv -t /usr/local/bin     node-v4.4.1-linux-armv7l/bin/*
mv -t /usr/local/include node-v4.4.1-linux-armv7l/include/*
mv -t /usr/local/lib     node-v4.4.1-linux-armv7l/lib/*
mv -t /usr/local/share   node-v4.4.1-linux-armv7l/share/*
```
Install fpm :
```bash
gem install fpm
```
Finally, install your `phantomjs` binary. For example :
```bash
curl -L https://raw.githubusercontent.com/fg2it/phantomjs-on-raspberry/master/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225/phantomjs_2.0.0_armhf.deb -o /tmp/phantomjs_2.0.0_armhf.deb
sudo dpkg -i /tmp/phantomjs_2.0.0_armhf.deb
```

### Build Grafana
The good news is you mainly have to follow the official
[instructions](https://github.com/grafana/grafana/blob/v2.6.0/docs/sources/project/building_from_source.md)
with just a few modifications.
```bash
export GOPATH=/tmp/graf-build
mkdir -p $GOPATH
cd $GOPATH
go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
git checkout v2.6.0
go run build.go setup    
$GOPATH/bin/godep restore   
npm install
npm install -g grunt-cli
cd $GOPATH/src/github.com/grafana/grafana
```
Now, the fix for `phantomjs`.
```bash
export LOC=./node_modules/karma-phantomjs-launcher/node_modules/phantomjs/lib/location.js
echo "module.exports.location = \"`which phantomjs`\"" > $LOC
echo "module.exports.platform = \"linux\"" >> $LOC
echo "module.exports.arch = \"arm\"" >> $LOC
```
Finally,
```bash
go run build.go build package
```
The packages are in `./dist`

### Some comments
The problem for `phantomjs` is that the npm module `phantomjs` (later renamed
`phantomjs-prebuilt`) won't succeed on arm. It tries to install official binaries
which don't exist for arm. But, it is only an installer and if you provide a
working `phantomjs` binary, you just have to change `location.js` (which reports
the location of the binary to be used). To be specific, you need to create this
file, since on failure, it is not created.

`nodejs` use that file to find the binary, and thus grafana tests will fails. Moreover,
`grafana` also use this file to include a working `phantomjs` binary in its package.

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [grafana](https://github.com/grafana/grafana/blob/v2.6.0/docs/sources/project/building_from_source.md)
- [gvm](https://github.com/moovweb/gvm)
- [nodejs](https://nodejs.org/dist/v4.4.1/node-v4.4.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/blob/master/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225/phantomjs?raw=true) for pi2/jessie
