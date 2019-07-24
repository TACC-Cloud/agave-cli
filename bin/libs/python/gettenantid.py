#!/usr/bin/env python
'''
Retrieve the tenant ID for a given credential store

A bit smarter than simple field retrieval to recover from a null
value in tenantid. This is a temporary hack until we can be sure
AgavePy and Tacc Cloud CLI are using identical data models.
'''
from __future__ import absolute_import
from __future__ import print_function
from urllib.parse import urlparse
import sys
import requests
import os
import json
from future import standard_library
standard_library.install_aliases()


TENANTS_URI = 'https://api.tacc.utexas.edu/tenants/'
AGAVE_CACHE_DIR = os.environ.get('AGAVE_CACHE_DIR',
                                 os.path.expanduser("~/.agave"))
AGAVE_CRED_STORE = 'current'


def main():

    # get baseurl from credential store
    creds = {}
    cred_store = os.path.join(AGAVE_CACHE_DIR, AGAVE_CRED_STORE)

    if len(sys.argv) == 2:
        _cred_store = os.path.join(AGAVE_CACHE_DIR, sys.argv[1])
        if os.path.exists(_cred_store):
            cred_store = _cred_store
        else:
            print("Credential store {} doens't exist".format(_cred_store))
            sys.exit(1)

    if os.path.exists(cred_store):
        try:
            f = open(cred_store, 'r')
            creds = json.load(f)
            f.close
        except Exception as e:
            print("Couldn't read in {}: {}".format(cred_store, e))
            sys.exit(1)
    else:
        print("Couldn't find{}: {}".format(cred_store, e))
        sys.exit(1)

    creds_netloc = urlparse(creds['baseurl'])[1]

    # load from tenants server
    r = requests.get(TENANTS_URI)
    resp = []
    try:
        resp_3 = r.json()
        if 'result' in resp_3:
            resp = resp_3['result']
    except Exception as e:
        print("Error fetching {}: {}".format(TENANTS_URI, e))
        sys.exit(1)

    for item in resp:
        tenant_netloc = urlparse(item['baseUrl'])[1]
        if tenant_netloc == creds_netloc:
            print((item['code']))
            sys.exit(0)

    print("Unable to determine tenant_id")
    sys.exit(1)


if __name__ == '__main__':
    main()
