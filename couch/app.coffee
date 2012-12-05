couchapp = require 'couchapp'
path     = require 'path'

ddoc =
  _id:'_design/app'
  rewrites: [ # http://localhost:5984/foo/_design/app/_rewrite/
    { from:'/',     to:'index.html' }
    { from:'msg/*', to:'_show/it/*' }
  ]
  views: {}
  lists: {}
  shows: {}

module.exports = ddoc


# load attachments
couchapp.loadAttachments ddoc, (path.join __dirname, 'attachments')


# Validation functions

ddoc.validate_doc_update = (new_doc, old_doc, user_ctx) ->
  # TODO: The hash must match the actual hash value of the contents
  # TODO: If there is an author, the rest must be signed
  # nothing can change, ever.
  if (old_doc and (toJSON old_doc) != (toJSON new_doc))
    throw forbidden: "Documents are immutable."


# Views (return documents)
# http://localhost:5984/foo/_design/app/_view/all
# http://localhost:5984/foo/_design/app/_view/date
ddoc.views.all  = map: (doc) -> emit doc._id, doc
ddoc.views.date = map: (doc) -> emit doc.date, doc if (doc.date)


# Lists (generate html from a view)
# http://localhost:5984/foo/_design/app/_list/w_link/all
# http://localhost:5984/foo/_design/app/_list/w_link/date
ddoc.lists.w_link = (doc, req) ->
  start headers: "Content-type": "text/html"
  # list all documents
  send "<dl>\n"
  while row = getRow()
    send "<dt><a href=\"../../_show/it/#{row.value._id}\">#{row.key}</a></dt>"
    send "<dd>#{if row.value.content then row.value.content else '--'}</dd>"
  send "</dl>"
  # a form to add a new document
  send "<p><span style=\"color:red;\">TODO</span>:"
  send "make it possible to add new _id'd documents with a PUT.</p>"


# Shows (view a document)
# http://localhost:5984/foo/_design/app/_show/it/test
ddoc.shows.it = (doc, req) ->
    headers: {"Content-type": "text/html"}
    body: "<p>#{if (doc.content) then doc.content else '--'}</p>\n"
