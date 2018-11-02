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

config = {
    "current": {
        "client-name": {
            "tenantid": "sd2e",
            "baseurl": "http://localhost:5000",
            "devurl": "",
            "apisecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxx",
            "apikey": "xxxxxxxxxxxxxxxxxxxxxxxxxxx",
            "username": "xxx",
            "access_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            "refresh_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            "created_at": "1541189098",
            "expires_in": 14400,
            "expires_at": "Sat Nov 3 00:04:58 UTC 2018"
        }
    },
    "sessions": {
        "sd2e": {
            "xxx": {
                "client-name": {
                    "tenantid": "sd2e",
                    "baseurl": "http://localhost:5000",
                    "devurl": "",
                    "apisecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxx",
                    "apikey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                    "username": "xxx",
                    "access_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                    "refresh_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                    "created_at": "1541189098",
                    "expires_in": 14400,
                    "expires_at": "Sat Nov 3 00:04:58 UTC 2018"
                }
            }
        }
    }
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

    config["current"]["client-name"]["created_at"] = now
    config["current"]["client-name"]["expires_at"] = time.strftime(
        "%a %b %-d %H:%M:%S %Z %Y", time.localtime(expires_at))

    # Write agavedb.
    agave_path = "{}/current".format(agave_dir)
    with open(agave_path, "w") as f:
        json.dump(agavedb, f)

    # Write config.
    agave_path = "{}/config.json".format(agave_dir)
    with open(agave_path, "w") as f:
        json.dump(config, f, indent=4)
