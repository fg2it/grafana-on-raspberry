#!/usr/bin/env python3
import argparse
import collections
import datetime
import subprocess
import sys
import yaml

release_def = 'stretch'
deb_releases = ["jessie","stretch"]
cfg_file = 'grafana.yaml'
cfg = yaml.load( open(cfg_file ) )


def extract_def(h):
    if type(h) is list :
        tag_def   = h[0]
        stamp_def = h[1]
    else:
        tag_def  = h
        stamp_def = ''
    return tag_def, stamp_def

def setup(git_tag,stamp,release, c_dict):
    if git_tag in c_dict and not stamp:
        stamp=c_dict[git_tag]

    docker_tag=git_tag.replace('-testing','')

    pkg_name=docker_tag[1:]
    if stamp and 'beta' in pkg_name:
        pkg_name=pkg_name.replace('beta',str(stamp)+'beta')
    elif stamp:
        pkg_name="{}-{}".format(pkg_name,stamp)

    if release != release_def :
        docker_tag="{}-{}".format(docker_tag,release)

    return docker_tag, pkg_name

def build(git_tag,docker_tag,pkg_name,release):
    build_date = datetime.datetime.utcnow().isoformat('T')+'Z'
    vcs_ref = subprocess.getoutput('git rev-parse --short HEAD')
    subprocess.call(
        ["docker", "build",
         "--pull",
         "--build-arg", "RELEASE={}".format(release),
         "--build-arg", "REPO_TAG={}".format(git_tag),
         "--build-arg", "PKG_NAME={}".format(pkg_name),
         "--build-arg", "BUILD_DATE={}".format(build_date),
         "--build-arg", "VCS_REF={}".format(vcs_ref),
         "--tag", "fg2it/grafana-armhf:{}".format(docker_tag),
         "."
        ],
        stderr=subprocess.STDOUT,
        universal_newlines=True,
        bufsize=0
    )

def test(docker_tag):
    subprocess.call(
        ["docker", "run", "-ti", "--rm",
         "--name=testgrafana{}".format(docker_tag),
         "-p", "9999:3000",
         "fg2it/grafana-armhf:{}".format(docker_tag)
         ],
         stderr=subprocess.STDOUT,
         universal_newlines=True,
         bufsize=0,
    )

def push(docker_tag):
    subprocess.call(["docker", "login"],
         stderr=subprocess.STDOUT,
         universal_newlines=True,
         bufsize=0
    )

    subprocess.call(["docker", "push",
                     "fg2it/grafana-armhf:{}".format(docker_tag)
                    ],
                    stderr=subprocess.STDOUT,
                    universal_newlines=True,
                    bufsize=0
    )


if __name__ == "__main__" :
    cfg_dict = collections.OrderedDict(
        map(extract_def, cfg)
        )
    tag_def, stamp_def = next(iter( cfg_dict.items() )) #extract_def(cfg[0])

    parser = argparse.ArgumentParser(description="Build grafana docker images for armhf")
    parser.add_argument("-d",
                        help="show default",
                        action='store_true'
                         )
    parser.add_argument("-t",
                        help="create & run docker container",
                        action='store_true'
                         )
    parser.add_argument("-p",
                        help="push images to dockerhub",
                        action='store_true'
                         )
    parser.add_argument("-r", "--release",
                        help="debian release to use for base image",
                        default=release_def,
                        choices=deb_releases
                         )
    parser.add_argument('git_tag', nargs='?', default=tag_def)
    parser.add_argument('timestamp', nargs='?', default=stamp_def)
    args = parser.parse_args()
#    print(args)
#    print(list(cfg_dict.keys()))
    if args.git_tag not in cfg_dict:
        print("\n** Warning: unknown gitub tag ({}) **\n".format(args.git_tag))

    docker_tag, pkg_name = setup(args.git_tag, args.timestamp, args.release, cfg_dict)

    if args.d:
        print("""git tag   : {}
grafana   : {}
docker tag: {}
dist      : {}""".format(args.git_tag,
                        pkg_name,
                        docker_tag,
                        args.release)
        )
        sys.exit(0)

    if not (args.t or args.p or args.d):
        build(args.git_tag,docker_tag, pkg_name, args.release)
    if args.t:
        test(docker_tag)
    if args.p:
        push(docker_tag)
