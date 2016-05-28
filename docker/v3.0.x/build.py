#!/usr/bin/env python
import argparse
import subprocess

version = {
    '3.0.4' : '1464202710',
    '3.0.3' : '1464034780',
    '3.0.2' : '1463517851',
}


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description="Run 'docker build' to create Grafana images")
    parser.add_argument('-g','--grafana', choices=version, default=sorted(version)[-1], help="grafana version to use")
    args= parser.parse_args()
    
    v, s = args.grafana,version[args.grafana]
    print "GRAFANA_VERSION: {0}-{1}\nDOCKER TAG: {0}".format(v, s)

    subprocess.call(['docker',
                     'build',
                     '--build-arg', 'GRAFANA_VERSION='+v,
                     '--build-arg', 'GRAFANA_STAMP='+s,
                     '--tag', 'fg2it/grafana-armhf:v{}'.format(v),
                     '.'])
