tls = require('tls')
fs = require('fs')

options =
  key: fs.readFileSync(process.argv[2])
  cert: fs.readFileSync(process.argv[3])

server = tls.createServer options, (cleartextStream) ->
  console.log 'server connected',
              cleartextStream.authorized ? 'authorized' : 'unauthorized'
  cleartextStream.write "welcome!\n"
  cleartextStream.setEncoding 'utf8'
  cleartextStream.pipe cleartextStream

server.listen 8888, () -> console.log 'server bound'
