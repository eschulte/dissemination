net = require 'net'
fs  = require 'fs'
all = {}

# utility
startsWith = (str,pre) -> str.substr(0,pre.length) == pre
trim = (str) -> str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')
incorporate = (str) ->
        for line in str.split('\n') when line.length > 0
                msg = JSON.parse line
                all[msg.hash] = msg

# read a file in which each line is a JSON message, this may change
fs.readFile '/home/eschulte/.dis-base', 'utf8', (err,data) ->
        if err then throw err else incorporate data

# The server supports the following actions:
server = (socket) ->
        socket.on 'data', (data) ->
                str      = data.toString('utf8')
                msg_data = trim (str.substr 5)
                switch (str.substr 0, 4).toLowerCase()
                        when "push" then push socket, msg_data
                        when "pull" then pull socket, msg_data
                        when "grep" then grep socket, msg_data
                        else bail socket
        socket.end

# 1. push will read a message and add it to the server's local
#    message list
push = (socket, msg_data) ->
        console.log "calling push"
        message = JSON.parse msg_data
        if message.hash and message.hash in all
                all[message.hash] = message

# 2. pull will read a hash prefix, if it uniquely identifies a
#    message than that message will be returned, otherwise a failure
#    message will be given.
pull = (socket, msg_data) ->
        match_pull = (key) ->
                for pre in msg_data.split(' ')
                        if startsWith key, pre then return true
                return false
        console.log "pull: "+msg_data
        for key in Object.keys(all) when match_pull key
                socket.write (JSON.stringify all[key])+'\n'

# 3. grep will read query and return a list of the hashes of all
#    matching messages
grep = (socket, msg_data) ->
        query = JSON.parse msg_data
        match_grep = (msg) ->
                for key,val of query
                        unless (new RegExp(val)).exec msg[key] then return false
                return true
        hashes = []
        for hash,msg of all
                if match_grep msg then hashes.push hash
        socket.write (JSON.stringify hashes)+'\n'

# 4. bail on unknown action
bail = (socket) -> socket.write "unsupported action\n"

net.createServer(server).listen(1337, "127.0.0.1");
