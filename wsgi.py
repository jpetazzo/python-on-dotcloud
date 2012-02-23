#!/usr/bin/env python

# This is just an example, replace this with your own wsgi.py file

def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/plain')])
    return b'Hello, world!\n'