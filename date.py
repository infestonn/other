#!/usr/bin/python

import Exec
arguments = Exec.parse_arg()
Exec.execute_program(prog_arguments=arguments.params, mode=arguments.mode, port=arguments.port, log=arguments.logging_level)