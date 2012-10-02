# -*- coffee-tab-width:2 -*-
net = require 'net'
fs  = require 'fs'

# config variables
base          = process.env.npm_package_config_base
host          = process.env.npm_package_config_host
port          = process.env.npm_package_config_port
sync_servers  = [{ host:"tortilla", port:4444 }]

# read a file in which each line is a JSON message, this may change
all = {}
fs.readFile base, 'utf8', (err,data) ->
  if err then throw err
  try json = "[#{(data.replace(/\s\s*$/, '').replace /(\n|\r)/gm, ', ')}]"
  catch err then console.error "error parsing database:#{err}"
  total = (all[msg.hash] = msg for msg in (JSON.parse json)).length
  console.log "loaded #{total} messages"


## Utility
Array.prototype.some  ?= (func) -> (return true  for it in @ when func it); false
Array.prototype.every ?= (func) -> (return false for it in @ when not (func it)); true
identity = (it) -> it
wrap = (it) -> if it instanceof Array then it else [it]
startsWith = (str,pre) -> str.substr(0,pre.length) == pre

save = () ->
  console.log "saving"
  fs.writeFile base, ((JSON.stringify v for k,v of all).join '\n'), 'utf8'

send = (remote, msgs) ->
  socket = net.createConnection remote, () ->
    socket.write "push "+JSON.stringify msgs
  socket.on 'data', (data) -> socket.end()
  socket.on 'error', (err) ->
    console.error "send(remote=#{JSON.stringify remote}): #{err}"


## Server
server = (socket) ->
  socket.on 'data', (data) ->
    str      = data.toString('utf8')
    try msg_data = JSON.parse (str.substr 5)
    catch err then console.error "server parse error: #{err}"
    switch (str.substr 0, 4).toLowerCase()
      when 'push' then push socket, msg_data
      when 'pull' then pull socket, msg_data
      when 'grep' then grep socket, msg_data
      else bail socket
  socket.on 'error', (err) -> console.error "server socket error: #{err}"

# read a (list of) message(s) and add them to the local message store
push = (socket, msgs) ->
  (msgs = hook msgs for hook in pre_save_hook)
  added = []
  for msg in (wrap msgs) when msg.hash and not (msg.hash of all)
    added.push msg
    all[msg.hash] = msg
  (hook socket, added for hook in post_save_hook) if added.length > 0
  socket.end  "added #{added.length} messages"

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
share = (socket, msgs) ->
  for remote in sync_servers when not (remote.host == socket.host)
    console.log "#{msgs.length} messages -> #{remote.host}:#{remote.port}"
    send remote, msgs

verify_signatures = (msgs) ->
  throw "TODO: remove messages with unverrified signatures"

# customizable to reject messages which don't match hook functions
pre_save_hook = [identity]

# called on saved messages
post_save_hook = [save, share]


## Run the server
net.createServer(server).listen(port, host);
console.log "server running on #{host}:#{port}"
