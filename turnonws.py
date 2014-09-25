#!/usr/bin/python
import sys
from subprocess import call
maclistfile = "../maclist"
if (len(sys.argv) < 2):
	sys.exit("Provide a workstation number, e.g. %s 05"%(sys.argv[0]))
_file = open(maclistfile,'r')
_filelines = _file.readlines()
_file.close()
_wsnum = sys.argv[1]
i = 0;
_totallines = len(_filelines)
_flag = True
while (i < _totallines):
	_line = _filelines[i]
	i = i + 1
	_fields = _line.split("|")
	if (_wsnum == _fields[0]):
		_flag = False
		command = "sudo etherwake %s"%(_fields[1])
		print "Executing %s"%(command)
		call(command,shell=True)
		break
if (_flag):
	print "Workstation with number %s was not found"%(_wsnum)
