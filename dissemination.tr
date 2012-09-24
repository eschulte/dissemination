.ce
A System for distributed information dissemination
.ce
<dissemination.txt>

.H 1 "Abstract"    \"  See: "Instructions to RFC Authors [RFC2223BIS]"

A distributed system for the dissemination of messages.  The core of
the system is a dynamic network of servers which share messages
similar in architecture to Usenet.  Messages are serialized as JSON
hashes.  Messages may be signed or encrypted using GPG public and
private keys.  The primary goals are simplicity, security, privacy,
and robust operation.

.H 1 "Introduction"
A distributed system through which named or anonymous users can
disseminate open, signed, or encrypted messages.

Think of this as a distributed twitter, running on top of Usenet's
architecture, using JSON as the data exchange format and GPG public
and private keys for user authentication and encryption.

.H 1 "Overview"

.H 2 "Users"

All messages are either anonymous or have a GPG signature.  There need
be no idea of a "user" in the dissemination system beyond GPG
signatures and signatories.  Maybe it would be worthwhile to add a
distributed users table to be distributed between servers, such a
table could associate each user with some of the following.

.BL
.LI
unique short human readable and writable name
.LI
real name (must be optional if exists)
.LI
URL
.LI
arbitrary text
.LI
small picture
.LI
or arbitrary fields
.EL

I kind of like the idea of not doing anything with users, but just
letting the existing GPG web of trust system handle everything.

.H 1 "Structure of a Message"

A message is just a key-value store with some rules about which keys
are required and when.

.H 2 "Signing and Encryption"

Will want signature and encryption to apply to as much of the message
(including meta data) as possible.  What is the minimum required to
show for each use case.

Signed messages must contain the following keys but may include more.

.TS
tab(:);
r|l.
Key:Description
_
keys:JSON array of the keys in the order
    :\^they are signed.
signatory:Identifier of the signatory readable by GPG.
signature:ASCII armor signature of the concatenated
         :\^values of keys.
.TE


Encrypted messages contain exactly the following keys.

.TS
tab(:);
r|l.
Key:Description
_
recipients:A list of the recipients
encrypted:ASCII armor encrypted blob of arbitrary
         :\^contents.
.TE

Signed and Encrypted messages are like encrypted messages but they may
contain a sender field, and the encrypted blob must also be signed by
GPG.

Anonymous messages may contain arbitrary JSON keys and values.

.H 2 "Other optional keys?"

Although no other keys would be required, which could be optional and
useful?

.TS
tab(:);
r|l.
Key:Description
_
date:Specifies when the message was posted.
TTL:Or "time to live" specifies the maximum time
   :\^the message may be preserved by a server.
subject:Obviously this could be useful.
.TE

.H 2 "Internal references"

There are times when you want to reference another part of the same
message, e.g., when you want to include images to be references from
an html portion.  What should the syntax be for this?  Are existing
email mime rules sufficiently powerful enough to handle this?

This should probably be set in the standard.

.H 1 "Distribution of Messages"

Along the same lines as Usenet.  Users connect to servers, and servers
exchange information betwixt themselves.

The biggest difference between this and usenet would be the
expectation that the inter-server exchange is somewhat more
timely/real-time, i.e., not just 2 batch transfers per day.

All messages should be compressed when sent between servers or servers
and clients.  Use gzip and gunzip to handle this encryption.

.H 1 "Organization and discovery of Messages"

Methods for the discovery of messages.

.BL
.LI
sender
.LI
keyword search
.LI
messages may target a user
.LI
messages may target a group
.LI
arbitrarily extensible headers?
.LI
servers can add their own discovery methods
.EL

.H 1 "Privacy Considerations"

.H 2 "Communication Meta-information"

The meta-information of communication consisting of records of who
communicated with who at what times is an increasingly popular target
of surveillance.  Governments have requested such records from
twitter, and since the requested information does not include the
contents of the communication the requests are subject to less strict
legal prohibitions.

Is there a way to send an encrypted message to a recipient, without
exposing either the identity of the sender or of the recipient?  In a
system with potentially malicious servers, this question reduces to
the search for a technique by which a user can both

.AL
.LI
Search through the messages on a server to identify which messages are
encrypted for the user in question.
.LI
Download messages from a server anonymously.
.LE

Anonymous search seems like it could be a difficult problem.  The
sender of the encrypted message would have to encrypt the names of the
recipients in such a way that they can only be decrypted by the
recipients (this can be done with standard GPG).  However, as it is
unfeasible for the user to decrypt \fBevery\fR message on a public
server there must be a way for a server to perform the search for the
recipient without knowing either (1) the recipient name being searched
for or (2) the lists of recipient names in each message.

How about using homologous encryption?  The sender encrypts and the
recipient each have access to their own private keys, and the other's
public key.  Is this enough shared information for the sender and
recipient to encrypt some token (probably the recipient's name) using
a form of homologous encryption, s.t., recipient can submit her
encrypted token to the server and the server can search for a matching
token in any of its files without having access to the value of the
token?

TODO: search for "homologous encryption" and "shared secrets" with
respect to GPG public/private key pairs.

TODO: look into GPG's "--hidden-recipient" option.  Does this do
anything more than simply encrypt the recipient's name?

.H 1 "Security Considerations"

I'm sure there are some, but who knows what.  Any with JSON parsing or
GPG signature verification or decryption could be issues here.  Many
Usenet security issues could also be relevant here.

.TC
