# Grafana v2.6.0 release for raspberry pi 2 and 3/wheezy
Build from tag [v2.6.0](https://github.com/grafana/grafana/tree/v2.6.0) with with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/wheezy/2.0.1-development)
`phantomjs` binary working on raspberry pi 2 running raspbian/wheezy.

`go` version was 1.5.2, `nodejs` was 4.4.1, `npm` was 2.14.20 and `phantomjs` was
2.0.1-dev.

The packages here can be expected to work on raspbian/jessie too, except for
features relying on `PhantomJS`. (see [here](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v2.6.0) for jessie)


## Do it your self

Packages were built following the same [instructions](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v2.6.0)
than for jessie with minimal changes.

### Dependencies
Due to a different `phantomjs` binary, you should have instead of the last `apt-get`:
```bash
sudo apt-get install libfontconfig1 libicu48 libjpeg8 libpng12-0
```
(to be specific, these are the dependencies for my binary).
To install `phantomjs`, can you use my binary :
```bash
curl -L https://github.com/fg2it/phantomjs-on-raspberry/raw/fe240a6831b943be813e01eef897045963cb54bc/wheezy/2.0.1-development/phantomjs_2.0.1-development_armhf.deb -o /tmp/phantomjs_2.0.1-development_armhf.deb
sudo dpkg -i phantomjs_2.0.1-development_armhf.deb
```

The remaining (other dependencies, patch of phantomjs and grafana build) is unchanged.

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [go](http://blog.hypriot.com/post/how-to-compile-go-on-arm/) by hypriot
- [grafana](https://github.com/grafana/grafana/blob/v2.6.0/docs/sources/project/building_from_source.md)
- [gvm](https://github.com/moovweb/gvm)
- [nodejs](https://nodejs.org/dist/v4.4.1/node-v4.4.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/tree/fe240a6831b943be813e01eef897045963cb54bc/wheezy/2.0.1-development) for pi2 (and pi3)/wheezy
