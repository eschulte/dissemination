dissemination
=============

A distributed system for the dissemination of messages.  The core of
the system is a loose network of servers which share messages similar
in architecture to Usenet.  Messages are serialized as JSON hashes.
Messages are signed or encrypted using GPG public and private keys.
The primary goals are simplicity, security, privacy, and robust
operation.

This package provides a message server, a command-line tool for
communicating with message servers, and a cgi web-page for accessing a
message server through a web page.

server to persist, disseminate, search and download messages
------------------------------------------------------------

Run the server with `npm start`.

The server provides access to a local message database from the
network.  The following actions are supported.
- `grep` searches the database and returns search results
- `pull` returns specific messages from the database
- `push` inserts messages into the database

Three configuration parameters may be set.
- `base` specifies the file in which to store the message database
- `port` specifies the port on which the server will listen
- `config` specifies a configuration file in which arbitrary functions
  may be added to the server through two hooks.  The `pre-save-hook`
  runs on all incoming messages and may be used to filter messages,
  e.g., those without a valid pgp signature.  The `post-save-hook` is
  called on all messages after they are added to the local database
  and may be used to save these messages to disk or send saved
  messages to other message servers.

command line interface to distributed information dissemination
---------------------------------------------------------------

    usage: dis [options] cmd [args]

    Commands:
     grep ---- search remote server for key regexp pairs
     pull ---- pull messages from remote server matching hashes
     push ---- push messages to a remote server

    Options:
     -H, --host [HOST]        host name of the remote host
                              default is DIS_HOST or localhost
     -p, --port [PORT]        port on the remote host
                              default is DIS_PORT or 4444
     -j, --json               leave the results as raw JSON
     -n, --dry-run            print to STDOUT instead of the server

    PUSH Options:
     -s, --sign               sign message
     -S, --signatory [USER]   use USER as signatory, implies -s
                              defaults to DIS_SIGNATORY or GPGKEY
     -e, --encrypt [USER]     encrypt for recipient USER, this options
                              multiple okay for multiple recipients
     -I, --hide               hide recipient list from public view
