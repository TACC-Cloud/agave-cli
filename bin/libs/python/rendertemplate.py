#!/usr/bin/env python

'''
usage: rendertemplate.py --variables file.ini --env "key=value"
       (--env "key=value"...) template output

override or pass additional variables by exporting to ENV or
setting them on the command line

var1=value var2=value rendertemplate.py ...
'''

from __future__ import absolute_import
from __future__ import print_function

from builtins import str
import argparse
import datetime
import os
import re
import sys
import time
import configparser

from agavepy.agave import Agave

debug = False

# this should be its own module
def get_date_time_facts():
    '''Return a dictonary of handy date and time values'''
    # Lifted from ansible/module_utils/facts/system/date_time.py
    facts_dict = {}
    date_time_facts = {}

    now = datetime.datetime.now()
    date_time_facts['year'] = now.strftime('%Y')
    date_time_facts['month'] = now.strftime('%m')
    date_time_facts['weekday'] = now.strftime('%A')
    date_time_facts['weekday_number'] = now.strftime('%w')
    date_time_facts['weeknumber'] = now.strftime('%W')
    date_time_facts['day'] = now.strftime('%d')
    date_time_facts['hour'] = now.strftime('%H')
    date_time_facts['minute'] = now.strftime('%M')
    date_time_facts['second'] = now.strftime('%S')
    date_time_facts['epoch'] = now.strftime('%s')
    if date_time_facts['epoch'] == '' or date_time_facts['epoch'][0] == '%':
        date_time_facts['epoch'] = str(int(time.time()))
    date_time_facts['date'] = now.strftime('%Y-%m-%d')
    date_time_facts['time'] = now.strftime('%H:%M:%S')
    date_time_facts['iso8601_micro'] = now.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
    date_time_facts['iso8601'] = now.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    date_time_facts['iso8601_basic'] = now.strftime("%Y%m%dT%H%M%S%f")
    date_time_facts['iso8601_basic_short'] = now.strftime("%Y%m%dT%H%M%S")
    date_time_facts['tz'] = time.strftime("%Z")
    date_time_facts['tz_offset'] = time.strftime("%z")

    facts_dict['date_time'] = date_time_facts
    return facts_dict


def expand(sourcedict, namespace=None):
    '''Expande a 1-level dict into level.key form'''
    flat_dict = {}
    for k in list(sourcedict.keys()):
        flat_dict['.'.join([namespace, k])] = sourcedict[k]
    return flat_dict


def flatten(sourcedict, replacelevel=None):
    '''Flatten a 2-level dict into level.key form'''
    flat_dict = {}
    for l in list(sourcedict.keys()):
        level = l
        if replacelevel is not None:
            level = replacelevel
        for k in list(sourcedict[l].keys()):
            flat_dict['.'.join([level, k])] = sourcedict[l][k]
    return flat_dict


def get_agave_vars(ag):
    '''Return a dict of essential Agave-related facts'''
    agave_dict = {'username': 'taco',
                  'full_name': 'TACO Bot',
                  'def_public_storagesystem': '',
                  'def_public_executionsystem': '',
                  'def_private_executionsystem': '',
                  'def_private_storagesystem': ''}
    try:
        # user profile
        profile = ag.profiles.get()
        for k in ('username', 'email'):
            agave_dict[k] = profile.get(k, '')
        agave_dict['full_name'] = "{} {}".format(
            profile.get('first_name', ''), profile.get('last_name', ''))
        # can be consolidated into a single call to 'default=True' and
        # smart parsing results
        # default public hpc
        def_pubexec = ag.systems.list(type='execution', default=True,
                                      public=True, limit=1)
        if len(def_pubexec) > 0:
            agave_dict['def_public_executionsystem'] = def_pubexec[0].get('id')
        # default pub store
        def_pubstor = ag.systems.list(type='storage', default=True,
                                      public=True, limit=1)
        if len(def_pubstor) > 0:
            agave_dict['def_public_storagesystem'] = def_pubstor[0].get('id')

        # default private hpc
        def_prvexec = ag.systems.list(type='execution', default=True,
                                      public=False, limit=1)
        if len(def_prvexec) > 0:
            agave_dict['def_private_executionsystem'] = def_prvexec[0].get('id')
        # default private store
        def_prvstor = ag.systems.list(type='storage', default=True,
                                      public=False, limit=1)
        if len(def_prvstor) > 0:
            agave_dict['def_private_storagesystem'] = def_prvstor[0].get('id')

    except Exception:
        pass

    # api_server
    # token
    # tenantid

    return agave_dict


def get_env_vars_from_args(args, delim='='):
    '''Read from args.env'''
    env_dict = {}
    if 'env' in args:
        argenv = args.env
        #print(argenv)
        if isinstance(argenv, list):
            for ae in argenv:
                #print("  {}".format(ae))
                try:
                    k, v = ae.split(delim)
                    v = v.replace('+', ' ')
                    #print("    {}:{}".format(k,v))
                    env_dict[k] = v
                except Exception:
                    pass
    else:
        return env_dict

    # support section__field serialation
    try:
        varpat = re.compile(r"^([A-Za-z0-9]{1,})\_\_([A-Za-z0-9\_]{1,})$")
        for osk in list(os.environ.keys()):
            matches = re.match(varpat, osk)
            if matches is not None:
                section = matches.group(1)
                field = matches.group(2)
                env_dict[section + '.' + field] = os.environ.get(osk)
    except Exception:
        pass

    return env_dict

def get_env_vars(delim='__'):
    '''Read from environment'''
    env_dict = {}
    # support section__field serialation
    try:
        varpat = re.compile(r"^([A-Za-z0-9]{1,})\_\_([A-Za-z0-9\_]{1,})$")
        for osk in list(os.environ.keys()):
            matches = re.match(varpat, osk)
            if matches is not None:
                section = matches.group(1)
                field = matches.group(2)
                env_dict[section + '.' + field] = os.environ.get(osk)
    except Exception:
        pass

    return env_dict


def get_docker_vars(context):
    '''Implement some smarts in dealing with [docker] config'''
    con = context

    if 'docker.organization' in list(con.keys()):
        if con.get('docker.organization', None) is None:
            if 'docker.username' in list(con.keys()):
                con['docker.organization'] = con.get('docker.username')
                return con

    return con


def parse_args():
    '''Parse command line arguments'''
    parser = argparse.ArgumentParser(prog="rendertemplate.py",
                                     description="Jinja-like template rendering")

    parser.add_argument("-d", "--debug",
                        action='store_true', default=False,
                        help="Show debugging information")

    parser.add_argument("--no-empty",
                        action='store_true',
                        dest="noempty",
                        default=False,
                        help="Error on any undefined values for variables")

    parser.add_argument("--blank-empty",
                        action='store_true',
                        dest="blankempty",
                        default=False,
                        help="Remove unmatched variables from output")

    parser.add_argument("-E", "--variables",
                        nargs='?',
                        type=str,
                        default=None,
                        help="Variables file (ini format)")

    parser.add_argument("-e", "--env",
                        nargs='?',
                        type=str,
                        action='append',
                        dest='env',
                        help="Additional variables: key=\"value\". Can be specified multiple times.")

    parser.add_argument('input',
                        nargs='?',
                        type=argparse.FileType('r'),
                        default=sys.stdin,
                        help="Source template (STDIN)")

    parser.add_argument("output",
                        nargs='?',
                        type=argparse.FileType('w'),
                        default=sys.stdout,
                        help="Destination (STDOUT)")

    args = parser.parse_args()

    return args


def main():

    global debug

    context = {}

    args = parse_args()
    debug = args.debug
    template = args.input.read()

    # extract variables so we can implement --no-empty or
    # --blank-empty behavior
    varpattern = re.compile(r"\{\{\s+?([a-zA-Z0-9\.\-\_]+)\s+?\}\}")
    template_varnames = re.findall(varpattern, template)
    if args.blankempty:
        for varname in template_varnames:
            context.update({varname: None})

    # populate date_time
    context.update(flatten(get_date_time_facts()))

    # populate agave variables based on logged in user
    ag = Agave.restore()
    agave_vars = expand(get_agave_vars(ag), 'agave')
    context.update(agave_vars)

    # read in values from optional config file
    if args.variables is not None:
        config = configparser.ConfigParser()
        config_dict = {}
        config.read(args.variables)
        for s in config.sections():
            for k in config.options(s):
                if s != 'DEFAULT':
                    template_var_key = u'.'.join(
                        [s, k])
                else:
                    template_var_key = k
                config_dict[template_var_key] = config.get(s, k)
        context.update(config_dict)

    # Since the intent of namespaced variables to to override
    # the variables file, we read it and do the update on the
    # context after reading from that file
    env_dict = get_env_vars_from_args(args)
    context.update(env_dict)

    # implement our docker variable override
    docker_vars = get_docker_vars(context)
    context.update(docker_vars)

    # should it be optional to inherit from os.environ?
    context.update(os.environ)

    # Do the subsitution dance
    for var in list(context.keys()):
        try:
            pattern = re.compile('{{\s{0,}' + var + '\s{0,}}}')
            replacement = context[var]
            if replacement is None:
                replacement = ''
            template = re.sub(pattern, replacement, template)
        except Exception:
            pass

    # handle all three paths for dealing with undefined or empty values
    empty_vars = []
    for varname in template_varnames:
        if context.get(varname) is None:
            empty_vars.append(varname)
    if args.noempty:
        if len(empty_vars) > 0:
            raise ValueError("No assigned value for: {}".format(
                ', '.join(empty_vars)))
    if args.blankempty:
        if debug:
            if len(empty_vars) > 0:
                print("Variables evaluated as empty include: {}".format(
                    ', '.join(empty_vars)))

    args.output.write(template)
    args.output.close()


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        if debug:
            raise
        else:
            print("Error: {}".format(e))
