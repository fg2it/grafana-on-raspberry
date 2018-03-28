#!/usr/bin/env python3
import argparse
import os
import re
import sys

version = sys.argv[1]
if version[0]=='v':
    version=version[1:]

d={'GRAFANA_VERSION' : version}

buildArg = ' '.join( ['--build-arg {}={}'.format(k,v) for k,v in d.items()] )
cmd =  'docker build {} -t fg2it/fgbw:all -f ci/Dockerfile ci'.format(buildArg)
print( cmd )
os.system( cmd )
  