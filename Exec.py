#!/usr/bin/python
'''
This module starts or stops a command on a given port from the pool of ports in ports.yaml.
Or lists all opened ports.
'''

import argparse
from subprocess import check_output
import subprocess
import os
import sys
import yaml
import logging


def parse_arg():

    parser = argparse.ArgumentParser(description='Starts/stops program or lists free ports.')

    subparsers = parser.add_subparsers(help='Action commands', dest='mode')
    
    act_start = subparsers.add_parser('start', help='Start program')
    act_start.add_argument(type=int, action='store', metavar='port_number', dest='port')
    act_start.add_argument('--params', action='store', dest='params')

    act_stop = subparsers.add_parser('stop', help='Stop program')
    act_stop.add_argument('port', type=int, action='store', metavar='port number')

    act_list = subparsers.add_parser('list', help='List free ports')
    act_list.add_argument('--port')

    parser.add_argument('--log-level', help='Logging level. 0 - Nothing, 1 - Errors, 2 - Warning, 3 - Info ,4 - Debug',
                        choices=[0, 1, 2, 3, 4], type=int, default=3, dest='logging_level')   

    if len(sys.argv) == 1:
        parser.print_help()
        exit(0)

    return parser.parse_args()


def execute_program(shell_prog='date', prog_arguments='None', mode='start', port=6000, log=3):
    prog_output = check_output([shell_prog, prog_arguments]).rstrip() #result of executed program
    set_log_level(level=log)
    
    try:
        y = load_yaml('open_ports.yaml')
        opened_ports = dict() if y is None else y
        portrange = load_yaml('ports.yaml')
        if mode == 'start': #START
            if port not in portrange['ports']:
                logging.error(u'Invalid port number. Enter port %s-%s' % (portrange['ports'][1], portrange['ports'][-1]))
                raise ValueError
            elif port not in opened_ports:
                opened_ports.update({port:prog_output}) #add opened port to opened_ports 
                save_to_yaml(opened_ports, 'open_ports.yaml') #and write result of executed prog to dictionary
                print('starting')
            else:
                logging.warning(u'Port %s already opened' % port)
        elif mode == 'stop': #STOP
            if port in opened_ports:
                del opened_ports[port] #remove opened port from dict
                save_to_yaml(opened_ports, 'open_ports.yaml')
                print('stopped')
            elif port not in portrange['ports']:
                logging.error(u'Invalid port number. Enter port %s-%s' % (portrange['ports'][1], portrange['ports'][-1]))
                raise ValueError
            else:
                logging.warning('%s port is not opened' % port)
        elif mode == 'list': #LIST
            for i in sorted(opened_ports.keys()):
                print(i)
    except ValueError as err:
        raise ValueError
        logging.error(u'Invalid port number. Enter port %s-%s' % (portrange['ports'][1], portrange['ports'][-1]))
    except subprocess.CalledProcessError as err:
        raise subprocess.CalledProcessError
        logging.error(u'Invalid parameter s%' % prog_arguments)


def load_yaml(file):
    try:
        fh = open(file, 'r')
        return yaml.load(fh)
    except EnvironmentError as err:
        logging.critical('Import error: {0}'.format(err))
        exit(1)
    finally:
        try:
            fh.close()
        except: pass


def save_to_yaml(obj, file, fs=False):
    try:
        fh = open(file, 'w')
        yaml.dump(obj, fh, default_flow_style=fs)
    except EnvironmentError as err:
        logging.critical('Export error: {0}'.format(err))
        exit(1)
    finally:
        try:
            fh.close()
        except: pass


def set_log_level(level=0):
    log_format_debug='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    log_format_error='%(levelname)s: %(message)s'
    log_format='%(message)s'

    if level == 0:
        logging.basicConfig(level=logging.NOTSET, format=log_format)
    elif level == 1:
        logging.basicConfig(level=logging.ERROR, format=log_format)
    elif level == 2:
        logging.basicConfig(level=logging.WARNING, format=log_format)
    elif level == 3:
        logging.basicConfig(level=logging.INFO, format=log_format)
    elif level >= 4:
        logging.basicConfig(format = u'%(filename)s[LINE:%(lineno)d]# %(levelname)-8s [%(asctime)s]  %(message)s', level = logging.DEBUG)