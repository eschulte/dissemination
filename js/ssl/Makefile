all: start

%.js: %.coffee
	coffee -c $<

dis-key.pem:
	openssl genrsa -out $@ 1024

dis-csr.pem: dis-key.pem
	openssl req -new -key $< -out $@

dis-cert.pem: dis-key.pem dis-csr.pem
	openssl x509 -req -in dis-csr.pem -signkey $< -out $@

start: server-ssl.js dis-key.pem dis-cert.pem
	node $^

clean:
	rm -f *.pem *.js
