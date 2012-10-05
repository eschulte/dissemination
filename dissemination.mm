.ce
A System for distributed information dissemination
.ce
<dissemination.txt>

.H 1 "Abstract"    \"  See: "Instructions to RFC Authors [RFC2223BIS]"

A distributed system for the dissemination of messages.  The core of
the system is a loose network of servers which share messages similar
in architecture to Usenet.  Messages are serialized as JSON hashes.
Messages are signed or encrypted using GPG public and private keys.
The primary goals are simplicity, security, privacy, and robust
operation.

.H 1 "Introduction"
A distributed system through which named or anonymous users can
disseminate open, signed, or encrypted messages.

Think of this as a distributed twitter, running on top of Usenet's
architecture, using JSON as the data exchange format and GPG public
and private keys for user authentication and encryption.

.H 1 "Technical Overview"

The main components of this system are \fBusers\fR, \fBmessages\fR,
and \fBservers\fR.  Users share messages between each other, and
servers are used to transport and store messages.  Each of these
components are addressed below.

.H 2 "Users"

All messages are either anonymous or have a GPG signature.  There need
be no idea of a "user" in the dissemination system beyond GPG
signatures and signatories.  However, it may be worthwhile to add a
distributed users table, such a table could associate each user with
some of the following (although I like the idea of not doing anything
with beyond what is provided by the existing GPG web of trust system).

.BL
.LI
unique short human readable and writable name
.LI
real name (must be optional if exists)
.LI
URL
.LI
small picture
.LI
other stuff...
.LI
arbitrary key-value pairs
.EL

.H 2 "Messages"

A message is a JSON key-value store (sometimes called an object,
record, struct, dictionary, map, hash or associative array) with some
minimal rules about which keys are required and when.

.H 3 "Signing and Encryption"

Signatures and encryption should apply across as much of each message
as possible (e.g., date, sender, and recipients, not just contents).

Every message will be assigned a hash based on its contents.  This
hash is calculated as the sha1sum of the JSON representation of the
entire message in canonical order (meaning with the keys sorted).
This hash should then be added to the top-level message HASH before
storage or dissemination.

In addition, the following delimits the minimum required keys for each
of the three possible message types; signed messages, signed and
encrypted messages, and anonymous messages.

.BL
.LI
Signed messages must contain the following, but in addition may
include any other arbitrary key-value pairs.

.TS
tab(:);
r|l.
Key:Description
_
keys:JSON array of the keys in the order
    :\^they are signed.
signatory:Identifier of the signatory readable by
         :\^GPG.
signature:ASCII armor signature of the concatenated
         :\^values of keys.
.TE

.LI
Encrypted messages must contain exactly the following keys.  The value
of the encrypted portion would likely be another JSON key-value store
holding any arbitrary key-value pairs.

.TS
tab(:);
r|l.
Key:Description
_
recipients:A list of the recipients
encrypted:ASCII armor encrypted blob of arbitrary
         :\^contents.
.TE

.LI
Signed and Encrypted messages are like encrypted messages but they may
contain a sender field, and the encrypted blob must also be signed by
GPG.

.LI
Anonymous messages may contain any arbitrary JSON keys-value pairs.
.EL

.H 3 "Standard keys"

Only the encryption and signature keys mentioned above are required
there are some standard keys.  The following are recommended as
standard key names for common message components.  All are optional.

.TS
tab(:);
r|l.
Key:Description
_
contents:The actual content of the message.
date:Specifies when the message was posted.
TTL:Or "time to live" specifies the maximum time
   :\^the message may be preserved by a server.
subject:A brief subject or title.
.TE

.H 3 "References (internal and external)"

There are times when you want to reference another part of the same
message, e.g., when you want to include images to be references from
an html portion.  What should the syntax be for this?  Are existing
email mime rules sufficiently powerful to handle this?

Similarly it may be that once message may want to reference the
contents of another message (e.g., a reply, a discussion thread, or a
reference to content which has a different signatory or is encrypted
for a different subset of recipients).

Some form of message reference (with both internal and external
syntax) should be specified in the standard.  I currently have no
strong feelings on the form or syntax of such references.

.H 2 "Servers"

Server distribute, persist and provide for discovery and download of
messages.

.H 3 "Distribution of Messages"

Users may upload and download messages to/from servers, and servers
may exchange information betwixt themselves.

Unlike in Usenet it would not be expected that every message would
eventually be represented on every server.  While hopefully some
servers would seek to disseminate every generally distributed message
in the system it would be possible to servers to be dedicated to
particular topics or user groups and handle only related messages.

There should be support for compressing and encrypting inter-server
communication (e.g. via GZIP and SSL respectively).

.H 3 "Message persistence"

Servers are under no obligation to store messages for any length of
time.  The only requirement is that the TTL key of any message is
respected if present.

.H 3 "Organization and discovery of Messages"

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

.H 3 "Possible types of servers"

.BL
.LI
A "general" server would attempt to provide access to every publicly
disseminated message.  Hopefully a collection of general servers would
form the distributed core of this system and their contents would
constitute the global public message contents.
.LI
A "topic" or "community" server may not perform any message exchange
with other servers, or may only exchange messages with a specific
topic or community of servers.  Such servers may only allow uploads of
specific messages discriminated by signatory or perhaps by content or
moderator.
.LI
A "personal" server may only post messages from a single signatory and
may do no inter-server communication whatsoever.  Such a server could
serve as a personal "home" on the web, like a homepage.

Using message references numerous messages could be presented in a
unified place (or page or view).  Such a personal presence on the web
may have numerous advantages over a static home page.

Every piece of content would be signed.  Content could easily be added
through the addition of messages.  Messages encrypted for particular
groups could be used to display different information to different
groups of readers.  Such a personal message server could serve the
same role as a Facebook page (at least as I understand Facebook, I've
never used it myself).
.EL

.H 1 "Robustness"

Robustness of operation include continued operation of the system as a
whole, and persistence of individual messages.  Both are attained
through spatial distribution and the lack of single points of failure.
All servers are peers, and each server is capable of serving any
message.  There is no single location at which a message exists, so to
remove a message from the system every copy of the message (server
side or client side) must be removed from the system.

.H 1 "Privacy Considerations"

GPG allows for the encryption of messages sent between users.
Currently the only way to target a message at a recipient is to
encrypt the message for that recipient.  By requiring the use of GPG
encryption of messages on the client side this framework should
greatly increase privacy over email (which is normally unencrypted)
and other communication systems in which servers must be trusted with
private contents.

.H 2 "Privacy of Meta-information"

The meta-information of the communication (who communicated with who
and when) is an increasingly common target of surveillance.  Such
information is often easier to collect without a warrant as it does
not include the contents communication.

Is there a way to send an encrypted message to a recipient, without
exposing either the identity of the sender or of the recipient?  In a
system with potentially malicious servers, this question reduces to
the search for a technique by which a user can both;

.AL
.LI
search through the messages on a server to identify which messages are
encrypted for the user in question, and
.LI
download messages from a server anonymously.
.LE

Anonymous search seems like it could be a difficult problem.  The
sender of the encrypted message would have to encrypt the names of the
recipients in such a way that they can only be decrypted by the
recipients (this can be done with standard GPG).  However, as it is
unfeasible for the user to decrypt \fBevery\fR message on a public
server there must be a way for a server to perform the search for the
recipient without knowing either (1) the encrypted search term or (2)
the encrypted contents (e.g., list of recipients) being searched.

How about using homologous encryption?  The sender and the recipient
each have access to their own private keys, and the other's public
key.  Is this enough shared information for the sender and recipient
to encrypt some token (say the recipient's name) homologously, such
that; (1) the recipient can submit her encrypted token to the server,
(2) the server can search for a matching token across encrypted fields
in multiple messages without any knowledge of the value of the token,
and ideally (3) the server can not encrypt a term (such as the
recipients name, or a banned search term) and then search for that
encrypted term.

.H 1 "Security Considerations"

I'm sure there are some, but who knows what.  Any with JSON parsing or
GPG signature verification or decryption could be issues here.  Many
Usenet security issues could also be relevant here.

.H 1 "Tools"

Here is a provisional list of those tools which should exist in some
form to form a proof of concept that this idea has legs.  So far the
first and the last exist.

.BL
.LI
A message server.  Currently a node server does exist and GPG bindings
for node allowing message signature verification have been written.
.LI
A web interface to a message server.  This would require a way of
calling GPG from within the browser to verify signatures, to decrypt
messages, and to encrypt and sign outgoing messages.
.LI
Another web front end allowing for the assembly of messages with html
content into web pages.  This would provide for easily updated web
pages with strict access controls based on the subset of the available
messages which the reading has permission to decrypt.
.LI
Command line tools for browsing local and remote message repositories,
and for encoding and decoding messages.
.LE

.TC
