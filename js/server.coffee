net = require 'net'                                 # -*- coffee-tab-width:2 -*-
fs  = require 'fs'
gpg = require 'gpgme'

# config variables
base           = process.env.npm_package_config_base
port           = process.env.npm_package_config_port
config         = process.env.npm_package_config_config
sync_servers   = [] # list of servers with which to share (in config)
pre_save_hook  = [] # list of functions which may reject messages (in config)
post_save_hook = [] # called on saved messages (in config)

# read a file in which each line is a JSON message, this may change
all = {}
fs.readFile base, 'utf8', (err,data) ->
  if err then throw err
  try json = "[#{(data.replace(/\s\s*$/, '').replace /(\n|\r)/gm, ', ')}]"
  catch err then console.error "error parsing database:#{err}"
  total = (all[msg.hash] = msg for msg in (JSON.parse json)).length
  console.log "loaded #{total} messages"


## Utility
Array.prototype.some  ?= (f) -> (return true  for it in @ when f it); false
Array.prototype.every ?= (f) -> (return false for it in @ when not (f it)); true
identity = (it) -> it
wrap = (it) -> if it instanceof Array then it else [it]
startsWith = (str,pre) -> str.substr(0,pre.length) == pre

save = () ->
  console.log "saving"
  fs.writeFile base, ((JSON.stringify v for k,v of all).join '\n') + '\n', 'utf8'

send = (remote, msgs) ->
  socket = net.createConnection remote, () ->
    socket.write "push "+JSON.stringify msgs
  socket.on 'data', (data) -> socket.end()
  socket.on 'error', (err) ->
    console.error "send(remote=#{JSON.stringify remote}): #{err}"


## Server
server = (socket) ->
  str = "";
  socket.on 'data', (data) ->
    if (str += data.toString('utf8')).indexOf("\n") >= 0
      try
        msg_data = JSON.parse (str.substr 5)
        switch (str.substr 0, 4).toLowerCase()
          when 'push' then push socket, msg_data
          when 'pull' then pull socket, msg_data
          when 'grep' then grep socket, msg_data
          else
            socket.end 'unsupported action\n'
      catch e then socket.end "server processing #{e}"
  socket.on 'error', (err) -> console.error "server socket #{err}"

# read a (list of) message(s) and add them to the local message store
push = (socket, msgs) ->
  added = []; msgs = (wrap msgs)
  thread = (prev,curr) -> (arg) -> curr(arg,prev)
  cont = (msgs) ->
    for msg in (wrap msgs) when msg.hash and not (msg.hash of all)
      added.push msg; all[msg.hash] = msg
    (hook added, socket for hook in post_save_hook) if added.length > 0
    socket.end  JSON.stringify(msg.hash for msg in added)+'\n'
  try (pre_save_hook.reverse().reduce thread, cont) msgs catch e
    socket.end "pre_save_hook error: #{e}"; msgs=[]

# read a (list of) hash prefix(es) and return the identified messages
pull = (socket, hashes) ->
  expand = (pre) -> (v for k,v of all when startsWith k, pre)
  out = ((expand h) for h in (wrap hashes)).reduce (a,b) -> a.concat b
  socket.end (JSON.stringify out)+'\n'

# read a JSON query and return the hashes of the matching messages
grep = (socket, query) ->
  match_grep = (msg) ->
    Object.keys(query).every (key) -> (new RegExp(query[key])).exec msg[key]
  socket.end (JSON.stringify (k for k,v of all when match_grep v))+'\n'


## Hook functions
share = (msgs, socket) ->
  for remote in sync_servers when not (remote.host == socket.host)
    console.log "#{msgs.length} messages -> #{remote.host}:#{remote.port}"
    send remote, msgs

verify_signatures = (msgs, cb) ->
  cb (msg for msg in msgs when (not msg.signature) or gpg.verify(msg.signature, msg.content))

fs.exists config, (exists) ->
  fs.readFile config, 'utf8', (err,data) ->
    if err then console.error "error loading config: #{err}" else eval data


## Run the server
net.createServer(server).listen(port);
console.log "server running on port #{port}"
