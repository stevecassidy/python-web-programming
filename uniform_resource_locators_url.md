## Uniform Resource Locators: URL {#uniform-resource-locators-url}

Another part of Tim Berners-Lee&#039;s invention is the Uniform Resource Locator, URL. These days, URLs are ubiquitous. We see them on advertisments, on the TV, we send them to each other in email, even reference them in books and reports. Most organisations today will have at least one top-level URL for their website and often have many connected to particular services, departments or advertising campaigns.

Let&#039;s look at the anatomy of a URL:

<pre>http://www.mq.edu.au/about/profile/history.html
      </pre>

The first part of the URL is `http://`, this is often left out when URLs are written, so we might see the above as `www.mq.edu.au/about/profile/history.html`. This will work when you type it into your web browser because the browser will assume you meant this as an HTTP URL. However, if we are being pedantic, the prefix is required as it tells us something about the web address - that we should use the HTTP protocol to access it.

URLs are not only useful for HTTP addresses. Other _schemes_ are allowed and they tell the client how to get access to the content that the URL describes. The most common you will see is `https://` which is the secure variant of HTTP (we&#039;ll find out about that later). HTTPS uses the same protocol as HTTP but over a secure connection so that information that is exchanged can&#039;t be intercepted. Another scheme is `ftp://` which tells the browser to use the older FTP protocol to access the content. Finally, you might see a `mailto` URL which allows us to write a link that triggers the browser to start composing an email message. This has a slightly different form: `mailto:Steve.Cassidy@mq.edu.au` but it&#039;s still a URL. In fact, the pattern looks like this:

<pre>&lt;scheme&gt;:&lt;scheme-specific-part&gt;
</pre>

For the HTTP scheme the pattern is:

<pre>http://&lt;net_loc&gt;/&lt;path&gt;;&lt;params&gt;?&lt;query&gt;#&lt;fragment&gt;
</pre>

The first part `&lt;net_loc&gt;` is the network location of the resource: the domain name of the web server that holds the web page we want. This is preceded by two forward slashes and followed by a single forward slash. Then follows the `&lt;path&gt;` which the server will use to identify which page we want. The `;&lt;params&gt;?&lt;query&gt;#&lt;fragment&gt;` are used to further qualify the resource that we want; we&#039;ll see some examples of how they are used later in the book.

The URL is a unique form of identifier in that it has two roles. First, it identifies a document, video or music file that&#039;s out on the web (we call these things _resources_). Each resource has a unique URL and you can refer to them via the URL. If we two people refer to the same URL, then they know they have read the same document. Secondly, the URL contains enough information for a web client to retrieve a copy of the resource. The client can use the scheme defined (HTTP) to connect to the server and send an HTTP request for the path part of the URL.

There are other kinds of formal identifier that don&#039;t have this second property. For example, every book has an ISBN (International Standard Book Number) which uniquely identifies it. However, the ISBN contains no information about how to get a copy of the book. To do so, you&#039;d need to look up the ISBN in a catalogue which might tell you who the publisher was and then contact them for a copy. Alternately you could go to a book-shop or library and use their catalogue to find the book. With a URL, there&#039;s no need for a catalogue or third party service to decode the identifier. The information on how to retrieve the resource is right there in the Uniform Resource Locator.

The [Internet Engineering Task Force (IETF)](http://www.ietf.org/) is as close as we get to a governing body for the Internet and it&#039;s home to many of the standards that define how the Internet and the Web work. The standards documents are called _Request for Comments_ or RFC, a name which reflects the democratic nature of the early Internet. [RFC2068](http://datatracker.ietf.org/doc/rfc2068/) defines HTTP version 1.1 and [RFC1738](http://datatracker.ietf.org/doc/rfc1738/) defines the URL. Look out also for [RFC2324](http://datatracker.ietf.org/doc/rfc2324/) which can be relevant after a long coding session.

There&#039;s another similar term that is sometimes used instead of URL: Uniform Resource Identifier (URI). URI is actually a more general term that includes URLs and Universal Resource Names (URNs). URNs are identifiers that don&#039;t contain any locator information such as the ISBN. They have a formal syntax so I can cite a particular ISBN as a URN as URN:ISBN:978-0-395-36341-6 (an example from the [IETF RFC3187](http://tools.ietf.org/html/draft-ietf-urnbis-rfc3187bis-isbn-urn-01) document that defines the standard). As explained above, we need a third party service to resolve a URN into a real location (a URL). You might see the term URI used in discussions of web technologies; it is often used instead of URL but generally means the same thing if we&#039;re talking about HTTP based services.

Since URLs are both names and addresses it becomes important that once you put a resource on the web, it stays there. This is discussed in Tim Berners-Lee&#039;s paper called &quot;[Cool URIs don&#039;t change](http://www.w3.org/Provider/Style/URI)&quot;. It&#039;s a principle that all web designers should bear in mind as it is easy to violate as we re-build old web-sites.