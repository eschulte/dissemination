# set USER and COUCH_PASS in your environment

all: push

.PHONY: push

%.js: %.coffee
	coffee -c $<

push: app.js attachments/site.js attachments/site.css attachments/lib/dis.js
	couchapp push app.js http://$(USER):$(COUCH_PASS)@localhost:5984/foo
