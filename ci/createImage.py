#!/usr/bin/env python3
import os
import re
import sys

d={}

name = os.getenv("TRAVIS_TAG")
# expect tag(-component)?
#    or commit((-branch)?-component)?
# consider we have the second if commit match [0-9a-f]{6}
# component must be either main, testing or experimental
# eg :
# name = 'a5f7ed-master-main'
# name = 'a5f7ed-master'
# name = 'a5f7ed'
# name = 'v4.0.0-beta1-testing'
# name = 'v4.0.1'

if not name and len(sys.argv)>1 :
    name=sys.argv[1]
else :
    name='master'

version = name
for c in ('main', 'testing', 'experimental'):
    version = re.sub('-{}$'.format(c),'',version)

g = re.search(r'([0-9a-f]{6})(-.+)?',version)
if g:
    d['COMMIT'] = g.group(1)
    d['LABEL'] = g.group(2)[1:]
    d['DEPTH'] = 20
else:
    #we have a tag
    d['LABEL'] = version

buildArg = ' '.join( ['--build-arg {}={}'.format(k,v) for k,v in d.items()] )
cmd =  'docker build {} -t fg2it/grafana-builder -f ci/Dockerfile ci'.format(buildArg)
print( cmd )
os.system( cmd )
