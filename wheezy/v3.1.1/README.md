# Grafana v3.1.1 release for raspberry pi 2
Build from tag [v3.1.1](https://github.com/grafana/grafana/tree/v3.1.1) with with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/master/wheezy/2.0.1-development)
`phantomjs` binary working on raspberry pi 2 running raspbian/wheezy.

`go` version was 1.5.2, `nodejs` was 5.10.1, `npm` was 3.8.3 and `phantomjs` was
2.0.1-dev.

The packages here can be expected to work on raspbian/jessie too, except for
features relying on `PhantomJS`. (see [here](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v3.1.1) for jessie)


## Do it yourself

Since my previous build for wheezy, there have been some changes in and around grafana.
These are rather easy to deal with on jessie, but for wheezy this requires a nasty workaround that should certainly be discouraged if you intend to keep your system in good shape.

### Phantomjs
The expected version of Phantomjs by the npm module phantomjs-prebuild is now 2.1.1.
Once your phantomjs binary have this version, no other changes are required for this part.
So no additional step to finish the install of the npm module. 

### node-sass
This is the nasty part on wheezy

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
### Workaround for a c++11 compliant g++
Once again, I don't advice to do this on a system you want to use. The best way is probably to do it inside a docker container (like I did, by the way).
Add jessie to your sources
```bash
sudo echo 'deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi' >> /etc/apt/sources.list
```
Set how sources should be used
```bash 
sudo cat << PREF > /etc/apt/preferences
Package: *
Pin: release n=wheezy
Pin-Priority: 900
Package: *
Pin: release n=jessie
Pin-Priority: 300
Package: *
Pin: release o=Raspbian
Pin-Priority: -10
PREF
```

### Install dependencies from wheezy
```bash
sudo apt-get update
sudo apt-get install -t wheezy curl git ca-certificates
sudo apt-get install -t wheezy rpm  # for rpmbuild, used indirectly by grafana (call to fpm)
sudo apt-get install -t wheezy libfontconfig1 libicu48 libjpeg8 libpng12-0 # for my phantomjs binary
```

### Install dependencies from jessie
```bash
sudo apt-get install -y -t jessie binutils gcc make libc-dev python g++ # for node-sass
sudo apt-get install -y -t jessie ruby ruby-dev # for fpm
```

### Install go 1.5.2 from hypriot
```bash
curl -L https://github.com/hypriot/golang-armbuilds/releases/download/v1.5.2/go1.5.2.linux-armv7.tar.gz | sudo tar -xz -C /usr/local
export PATH=/usr/local/go/bin:$PATH
```

### Install nodejs
```bash
curl -L https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz | sudo tar -xJ --strip-components=1 -C /usr/local
```

### Install fpm
```bash
gem install fpm
```

### Install Phantomjs
```bash
curl -L https://raw.githubusercontent.com/fg2it/phantomjs-on-raspberry/master/wheezy/2.0.1-development/phantomjs_2.0.1-development_armhf.deb -o /tmp/phantomjs_2.0.1-development_armhf.deb
sudo dpkg -i phantomjs_2.0.1-development_armhf.deb
```
Patch the binary to have pretend it is version 2.1.1
```bash
export PHJSOFFSET=$(grep -aboF `phantomjs -v` `which phantomjs`|cut -d':' -f1)
printf "2.1.1\00" | sudo dd of=`which phantomjs` obs=1 seek=${PHJSOFFSET} conv=notrunc
```

### Build Grafana
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
go run build.go build package
```
The packages are in `./dist`


## Installing the package
```bash
sudo apt-get install libfontconfig libicu48 libjpeg8 libpng12-0
curl -o /tmp/grafana.deb -L https://github.com/fg2it/grafana-on-raspberry/releases/download/v3.1.1-wheezy/grafana_3.1.1-1472241752_armhf.deb
sudo dpkg -i /tmp/grafana.deb
```

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [go](http://blog.hypriot.com/post/how-to-compile-go-on-arm/) by hypriot
- [grafana](https://github.com/grafana/grafana/blob/v3.1.1/docs/sources/project/building_from_source.md)
- [nodejs](https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/tree/master/wheezy/2.0.1-development) for pi2/wheezy
