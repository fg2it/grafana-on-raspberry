# Grafana v3.0.3 release for raspberry pi 2
Build from tag [v3.0.3](https://github.com/grafana/grafana/tree/v3.0.3) with
[this](https://github.com/fg2it/phantomjs-on-raspberry/tree/master/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)
`phantomjs` binary working on raspberry pi 2 running raspbian/jessie.

`go` version was 1.5.2, `nodejs` was 5.10.1, `npm` was 3.8.3  and `phantomjs` was
some version between 2.0.0 and 2.1.0 release
([b483dd6](https://github.com/ariya/phantomjs/tree/b483dd673a1ca589ff10c5f73dfea1e43bfa3225)).

## How ?
Just have a look at the build process for [v3.0-beta3](https://github.com/fg2it/grafana-on-raspberry/tree/master/jessie/v3.0-beta3/README.md).
The only thing to change is the obvious one
```bash
git checkout v3.0.3
```

## See:
- [fpm](https://github.com/jordansissel/fpm)
- [go](http://blog.hypriot.com/post/how-to-compile-go-on-arm/) by hypriot
- [grafana](https://github.com/grafana/grafana/blob/v3.0.3/docs/sources/project/building_from_source.md)
- [nodejs](https://nodejs.org/dist/v5.10.1/node-v5.10.1-linux-armv7l.tar.xz) official binaries
- [phantomjs](https://github.com/fg2it/phantomjs-on-raspberry/blob/master/jessie/b483dd673a1ca589ff10c5f73dfea1e43bfa3225/phantomjs?raw=true) for pi2/jessie
