#!/usr/bin/env python

'''
usage: rendertemplate.py --variables file.ini template output

override or pass additional variables by exporting to ENV or
setting them on the command line

var1=value var2=value rendertemplate.py ...
'''

from __future__ import absolute_import
from __future__ import print_function

import argparse
import configparser


def parse_args():
    '''Parse command line arguments'''
    parser = argparse.ArgumentParser(prog="readvalfromini.py",
                                     description="Fetch value of 'field' from 'section' in an .ini file")

    parser.add_argument("-d", "--debug",
                        action='store_true', default=False,
                        help="Show debugging information")

    parser.add_argument("-E", "--variables",
                        type=str,
                        default=None,
                        help="Variables file (ini format)")

    parser.add_argument("--section",
                        type=str,
                        nargs='?',
                        default=None,
                        dest="sectionname",
                        help="Section name")

    parser.add_argument("--field",
                        type=str,
                        default=None,
                        dest="fieldname",
                        help="Field name")

    parser.add_argument("--no-empty",
                        action='store_true',
                        dest="noempty",
                        default=False,
                        help="Error on missing section, field, or value")

    args = parser.parse_args()
    return args


def main():

    global debug

    args = parse_args()
    debug = args.debug
    return_value = None

    config = configparser.ConfigParser()
    config.read(args.variables)

    ini_section = args.sectionname
    ini_field = args.fieldname

    if ini_section not in config.sections():
        if args.noempty:
            raise KeyError("Section {} not present in file".format(
                ini_section))
        else:
            ini_section = 'DEFAULT'

    try:
        return_value = config.get(ini_section, ini_field)
    except Exception:
        if args.noempty:
            raise KeyError("Can't access field {}".format(ini_field))
        else:
            return_value = ""

    print(return_value)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print("Error: {}".format(e))
