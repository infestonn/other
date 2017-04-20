#!/usr/bin/env python3

import os, time


def _listdir(directory=None, numdel=5, exclude_list=None):
    directory = directory or os.getcwd()
    '''Removes last 'numdel' modified files in the 'directory' '''
    line_keys = []
    directory = directory if directory.endswith(os.sep) else directory + os.sep
    if exclude_list is not None:
        if type(exclude_list) == str:
            exclude_list = [exclude_list,]
    else:
        exclude_list = []
    line_keys = sorted((directory + path for path in os.listdir(directory) if path not in exclude_list),#create list of files in 'directory' if file name not in 'exclude_list' 
        key=lambda x: os.path.getmtime(x), reverse=True)  # and sort it by date(newest first)
    for i in line_keys[:numdel]:
        try:
            os.remove(i)
        except OSError:
            os.removedirs(i)