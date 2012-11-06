dissemination
=============

The "dissemination" information dissemination system is a protocol
rather than a tool, however, both a server and a command line client
which implement this protocol are distributed with this document.  See
[man dis-server] for more information on the server and [man dis] for
more information on the command line client.

The core of the system is a loose network of servers which share
messages similar in architecture to Usenet.  Messages are serialized
as JSON hashes.  Messages are signed or encrypted using PGP public and
private keys.  Authorship is fully specified through PGP signatures
rather than network addresses (either email or IP).  The primary goals
are simplicity, security, privacy, and robust operation.

This repository provides an npm package for node.js which includes a
message server and a command-line tool for communicating with message
servers.  The command line tools may also be installed separate from
the server as an Arch Linux AUR package.

See the man pages for more information.  To view the man pages locally
run the following from the base of this repository.

    # complete description of the design and goals of the dis system
    man -l man/dis.7

    # manual for the message server
    man -l man/server.1

    # manual for the command line interface
    man -l man/dis.1
