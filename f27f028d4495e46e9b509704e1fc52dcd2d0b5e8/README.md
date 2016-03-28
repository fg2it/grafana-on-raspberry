# Grafana for Raspberry Pi 2
build from [f27f028](https://github.com/grafana/grafana/tree/f27f028d4495e46e9b509704e1fc52dcd2d0b5e8)
commit without any change to source code but with a `phantomjs` binary working on arm.

## Main Problems to Overcome
- you need a recent version of `nodejs`.
- you may want to have `phantomjs`. See
[#2683](https://github.com/grafana/grafana/issues/2683) for this issue. Having
the right version of `phantomjs` binary allows a cleaner build and the feature
creating png files from your graph.

## Instructions
Basically, you only have to follow the official [instructions](http://docs.grafana.org/v2.1/project/building_from_source/).
In short, from a fresh raspbian install:

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
#install fpm
sudo apt-get install ruby-dev
sudo gem install fpm
#install rpm (for rpmbuild) since grafana build.go
#build .deb and .rpm
sudo apt-get install rpm
```
Then you need to install `nodejs` and `phantomjs` (1.9.8). See my other repos for that if your on pi2/raspbian wheezy.

Now, follow offical instructions up to the `grunt-cli` install:

```bash
gvm use go1.5
mkdir graf-build
cd graf-build/
export GOPATH=$HOME/graf-build
go get github.com/grafana/grafana # run for 8m30
cd $GOPATH/src/github.com/grafana/grafana
git checkout f27f028d4495e46e9b509704e1fc52dcd2d0b5e8
go run build.go setup             # run for 35s
$GOPATH/bin/godep restore         # run for 70s
npm install                       # run for 6m
sudo npm install -g grunt-cli     # <15s
```

Before building the packages, put the right `phantomjs` binary in place:
```bash
#overwrite default phantomjs binary
cp `which phantomjs` vendor/phantomjs/phantomjs
#ensure it is stripped
strip vendor/phantomjs/phantomjs
```

Finally
```bash
go run build.go build package     # 21m
```
Packages are in `$GOPATH/src/github.com/grafana/grafana/dist`.

See:
- [gvm](https://github.com/moovweb/gvm)
- [fpm](https://github.com/jordansissel/fpm)
- [grafana](http://docs.grafana.org/v2.1/project/building_from_source/)
