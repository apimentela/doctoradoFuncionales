#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  sin título.py
#  
#  Copyright 2018 Alejandro <alejandro@alejandro-PowerEdge-T20>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

import socketserver

class MyUNIXHandler(socketserver.StreamRequestHandler):

    def handle(self):
        # self.rfile is a file-like object created by the handler;
        # we can now use e.g. readline() instead of raw recv() calls
        self.data = self.rfile.readline().strip()
        print(self.data)
        # Likewise, self.wfile is a file-like object used to write back
        # to the client
        #~ self.wfile.write(self.data.upper())

if __name__ == '__main__':
    ADDR = "/tmp/algo"

    # Create the server, binding to localhost on port 9999
    server = socketserver.UnixStreamServer(ADDR, MyUNIXHandler)
        # Activate the server; this will keep running until you
        # interrupt the program with Ctrl-C
    server.serve_forever()
