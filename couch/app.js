var couchapp = require('couchapp');

var ddoc = {
    _id:'_design/app'
  , views: {}
  , lists: {}
  , shows: {}
};

module.exports = ddoc;


/// Validation functions

ddoc.validate_doc_update = function(new_doc, old_doc, user_ctx){
  // TODO: The hash must match the actual hash value of the contents
  // TODO: If there is an author, the rest must be signed
  // nothing can change, ever.
  if(old_doc && toJSON(old_doc) != toJSON(new_doc))
  { throw({ forbidden : "Documents are immutable." }); }

  return true;
}


/// Views (return documents)

// All documents -- http://localhost:5984/foo/_design/app/_view/all
ddoc.views.all = {
  map: function(doc) { emit(doc._id, doc); } }

// With dates -- http://localhost:5984/foo/_design/app/_view/date
ddoc.views.date = {
  map: function(doc) { if (doc.date) { emit(doc.date, doc)}; } }


/// Lists (generate html from a view)

// http://localhost:5984/foo/_design/app/_list/w_link/all
// http://localhost:5984/foo/_design/app/_list/w_link/date
ddoc.lists.w_link = function(doc, req) {
  start({ headers: {"Content-type": "text/html"} });
  // list all documents
  send("<dl>\n");
  while(row = getRow()) {
    send("\t<dt><a href=\"../../_show/it/" + row.value._id + "\">"+row.key+"</a></dt>\n");
    if (row.value.content) { send("\t<dd>" + row.value.content + "</dd>\n"); }
    else { send("\t<dd>--</dd>\n"); } }
  send("</dl>\n");
  // a form to add a new document
  send("<p><span style=\"color:red;\">TODO</span>: make it possible to add new _id'd documents with a PUT.</p>"); }


/// Shows (view a document)

// http://localhost:5984/foo/_design/app/_show/it/test
ddoc.shows.it = function(doc, req) {
  if (doc.content) { body = "<p id='thing' class='content'>" + doc.content + "</p>\n"; }
  else { body = "<p>no content</p>"; }
  return {
    headers: {"Content-type": "text/html"},
    body: body }; }
