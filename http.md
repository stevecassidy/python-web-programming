## HTTP {#http}

In 1991 Tim Berners-Lee invented the World Wide Web. He was building on the existing technology of the Internet that allowed computers to exchange information around the world. His invention consisted essentially of three things: the Hypertext Transfer Protocol (HTTP), the Universal Resource Locator (URL) and the Hypertext Markup Language (HTML). HTTP is the language that a web client (your browser) talks to a web server to ask for a page and get the response back. It&#039;s a protocol, just like TCP/IP, but it&#039;s a much higher level protocol and it&#039;s one that we need to understand very well as web programmers.

HTTP requires that we first establish a point-to-point connection between a client (who is sending a request) and a server (who will fulfil the request if possible). This connection is usually via TCP/IP over the Internet but could also be over any other communication medium such as [bluetooth](http://code.google.com/p/bt-http-server/). Once the connection is established, the conversation can begin.

One of the important features of HTTP is that it is a simple, text based protocol. The request and response consist of a number of lines of text in a well defined format. Here is an example request that might be sent to a server:

<pre class="example">GET /storefront.html  HTTP/1.1
Host: store.example.com
Accept: text/*

</pre>

The first word in the request is always one of the defined _HTTP verbs_ (most frequently GET, HEAD or POST, we&#039;ll explore these in more detail later). A GET request asks the server to return the given resource, in this case &#039;/storefront.html&#039; which is probably an HTML file stored somewhere on the server. The last part of the first line (HTTP/1.1) defines the version of the standard that we are using; there was a version 1.0 but most modern browsers will use 1.1\. The remaining lines of the request include other _headers_ that qualify the request in some way. The _Host_ header is required and denotes the server that the request is being sent to. The Accept header defines what kinds of document we&#039;d like in return; in this case, any kind of text document is ok. The request ends with a blank line, which is how the server knows that all headers have been received.

The request is received and processed by the server and a response is sent back to the client containing the web page that was asked for. Again the format of the response is easy to understand:

<pre class="example">HTTP/1.1  200 OK
Content-Type: text/html

&lt;html&gt;
...etc...
</pre>

The first word of the response must be HTTP/1.1, the remainder of the first line contains a response code (200) and explanation (OK) in this case saying everything is fine, here&#039;s the page you asked for. The second header here defines the type of document being returned (it&#039;s an HTML page). There is then a blank line which ends the headers (as with the request) and the HTML content is then sent.

A real request and response pair will have many more headers than this but their format follows this basic pattern: header lines followed by a blank line and an optional body. The point here is that HTTP is a very simple conversation between web client and server.

One important feature of HTTP is that each request/response pair is independent of every other. This means that all the information about your request must be included in the request headers; the server doesn&#039;t remember anything you told it last time. This is one reason that HTTP and the web have been so successful. It is very easy to implement an HTTP server and it can be done on very small devices. This might be one of the reasons why the Web succeeded where other similar systems failed. Since the protocol is so simple, it was easy to write a web server and many people did. This meant that the web was used by many small groups to publish content, forming the groundswell that led to institutional and corporate adoption.

We&#039;ll look at HTTP in more detail later, for now the take home message is:

*   HTTP is a simple text based protocol
*   The client (browser) sends a request to the server
*   The server receives the request and returns a response
*   The server doesn&#039;t need to remember the client - every request is independant.
*   The simple nature of HTTP makes it easy to understand and makes writing web servers relatively easy.