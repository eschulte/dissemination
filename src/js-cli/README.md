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
