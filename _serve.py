#!/usr/bin/env python3
"""Local LP preview server.

This script must be invoked with its own absolute path so that
__file__ points at the LP directory. We then chdir there before
the http stdlib lazily evaluates os.getcwd(), avoiding the macOS
sandbox PermissionError that hits when the spawn cwd is unreadable.
"""
import os
import sys

LP_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(LP_DIR)

from http.server import HTTPServer, SimpleHTTPRequestHandler
import functools

handler = functools.partial(SimpleHTTPRequestHandler, directory=LP_DIR)
server = HTTPServer(("127.0.0.1", 5500), handler)
print(f"Serving {LP_DIR} at http://127.0.0.1:5500/", flush=True)
server.serve_forever()
