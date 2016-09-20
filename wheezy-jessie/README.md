# Grafana v3.1.1 release for raspberry pi 2 /*wheezy and jessie*
Build from tag [v3.1.1](https://github.com/grafana/grafana/tree/v3.1.1) with
[this](https://github.com/fg2it/phantomjs-on-raspberry/releases/tag/v2.1.1-wheezy-jessie)
`phantomjs` binary working on raspberry pi 2 running raspbian/wheezy or jessie.

`go` version was 1.5.2, `nodejs` was 5.10.1, `npm` was 3.8.3  and `phantomjs`
was [2.1.1](https://github.com/ariya/phantomjs/tree/2.1.1). The build was done
on a jessie based arm docker container, specifically
[resin/armv7hf-debian:jessie](https://hub.docker.com/r/resin/armv7hf-debian/).

## Some Remarks
- Have a look on what I wrote on [`go` and `nodejs`](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v2.6.0#go) for building v2.6.0. This still holds.
- Have a look on what I wrote on [`node-sass`](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v3.0-beta5#node-sass) for buiding v3 beta. This is the reason for the choice of a jessie based distro in this build. Alternately, I could probably have follow what I did to build [grafana v3.1.1 on wheezy](https://github.com/fg2it/grafana-on-raspberry/tree/master/wheezy/v3.1.1#workaround-for-a-c11-compliant-g) to get the needed c++11 compliant g++.
- Since the PhantomJS binary used is now a proper v2.1.1, previous [trick](https://github.com/fg2it/grafana-on-raspberry/blob/master/jessie/v2.6.0#patch-phantomjs) to patch the binary has no [reason](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v2.6.0#phantomjsphantomjs-prebuild-npm-module) to be anymore.  
- Finally, you can read the [reason](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v2.6.0#phantomjsphantomjs-prebuild-npm-module) for the manual install of PhantomJS.


## Instructions
### Install Dependencies
```bash
sudo apt-get update
sudo apt-get install curl git ca-certificates
sudo apt-get install binutils gcc make libc-dev
sudo apt-get install ruby ruby-dev  # for fpm
sudo apt-get install rpm            # for rpmbuild, used indirectly by grafana (call to fpm)
sudo apt-get install libfontconfig1 # for phantomjs v2.1.1
sudo apt-get install python g++     # for node-sass
```
Install go 1.5.2 from hypriot :
```bash
curl -L https://github.com/hypriot/golang-armbuilds/releases/download/v1.5.2/go1.5.2.linux-armv7.tar.gz | sudo tar -xz -C /usr/local
export PATH=/usr/local/go/bin:$PATH
```
Install nodejs :
```bash
curl -L https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz | sudo tar -xJ --strip-components=1 -C /usr/local
```
Install fpm :
```bash
gem install fpm
```
Finally, install your `phantomjs` binary. For example :
```bash
curl -L https://github.com/fg2it/phantomjs-on-raspberry/releases/download/v2.1.1-wheezy-jessie/phantomjs_2.1.1_armhf.deb -o /tmp/phantomjs_2.1.1_armhf.deb
sudo dpkg -i /tmp/phantomjs_2.1.1_armhf.deb
```

### Build Grafana
The good news is that now you just have to follow the official
[instructions](https://github.com/grafana/grafana/blob/v3.0-beta5/docs/sources/project/building_from_source.md)
with just a few modifications.
```bash
export GOPATH=/tmp/graf-build
mkdir -p $GOPATH
cd $GOPATH
go get github.com/grafana/grafana
cd $GOPATH/src/github.com/grafana/grafana
git checkout v3.1.1
go run build.go setup    
$GOPATH/bin/godep restore   
npm install
```

Finally,
```bash
go run build.go build package
```
The packages are in `./dist`

## Install
You simply have to install the dependencies, download the .deb package and install it.
```bash
sudo apt-get install adduser libfontconfig
curl -L https://github.com/fg2it/grafana-on-raspberry/releases/download/v3.1.1-wheezy-jessie/grafana_3.1.1-1472506485_armhf.deb -o /tmp/grafana_3.1.1-1472506485_armhf.deb
sudo dpkg -i /tmp/grafana_3.1.1-1472506485_armhf.deb
```
For additional help, see the [v3.1 official documentation](http://docs.grafana.org/v3.1/).

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [go](http://blog.hypriot.com/post/how-to-compile-go-on-arm/) by hypriot
- [grafana](https://github.com/grafana/grafana/blob/v3.1.1/docs/sources/project/building_from_source.md)
- [nodejs](https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/tree/master/wheezy-jessie/v2.1.1) for pi2/wheezy and jessie
