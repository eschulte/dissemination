var couchapp = require('couchapp');

var ddoc = {
    _id:'_design/app'
  , views: {}
  , lists: {}
  , shows: {}
};

module.exports = ddoc;

// http://localhost:5984/foo/_design/app/_view/date
ddoc.views.date = {
  map: function(doc) {
    if(doc.date && doc.content){
      emit(doc.date, doc.content);
    }
  }
}

// http://localhost:5984/foo/_design/app/_list/dd/date
ddoc.lists.dd = function(doc, req) {
  start({ headers: {"Content-type": "text/html"} });
  send("<dl>\n");
  while(row = getRow()) {
    send("\t<dt>" + row.key + "</dt>\n");
    send("\t<dd>" + row.value + "</dd>\n");
  }
  send("</dl>\n")
}

// http://localhost:5984/foo/_design/app/_show/it/test
ddoc.shows.it = function(doc, req) {
  return {
    headers: {"Content-type": "text/html"},
    body: "<p id='thing' class='content'>" + doc.content + "</p>\n"
  }
}
