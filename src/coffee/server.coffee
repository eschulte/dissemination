# -*- coffee-tab-width:2 -*-
net = require 'net'
fs  = require 'fs'
all = {}

# utility
startsWith = (str,pre) -> str.substr(0,pre.length) == pre
trim = (str) -> str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')
incorporate = (str) ->
  counter = 0
  (JSON.parse line for line in str.split('\n') when line.length > 0).map (msg) ->
    unless msg.hash of all
      all[msg.hash] = msg
      counter += 1
  counter

# read a file in which each line is a JSON message, this may change
fs.readFile '/home/eschulte/.dis-base', 'utf8', (err,data) ->
  if err then throw err else incorporate data
  console.log 'loaded '+(Object.keys(all).length)+' message(s)'

# The server supports the following actions:
server = (socket) ->
  socket.on 'data', (data) ->
    str      = data.toString('utf8')
    msg_data = trim (str.substr 5)
    switch (str.substr 0, 4).toLowerCase()
      when 'push' then push socket, msg_data
      when 'pull' then pull socket, msg_data
      when 'grep' then grep socket, msg_data
      else bail socket
  socket.end

# 1. push will read a message and add it to the server's local
#    message list
push = (socket, msg_data) ->
  update = "added  #{incorporate msg_data} message(s)"
  console.log update
  socket.write update+'\n'

# 2. pull will read a hash prefix, if it uniquely identifies a
#    message than that message will be returned, otherwise a failure
#    message will be given.
pull = (socket, msg_data) ->
  match_pull = (key) ->
    return true  for pre in msg_data.split(' ') when startsWith key, pre
    return false
  socket.write (JSON.stringify v)+'\n' for k,v of all when match_pull k

# 3. grep will read query and return a list of the hashes of all
#    matching messages
grep = (socket, msg_data) ->
  query = JSON.parse msg_data
  match_grep = (msg) ->
    return false for k,v of query when not (new RegExp(v)).exec msg[k]
    return true
  socket.write (JSON.stringify (k for k,v of all when match_grep v))+'\n'

# 4. bail on unknown action
bail = (socket) -> socket.write 'unsupported action\n'

net.createServer(server).listen(1337, '127.0.0.1');
