#!/usr/bin/env python3
import argparse
import json
import pprint
import requests
import yaml

def trigger(branch,cfg,token,message='',verbose=False):
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Travis-API-Version': '3',
        'Authorization': 'token {}'.format(token),
    }
    if message != '':
        message = '({})'.format(message)

    data = {
        "request" : {
          "message": "custom build {}".format(message),
          "branch" : branch,
          "config" : cfg
        }
    }
    serialized = json.dumps(data,indent=2)
    if verbose:
        print(serialized)
    response = requests.post('https://api.travis-ci.org/repo/fg2it%2Fgrafana-on-raspberry/requests',
                             headers=headers, data=serialized)
    print(response.status_code)
    if verbose:
        try:
            pprint.PrettyPrinter(indent=2).pprint(response.json())
        except ValueError:
            print(response.text)

if __name__ == "__main__" :
    parser = argparse.ArgumentParser(description="Trigger travis ci from yml")
    parser.add_argument("-b",
                        help="branch of git repo",
                        default="master"
    )
    parser.add_argument("-c",
                        help="yml configuration file",
                        default=".travis.yml"
    )
    parser.add_argument("-m",
                        help="travis message",
                        default="")
    parser.add_argument("-t",
                        help="travis token"
    )
    parser.add_argument("-v",
                        help="verbose",
                        action='store_true'
    )
    args = parser.parse_args()
    if args.v:
        print("Requesting build:\n"
              "  on        {}\n"
              "  using     {}\n"
              "  (message) {}\n"
              "  (token)   {}".format(args.m,args.c,args.m,args.t))
    cfg = yaml.load( open(args.c) )
    trigger(args.b, cfg, args.t, message=args.m, verbose=args.v)
