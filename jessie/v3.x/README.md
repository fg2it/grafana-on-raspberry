# Grafana v3.x release for raspberry pi 2 and 3/jessie
> Here v3.x stands for any of [v3.0-beta5](https://github.com/grafana/grafana/tree/v3.0-beta5),
[v3.0.2](https://github.com/grafana/grafana/tree/v3.0.2),
[v3.0.3](https://github.com/grafana/grafana/tree/v3.0.3),
[v3.0.4](https://github.com/grafana/grafana/tree/v3.0.4),
[v3.1.0-beta1](https://github.com/grafana/grafana/tree/v3.1.0-beta1),
[v3.1.0](https://github.com/grafana/grafana/tree/v3.1.0),
[v3.1.1](https://github.com/grafana/grafana/tree/v3.1.1)

> This note presents how I build v3.x. For download, see the
>[release](https://github.com/fg2it/grafana-on-raspberry/releases) section. For install, see the [wiki](https://github.com/fg2it/grafana-on-raspberry/wiki).


Build from the corresponding tag of [grafana](https://github.com/grafana/grafana) github repo with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)
`phantomjs` binary working on raspberry pi 2 running raspbian/jessie.

`go` version was 1.5.2, `nodejs` was 5.10.1, `npm` was 3.8.3  and `phantomjs` was
some version between 2.0.0 and 2.1.0 release
([b483dd6](https://github.com/ariya/phantomjs/tree/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)).

## Main problems to overcome
Most of what I said for [v2.6.0](https://github.com/fg2it/grafana-on-raspberry/blob/master/jessie/v2.6.0/README.md)
still hold. But there are a few new things.

### Phantomjs
The expected version of Phantomjs by the npm module phantomjs-prebuild is now 2.1.1.
Once your phantomjs binary have this version, no other changes are required for this part.
So no additional step to finish the install of the npm module.

### node-sass
As stated in [Grafana 3.0 Beta Released blog post](http://grafana.org/blog/2016/03/31/grafana-3-0-beta-released.html)
the UI moved from bootstrap to a custom sets of sass foundation.

With this change, comes the use of
[node-sass](https://github.com/sass/node-sass) npm module, which is a node
binding to [libsass](https://github.com/sass/libsass).

Unfortunately for your raspberry pi, no official binaries are available, which
means your pi will have to build it itself. It takes some time but everything
works flawlessly during the `npm install` step, provided you have `python` and
`g++` installed.

An hidden dependency for this build to succeed, is that your `g++` is c++11
compliant. Not a problem on jessie, but it is on wheezy. So for wheezy, you will
need to import `g++` from jessie.

## Instructions
### Install Dependencies
```bash
sudo apt-get update
sudo apt-get install curl git ca-certificates
sudo apt-get install binutils gcc make libc-dev
sudo apt-get install ruby ruby-dev  # for fpm
sudo apt-get install rpm            # for rpmbuild, used indirectly by grafana (call to fpm)
sudo apt-get install libfontconfig1 libicu52 libjpeg62-turbo libpng12-0 # for my phantomjs binary !
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
curl -L https://github.com/fg2it/phantomjs-on-raspberry/raw/fe240a6831b943be813e01eef897045963cb54bc/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225/phantomjs_2.0.0_armhf.deb -o /tmp/phantomjs_2.0.0_armhf.deb
sudo dpkg -i /tmp/phantomjs_2.0.0_armhf.deb
```

### Patch PhantomJS
Here is a way to patch your PhantomJS binary:
```bash
export PHJSOFFSET=$(grep -aboF `phantomjs -v` `which phantomjs`|cut -d':' -f1)
printf "2.1.1\00" | sudo dd of=`which phantomjs` obs=1 seek=${PHJSOFFSET} conv=notrunc
```
Be aware, this is not a specially robust way for at least 2 reasons :
- we expect to find only one match of the version string, and accordingly we use the offset of the first match.
- we expect the original string to be at least as long as the new one.

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
git checkout v3.0-beta5 #change v3.0-beta5 with the wanted v3.x tag
go run build.go setup    
$GOPATH/bin/godep restore   
npm install
```

Finally,
```bash
go run build.go build package
```
The packages are in `./dist`


## See:
- [fpm](https://github.com/jordansissel/fpm)
- [go](http://blog.hypriot.com/post/how-to-compile-go-on-arm/) by hypriot
- grafana [v3.0-beta5](https://github.com/grafana/grafana/blob/v3.0-beta5/docs/sources/project/building_from_source.md) offical build instructions (they are the same for all v3.x tags)
- [nodejs](https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225) for pi2 (and pi3)/jessie
