#!/usr/bin/python
#
# This program shows how to use a WSGI
#
import sys
from subprocess import call
from bottle import get, post, request, run, route

maclistfile = "/shared/management/maclist"
remoteuser = "rooot"
#etherwakecommand = "sudo etherwake %s"%(_fields[1])

def readfile(_filename):
	_file = open(_filename,'r')
	_filelines = _file.readlines()
	_file.close()
	return _filelines

def findMACGivenId(_id):
	_filelines = readfile(maclistfile)
	i = 0;
	_totallines = len(_filelines)
	while (i < _totallines):
		_line = _filelines[i]
		i = i + 1
		_fields = _line.split("|")
		if (_id == _fields[0]):
			return _fields[1]
	return ""

def runcommand(command):
	print "Executing %s"%(command)
	return call(command,shell=True)

@get('/turnonws')
def turnonws():
	return '''
		<form action="/turnonws" method="post">
			Machine id to be turned on: <input name="machineid" type="text"/>
			<input value="Submit" type="submit">
		</form>
	'''

@post('/turnonws')
def do_turnonws():
		_machineid = request.forms.get("machineid")
		_ret = runcommand("sudo etherwake %s"%(findMACGivenId(_machineid)))
		if (_ret == 0):
			return "<p>Success etherwake</p"
		else:
			return "<p>Failed etherwake</p"

@get('/turnoffws')
def turnoffws():
	return '''
		<form action="/turnoffws" method="post">
			Machine IP to be turned off: <input name="machineid" type="text"/>
			<input value="Submit" type="submit">
		</form>
	'''

@post('/turnoffws')
def do_turnoffws():
		_machineid = request.forms.get("machineid")
		_ret = runcommand("ssh %s@%s sudo halt -p"%(remoteuser,_machineid))
		if (_ret == 0):
			return "<p>Success shutdown</p"
		else:
			return "<p>Failed shutdown</p"

@route('/turnallon')
def do_turnallon():
        _filelines = readfile(maclistfile)
        i = 0;
        _totallines = len(_filelines)
        while (i < _totallines):
                _line = _filelines[i]
                i = i + 1
                _fields = _line.split("|")
		_ret = runcommand("sudo etherwake %s"%(_fields[1]))

@route('/turnalloff')
def do_turnalloff():
        _filelines = readfile(maclistfile)
        i = 0;
        _totallines = len(_filelines)
        while (i < _totallines):
                _line = _filelines[i]
                i = i + 1
                _fields = _line.split("|")
		_ret = runcommand("ssh %s@%s sudo halt -p"%(remoteuser,_fields[2]).strip())


run(host='172.17.9.50', port=8008, debug=True)
