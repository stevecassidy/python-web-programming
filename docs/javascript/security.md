# Javascript Security

Javascript is a programming language with the power of any other programming
language that can be used to write complex applications.  The interpreter for
this language is built in to your web browser running on your local computer and
Javascript programs are downloaded from the web when they are linked to web
pages and executed.   Taken at face value, this seems like a recipe for disaster
from a security perspective.  We download random code from the net and run it on
our local machine.  These days we know we should not do this because there will
always be a malicious actor ready to exploit this to deliver code that will
compromise your system in some way.  So, why is it ok to download Javascript
code and run it? What does the Javascript environment do to prevent bad things
happening?  

There have been two main models for running downloaded code in the web
environment: one based on trust certification and one based on restricted
execution environments. In the trust model (used by Microsoft ActiveX), any code
that was to be executed had to be digitally signed by the originating site,
identifying it as definitely coming from that provider. If you trusted Microsoft
then you would accept any code signed by them to run in your browser. The
problem with this is that it was too easy to set yourself up as a provider and
most people would blindly trust everything if it offered them something
interesting.

The alternative is to make it so that the code that was downloaded could not do
bad things by restricting the environment that it is run in. This is the
approach taken by Javascript.

## Restricted Execution Environment

When you run Javascript in your browser it operates in a _sandbox_ environment.
The running code only has access to a limited set of resources on your machine.
For example, it is not allowed to write to the file system and it has only
limited access to your display. The general principle is that the Javascript
code should have as little access to resources as possible and that all access
is considered as a possible attack vector and carefully controlled.  

### File System Access

Unlike most programming languages, Javascript has no native file handling
primitives. You can't open a file for reading or writing in Javascript.  The
only access you have to the file system is via the
[FileList](https://developer.mozilla.org/en-US/docs/Web/API/FileList) interface
that represents files that the user has chosen through an interactive dialogue -
that is, the user must be involved in giving explicit access to files for
_reading_ only.   In the [node.js](https://nodejs.org) interpreter that is
intended to run scripts on your laptop or on a server, there is a [special
filesystem module](https://nodejs.org/docs/latest/api/fs.html) that needs to be
loaded to provide access to files. So, Javascript prevents malicious attacks on
the file system by preventing any kind of access at a very low level in the
language.

### Networking

Javascript can make network requests in a number of ways.  This could be
explicit via an `XMLHttpRequest` or indirectly by inserting a fragment of HTML
including a `<script src='...'></script>` or `<img src='...'>` tag referencing a
remote resource. This means that network access is limited to using a protocol
like HTTP or FTP rather than allowing arbitrary protocols (eg. SMTP for mail or
SNMP for network management).

Any request made by Javascript is subject to a Same Origin Policy which
restricts the requests that can be made to servers other than the one that was
the origin of the page. In general, it is ok for the script to _send_ data to a
different domain but reading data is restricted.

Another mechanism is the newer [Web Socket
API](https://developer.mozilla.org/en-US/docs/Web/API/Websockets_API) which uses
the WSS protocol to open a bidirectional connection between client and server.
WSS communication is not subject to Cross Origin restrictions but again must use
the high level WSS protocol for all requests.

### Access to the Browser

Javascript code running in the browser has access to the current page via the
`document` global variable and to the browser window via `window`.  Importantly,
these refer only to the contents of one browser tab or window. There is no way
for a script to reference any content from any other tab or even to know that
another tab exists.

This prevents a possible attack where a malicious script in one page reads
sensitive data from another page in another tab.  

Javascript can also access cookies that have been set for the current site. The
`document.cookie` property contains all of the cookies that have been sent by
the current site. Javascript can even update this list to add a new cookie that
will be sent back with any future requests. Importantly though, a script has no
access at all to cookies from any domain other than the origin domain for the
page it is running in.  This means that a script can't grab the cookie
associated with my banking site and use it to make requests on my behalf.

In general, a script is limited to accessing information about the page it is
running on and the domain that this page was requested from.  
