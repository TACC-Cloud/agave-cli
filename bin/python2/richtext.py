#!/usr/bin/env python

'''Python >=2.7 utility for converting JSON responses to a rich format'''

from __future__ import absolute_import
from __future__ import print_function

import sys
from six.moves import range
from six.moves import zip

debug = False


def print_table(table):

    zip_table = list(zip(*table))
    widths = [max(len(value) for value in row) for row in zip_table]

    for row in table:
        result = "| "
        for i in range(len(row)):
            result = result + row[i].ljust(widths[i]) + " | "
    print(result)


def main():

    last = ""
    row = []
    data = []

    sys.argv.pop(0)
    sys.argv.append("|")

    for value in sys.argv:
        if (value == "|"):
            if (value == last):
                data.append(row)
                row = []
        else:
            if (last != "|"):
                value = last + " " + value
                row[-1] = value
            else:
                row.append(value)
        last = value

    # Control output format with env variable here
    print_table(data)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print("Error: ".format(e))
