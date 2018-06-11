#!/usr/bin/python
# pywritejson
#
# A Python >=2.7 command line utility to write a field in a JSON dict
#

from __future__ import absolute_import
from __future__ import print_function
import argparse
import json
import os
import sys
import time

debug = False


def parse_args():
    parser = argparse.ArgumentParser(prog="pywritejson.py",
                                     description="Write a field in a JSON doc")

    parser.add_argument("-d", "--debug",
                        action='store_true', default=False,
                        help="Show debug information")

    parser.add_argument("-f", "--field",
                        dest="field", type=str,
                        nargs='?', default=None,
                        help="Field")

    parser.add_argument("-v", "--value",
                        dest="value", type=str,
                        nargs='?', default=None,
                        help="Value")

    parser.add_argument("-n", "--novalidate",
                        action='store_true',
                        default=False,
                        help="Write field without validating it exists")

    parser.add_argument('input',
                        nargs='?',
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="The JSON file to modify")

    args = parser.parse_args()

    return args


def main():

    global debug

    args = parse_args()
    assert args.field is not None, "--field cannot be empty"
    assert args.value is not None, "--value cannot be empty"
    assert args.input is not None, "must provide a filename"
    debug = args.debug

    raw = args.input.read()
    json_dict = json.loads(raw)
    if args.novalidate is False:
        assert args.field in list(json_dict.keys()), \
            "{} not in file. Not setting its value".format(args.field)
    json_dict[args.field] = args.value
    # backup original
    original = args.input.name
    backup = original + '.' + str(int(time.time()))
    os.rename(original, backup)
    # write new value
    try:
        f = open(original, 'w')
        f.write(json.dumps(json_dict, indent=2, sort_keys=True))
        f.close()
        os.remove(backup)
    except Exception as e:
        print("Failed to set field '{}'' in '{}': {}".format(
            args.field, original, e))
        os.rename(backup, original)
        return False
        pass

    return True


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print("Error: {}".format(e))
