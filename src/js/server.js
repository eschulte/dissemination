var net = require('net');
var fs  = require ('fs');

// utility
function includes (obj, key){
  return Object.keys(obj).indexOf(key) >= 0; }

function str_begins(str, prefix){
  return str.substring(0,prefix.length) === prefix; }

function trim (str) {
  return str.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); }

// a file in which each line is a JSON message, this may change
var all = {};
fs.readFile('/home/eschulte/.dis-base', 'utf8', function(err,data){
  if(err) throw err;
  data.split('\n')
    .filter(function(line){ return line.length > 0; })
    .map(function(line){ return JSON.parse(line); })
    .map(function(msg){ all[msg.hash] = msg; })});

// The server  supports the following actions:
var serve = function(socket) {
  socket.on('data', function(data){
    var act      = data.toString('utf8').substr(0,4);
    var msg_data = trim(data.toString('utf8').substr(5));
    switch(act.toLowerCase()){
      case 'push': push(socket, msg_data); break;
      case 'pull': pull(socket, msg_data); break;
      case 'grep': grep(socket, msg_data); break;
      default:     bail(socket, act)};
  socket.end(); })};

// 1. push will read a message and add it to the server's local
//    message list
var push = function(socket, msg_data){
  var message = JSON.parse(msg_data.toString('utf8'));
  var hash = message.hash;
  if(hash && (! includes(all, hash))){
    all[hash] = message; }}

// 2. pull will read a hash prefix, if it uniquely identifies a
//    message than that message will be returned, otherwise a failure
//    message will be given.
var pull = function(socket, msg_data){
  var matching = Object.keys(all).filter(function(key){
    return str_begins(key, msg_data); });
  if(matching.length == 1){
    socket.write(JSON.stringify(all[matching[0]])+'\n'); }};

// 3. grep will read query and return a list of the hashes of all
//    matching messages
var grep = function(socket, msg_data){ socket.write("not supported"); };

// 4. bail on unknown action
var bail = function(socket, act){
  socket.write("unsupported action '"+act+"', try one of push/pull/grep"); }

net.createServer(serve).listen(1337, "127.0.0.1");
