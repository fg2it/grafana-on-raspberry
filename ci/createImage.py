#!/usr/bin/env python3
import argparse
import os
import re
import sys

d={'GRAFANA_VERSION' : sys.argv[1]}


buildArg = ' '.join( ['--build-arg {}={}'.format(k,v) for k,v in d.items()] )
cmd =  'docker build {} -t fg2it/grafana-fast-builder -f ci/Dockerfile ci'.format(buildArg)
print( cmd )
os.system( cmd )
  