# -*- coffee-tab-width:2 -*-
net = require 'net'
fs  = require 'fs'
all = {}

# utility
startsWith = (str,pre) -> str.substr(0,pre.length) == pre
wrap = (it) -> if it instanceof Array then it else [it]
Array.prototype.some ?= (func) -> (return true  for it in @ when func it); false
Array.prototype.all  ?= (func) -> (return false for it in @ when not func it); true

# read a file in which each line is a JSON message, this may change
fs.readFile '/home/eschulte/.dis-base', 'utf8', (err,data) ->
  if err then throw err
  json = "[#{(data.replace(/\s\s*$/, '').replace /(\n|\r)/gm, ', ')}]"
  (JSON.parse json).map (msg) -> all[msg.hash] = msg

# The server supports the following actions:
server = (socket) ->
  socket.on 'data', (data) ->
    str      = data.toString('utf8')
    msg_data = JSON.parse (str.substr 5)
    switch (str.substr 0, 4).toLowerCase()
      when 'push' then push socket, msg_data
      when 'pull' then pull socket, msg_data
      when 'grep' then grep socket, msg_data
      else bail socket

# 1. push will read a (list of) message(s) and add it to the server's
#    local message list
push = (socket, msgs) ->
  (all[msg.hash] = msg for msg in (wrap msgs) when not msg.hash of all)
  socket.end "added #{msgs.length} messages"

# 2. pull will read a (list of) hash prefix(es), and return the
#    messages identified by the hash(es)
pull = (socket, hashes) ->
  match_pull = (key) -> (wrap hashes).some (pre) -> startsWith key, pre
  socket.end (JSON.stringify (v for k,v of all when match_pull k))+'\n'

# 3. grep will read a JSON query and return a list of the hashes of
#    all matching messages
grep = (socket, query) ->
  match_grep = (msg) ->
    return false for k,v of query when not (new RegExp(v)).exec msg[k]
    return true
  socket.end (JSON.stringify (k for k,v of all when match_grep v))+'\n'

# 4. bail on unknown action
bail = (socket) -> socket.end 'unsupported action\n'

net.createServer(server).listen(1337, '127.0.0.1');
