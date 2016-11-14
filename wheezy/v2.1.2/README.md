# Grafana v2.1.2 release for raspberry pi 2 and 3/wheezy
Build from tag [v2.1.2](https://github.com/grafana/grafana/tree/v2.1.2) with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/wheezy/2.0.1-development_as_1.9.8)
`phantomjs` binary working on raspberry pi 2 running raspbian/wheezy.

`go` version was 1.5, `nodejs` was 0.12.7, `npm` was 2.11.3 and `phantomjs` was
2.0.1-dev dressed like 1.9.8.

The packages here can be expected to work on raspbian/jessie too, except for
features relying on `PhantomJS`.

Should you follow the instructions below with the right binary for PhantomJS,
you would end up with a fully functional build.

## Main problems to overcome
- you need a recent version of `nodejs` (>=0.12.0 should be fine; 0.12.7 is).
- you may want to have `phantomjs`. See
[#2683](https://github.com/grafana/grafana/issues/2683) for this issue. Having
the right version of `phantomjs` binary allows a cleaner build and the feature
creating png files from your graph.
- per se, source won't build because of a time out.
You need to modify `requirejs.js`. (The time out was disabled a few commit later).


## Instructions
The good news is you mainly have to follow the official
[instructions](https://github.com/grafana/grafana/blob/v2.1.2/docs/sources/project/building_from_source.md)
with just a few modifications.

```bash
cd
#install gvm
sudo apt-get install bison
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source ~/.gvm/scripts/gvm
gvm install go1.4.2
gvm use go1.4.2
#for go1.5
GOROOT_BOOTSTRAP=~/.gvm/gos/go1.4.2 gvm install go1.5
gvm use go1.5
#install fpm which is used in build.go to create deb and rpm packages
sudo apt-get install ruby-dev
sudo gem install fpm
#install rpm (for rpmbuild) since grafana build.go
#build .deb and .rpm
sudo apt-get install rpm
```

Then you need to install `nodejs` and `phantomjs` (1.9.8). See my other repo for that.
Be careful to install your `phantomjs` binary before the `npm install` step:
npm will try to install `phantomjs` if it doesn't find `phantomjs` version 1.9.8
in your path; unfortunately, because of this [issue](https://github.com/Medium/phantomjs/issues/376),
it will fail to install the right binary.

Now, follow offical instructions up to the `grunt-cli` install:
```bash
gvm use go1.5
mkdir graf-build
cd graf-build/
export GOPATH=$HOME/graf-build
go get github.com/grafana/grafana # run for 8m30
cd $GOPATH/src/github.com/grafana/grafana
git checkout v2.1.2
go run build.go setup             # run for 35s
$GOPATH/bin/godep restore         # run for 70s
npm install                       # run for 6m
sudo npm install -g grunt-cli     # <15s
```

Before building the packages:
```bash
#disable time out for requirejs task
sed -i 's/baseUrl: '\''.\/app'\'',/baseUrl: '\''.\/app'\'',waitSeconds: 0,/' tasks/options/requirejs.js
#overwrite default phantomjs binary
cp `which phantomjs` vendor/phantomjs/phantomjs
#ensure it is stripped
strip vendor/phantomjs/phantomjs
```

Finally:
```bash
go run build.go build package     # 21m
```

Packages are in `$GOPATH/src/github.com/grafana/grafana/dist`.

## Update
Nodejs resumes its [official binaries](https://nodejs.org/dist/) for arm since
v4.0.0. You should probably give it a try.

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [grafana](https://github.com/grafana/grafana/blob/v2.1.2/docs/sources/project/building_from_source.md)
- [gvm](https://github.com/moovweb/gvm)
- nodejs [v0.12.7](https://github.com/fg2it/nodejs-on-raspberry/tree/master/0.12.7) for pi2 and [official binaries](https://nodejs.org/dist/)
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/wheezy/2.0.1-development_as_1.9.8) pseudo v1.9.8 for pi2 (and pi3)/wheezy
