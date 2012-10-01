# -*- coffee-tab-width:2 -*-
net = require 'net'
fs  = require 'fs'
all = {}

# config variables
base_path     = process.env.npm_package_config_base_path
host          = process.env.npm_package_config_host
port          = process.env.npm_package_config_port
save_interval = process.env.npm_package_config_save_interval
push_servers  = process.env.npm_package_config_push_servers
push_interval = process.env.npm_package_config_push_interval
pull_servers  = process.env.npm_package_config_pull_servers
pull_interval = process.env.npm_package_config_pull_interval
max_pull_msgs = process.env.npm_package_config_max_pull_msgs
max_push_msgs = process.env.npm_package_config_max_push_msgs

# utility
Array.prototype.some  ?= (func) -> (return true  for it in @ when func it); false
Array.prototype.every ?= (func) -> (return false for it in @ when not (func it)); true
wrap = (it) -> if it instanceof Array then it else [it]
startsWith = (str,pre) -> str.substr(0,pre.length) == pre
save = () ->
  fs.writeFile base_path, ((JSON.stringify v for k,v of all).join '\n'), 'utf8'

# read a file in which each line is a JSON message, this may change
fs.readFile base_path, 'utf8', (err,data) ->
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
  added = (all[msg.hash] = msg for msg in (wrap msgs) when not (msg.hash of all)).length
  socket.end  "added #{added} messages"

# 2. pull will read a (list of) hash prefix(es), and return the
#    messages identified by the hash(es)
pull = (socket, hashes) ->
  match_pull = (key) -> (wrap hashes).some (pre) -> startsWith key, pre
  socket.end (JSON.stringify (v for k,v of all when match_pull k))+'\n'

# 3. grep will read a JSON query and return a list of the hashes of
#    all matching messages
grep = (socket, query) ->
  match_grep = (msg) ->
    Object.keys(query).every (key) -> (new RegExp(query[key])).exec msg[key]
  socket.end (JSON.stringify (k for k,v of all when match_grep v))+'\n'

# 4. bail on unknown action
bail = (socket) -> socket.end 'unsupported action\n'


## Timers

# Synchronize message list with remove servers
sync = () ->
  pull_servers.map (remote) ->
    socket = new net.Socket
    socket.connect(remote.port, remote.host)
    socket.write "grep {}"
    socket.on data, (data) ->
      theirs = (JSON.parse data)
      to_pull = (hash for hash in theirs when not hash of all)
      to_push = (hash for hash in all    when not hash of theirs)
      socket.write "pull "+JSON.stringify to_pull
      socket.on data, (data) -> (all[k] = v for k,v of (JSON.stringify data))
      socket.write "push "+JSON.stringify to_push
      socket.on data, (data) -> socket.destroy()

setInterval(sync, pull_interval) if pull_interval >= 0
setInterval(save, save_interval) if save_interval >= 0


## Run the server
net.createServer(server).listen(port, host);
console.log "server running on #{host}:#{port}"
