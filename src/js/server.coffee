# -*- coffee-tab-width:2 -*-
net = require 'net'
fs  = require 'fs'

# config variables
base_path     = process.env.npm_package_config_base_path
host          = process.env.npm_package_config_host
port          = process.env.npm_package_config_port
pre_save_hook = process.env.npm_package_config_pre_save_hook
post_save_hook = process.env.npm_package_config_post_save_hook
save_interval = process.env.npm_package_config_save_interval
sync_servers  = process.env.npm_package_config_sync_servers
sync_interval = process.env.npm_package_config_sync_interval

# read a file in which each line is a JSON message, this may change
all = {}
fs.readFile base_path, 'utf8', (err,data) ->
  if err then throw err
  json = "[#{(data.replace(/\s\s*$/, '').replace /(\n|\r)/gm, ', ')}]"
  (JSON.parse json).map (msg) -> all[msg.hash] = msg


## Utility
Array.prototype.some  ?= (func) -> (return true  for it in @ when func it); false
Array.prototype.every ?= (func) -> (return false for it in @ when not (func it)); true

wrap = (it) -> if it instanceof Array then it else [it]

startsWith = (str,pre) -> str.substr(0,pre.length) == pre

save = () ->
  fs.writeFile base_path, ((JSON.stringify v for k,v of all).join '\n'), 'utf8'

send = (remote, msgs) ->
  socket.connect(remote.port, remote.host)
  socket.write "push "+JSON.stringify msgs
  socket.on data, (data) -> socket.destroy()

# Synchronize message list with remove servers
sync = () ->
  sync_servers.map (remote) ->
    socket = new net.Socket
    socket.connect(remote.port, remote.host)
    socket.write "grep {}" # to get a list of all remote hashes
    socket.on data, (data) ->
      theirs = (JSON.parse data)
      to_pull = (hash for hash in theirs when not hash of all)
      to_push = (hash for hash in all    when not hash of theirs)
      socket.write "pull "+JSON.stringify to_pull
      socket.on data, (data) -> (all[k] = v for k,v of (JSON.stringify data))
      socket.write "push "+JSON.stringify to_push
      socket.on data, (data) -> socket.destroy()


## Server
server = (socket) ->
  socket.on 'data', (data) ->
    str      = data.toString('utf8')
    msg_data = JSON.parse (str.substr 5)
    switch (str.substr 0, 4).toLowerCase()
      when 'push' then push socket, msg_data
      when 'pull' then pull socket, msg_data
      when 'grep' then grep socket, msg_data
      else bail socket

# read a (list of) message(s) and add them to the local message store
push = (socket, msgs) ->
  msgs = (msgs = hook msgs for hook in pre_save_hook)
  added = (all[msg.hash] = msg for msg in (wrap msgs) when not (msg.hash of all)).length
  (hook msgs for hook in post_save_hook)
  socket.end  "added #{added} messages"

# read a (list of) hash prefix(es) and return the identified messages
pull = (socket, hashes) ->
  match_pull = (key) -> (wrap hashes).some (pre) -> startsWith key, pre
  socket.end (JSON.stringify (v for k,v of all when match_pull k))+'\n'

# read a JSON query and return the hashes of the matching messages
grep = (socket, query) ->
  match_grep = (msg) ->
    Object.keys(query).every (key) -> (new RegExp(query[key])).exec msg[key]
  socket.end (JSON.stringify (k for k,v of all when match_grep v))+'\n'

# bail on unknown action
bail = (socket) -> socket.end 'unsupported action\n'


## Hook functions
share = (msgs) -> (send remote, msgs for remote in sync_servers)

# TODO: remove messages with unverrified signatures
verify_signatures = (msgs) -> []


## Start Timers
setInterval(sync, sync_interval) if sync_interval >= 0
setInterval(save, save_interval) if save_interval >= 0


## Run the server
net.createServer(server).listen(port, host);
console.log "server running on #{host}:#{port}"
