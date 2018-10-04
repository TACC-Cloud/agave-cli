#!/usr/bin/env python
import errno
import json
import os
import time


agavedb = {
    "tenantid": "sd2e",
    "baseurl": "http://localhost:5000",
    "devurl": "",
    "apisecret": "xxx",
    "apikey": "xxx",
    "username": "xxx",
    "access_token": "ak39dh8sutpa139s018mspzatqw9xx1",
    "refresh_token": "xxx",
    "created_at": "1533215424",
    "expires_in": "14400",
    "expires_at": "Thu Aug 16 12:37:08 CDT 2018"
}


if __name__=="__main__":
    # Agavedb path.
    agave_dir = os.path.expanduser("~/.agave")

    # Make agave directory.
    try:
        os.mkdir(agave_dir, 755)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

    # Update time.
    now = int(time.time())
    expires_at = now + 14400
    agavedb["created_at"] = now
    agavedb["expires_at"] = time.strftime("%a %b %-d %H:%M:%S %Z %Y", time.localtime(expires_at))

    # Write agavedb.
    agave_path = "{}/current".format(agave_dir)
    with open(agave_path, "w") as f:
        json.dump(agavedb, f)
