var net = require('net');
var fs  = require ('fs');

// a file in which each line is a JSON message, this may change
var all = {};
fs.readFile('/home/eschulte/.dis-base', 'ASCII', function(err,data){
  if(err) throw err;
  var lines = data.split('\n');
  for(i=0;i<lines.length;i++){
    if(lines[i].length > 0){
      var msg = JSON.parse(lines[i]);
      all[msg.hash] = msg; }}});

// The server  supports the following actions:
var serve = function(socket) {
  socket.on('data', function(data){
    socket.write("got:"+data+"\n");
    var act      = data.toString('ascii').substr(0,4);
    var msg_data = data.toString('ascii').substr(0,4);
    switch(act.toLowerCase()){
      case 'push': push(socket, msg_data); break;
      case 'pull': pull(socket, msg_data); break;
      case 'grep': grep(socket, msg_data); break;
      default:     bail(socket, act);
    }})};

// 1. push will read a message and add it to the server's local
//    message list
var push = function(socket, msg_data){
  var message = JSON.parse(msg_data);
  var hash = message.hash;
  if(hash){
    // TODO: conditionally add if not already present
    socket.write("[accepted]"); }
  else{
    socket.write("[rejected] no hash"); } }

// 2. pull will read a hash prefix, if it uniquely identifies a
//    message than that message will be returned, otherwise a failure
//    message will be given.
var push = function(socket, msg_data){ socket.write("not supported"); };

// 3. grep will read query and return a list of the hashes of all
//    matching messages
var grep = function(socket, msg_data){ socket.write("not supported"); };

// 4. bail on unknown action
var bail = function(socket, act){
  socket.write("unsupported action '"+act+"', try one of push/pull/grep"); }

net.createServer(serve).listen(1337, "127.0.0.1");
