couchapp = require 'couchapp'
path     = require 'path'

ddoc =
  _id:'_design/app'
  rewrites: [ # http://localhost:5984/foo/_design/app/_rewrite/
    { from:'/',      to:'index.html' }
    { from:'/api',   to:'../../' }
    { from:'/api/*', to:'../../*' }
    { from:'/*',     to:'*' }
    { from:'msg/*',  to:'_show/it/*' }
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


# Filters
ddoc.filters = chats: (doc, req) -> true if doc.created_at


# Views (return documents)
ddoc.views.chats = map: (doc) -> emit doc.created_at, doc if (doc.created_at and doc.author)


# Shows (view a document)
ddoc.shows.it = (doc, req) ->
    headers: { "Content-type": "text/html" }
    body: "<p>#{if (doc.content) then doc.content else '--'}</p>\n"
