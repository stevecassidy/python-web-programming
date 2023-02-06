

Web Data for Machines
=====================



Not Just HTML
-------------

HTML is the language of the web, it was invented at the same time as the
HTTP protocol and is the format we think of when we think of web
documents. But HTTP is not limited to exchanging HTML documents. Even
back in the early days, it was used to exchange Postscript (a precursor
to PDF) versions of scientific papers. Now, it is used to deliver
images, video, audio, and every imaginable kind of digital resource.

When we make an HTTP request we ask for a particular resource named by a
URL. The name of the URL doesn't need to be related to the kind of data
that we will get back. In some cases it is clear what is meant. So if I
ask for `http://example.org/images/cats.jpg` I would expect to get back
an image in JPEG format. In other cases it is not obvious what would
come back, eg. `http://example.org/animals/cats` could be an HTML list
of cats or a video about them or indeed an image. However, nothing in
the URL name really defines what comes back. The server is free to
return an HTML page for the first URL even though it ends in `jpg`. The
way that the client (browser) knows what has been returned is by a
header set in the HTTP response: Content-Type.

The Content-Type header in the response is used by the server to tell
the client what kind of content is being returned. The value of this
header is known as a *MIME type* (MIME stands for Multi-Purpose Internet
Mail Extensions, the standard originated to deal with email
attachments). A MIME type consists of two parts, a type and a subtype.
The type of a regular web page is `text/html` while a simple text file
would be `text/plain`; images might be `image/jpeg` or `image/png`.
Other examples are `text/css`, `video/mp4` `application/javascript` or
`application/pdf`.

When the client receives a response, it can look at this header to work
out how to treat the body of the response. Your web browser will use it
to work out whether to feed the response to the HTML parser, display it
as an embedded image, play a video or apply it as a stylesheet. If the
browser doesn't know what to do with a particular MIME type it will
prompt the user to save the response as a document on disk.

If we are writing scripts to crawl the web we can also use the
Content-Type header to work out what to do. The crawler script in the
previous chapter assumed that every document that was returned would be
HTML and so tried to parse it and find links in it. If it were to get a
CSS stylesheet or a PDF file returned, the parse would fail and possibly
crash the system. Looking at the Content-Type header would allow it to
only parse the HTML files that were returned. We might also write a
crawler to save a particular kind of content. For example, one that
looked for links that resolved to image files so that we could save a
local copy of all of the images on a site.


What Would You Prefer?
----------------------

<a name="accept"></a>

A very important thing to recognise about the web is that a URL is an
abstract name for a *resource*. As we said above, the URL doesn't imply
anything about the format that this resource will be returned in. In
some cases there might be multiple ways to return the same resource -
multiple representations of the same thing. For example, my CV might be
available as an HTML web page or as a nice PDF formatted for printing.
The information is the same in each case but the format is different to
support a different kind of use. I could give these different URLs
(`http://example.org/cv.html` and `http://example.org/cv.pdf`) but since
they really are the same resource in a real sense, it might be better to
use use `http://example.org/cv` and allow the client to let me know
which format they would prefer.

This is made possible in HTTP with the `Accept` header in a request. The
value of this header is a string that lists the formats that the client
will accept as MIME types or as patterns (see the
[specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1)).
So if I really only understand HTML I would use `text/html` but if I
also understand css, plain text and a few image types I would use
`text/html, text/css, text/plain, image/jpg, image/png`. If I am happy
to accept any text format I could say `text/*` and if I really don't
care what I get I can use `*/*`. The Accept header can also include
preferences; the default header for the Firefox browser is
`text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8` This
means that two versions of HTML are preferred but XML is ok with a
weight (quality) of 0.9 (`application/xml;q=0.9`) and as a fallback, it
will accept anything (`*/*;q=0.8`).

Using the information in the Accept header, the server application can
decide what version of the resource to return if it has more than one.
In this case if we have an HTML version and a PDF version we'd send the
HTML since it is preferred over PDF (which only matches `*/*` with a
lower weight of 0.8).

Using the Accept header to get alternate versions of resources is called
[Content
Negotiation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation).
Most servers and applications don't do this very often as in most cases
each page or resource has a single representation. Where it does come in
useful is when we look at machine to machine requests. In the previous
chapter we looked at using scripts to request HTML pages and scrape data
from the content. A much better approach would be to tell the server
that we'd like something more easily processable, and we can use Content
Negotiation to achieve this. In this chapter we'll look at what kind of
data representation is more useful for machine processing. Later we'll
see how to implement content negotiation in a Bottle script.


XML
---

### History: SGML and HTML

XML was introduced in 1997 as a new family of markup languages that
would replace the older HTML and SGML standards. SGML was an old
standard started by IBM in the 1960s to encode their technical
documentation in a machine readable way. The SGML standard really
defined a way of defining specific markup languages that used the now
familiar angle bracket &lt;tag&gt; notation. A project would define a
set of tags and the way that they were allowed to nest (a book will have
a table of contents and one or more chapters...) and write this as a
Document Type Declaration (DTD). Authors could then write documents
using these tags and they could be checked against the DTD to ensure
they were properly structured. Processing code could then be written to
transform them to other formats, eg. for printing or display on a
screen. When Tim Berners Lee came to develop a markup language for the
web, he was inspired by SGML; later HTML was re-cast as an SGML markup
language with a DTD. All versions of HTML up to version 4 were published
with a corresponding DTD that could be used to validate an HTML document
using SGML technology. HTML5 abandons this idea of backward
compatibility with SGML.

One problem with SMGL was that it was very flexible in what it accepted.
Partly because it was intended to be written by people and so included a
number of short-cuts to make writing easier. An example of this is that
end-tags are optional in cases where they can be predicted from the
context. So in HTML, the DTD says that paragraphs can't contain other
paragraphs; so if add a paragraph tag inside a paragraph then it must
mean I intended to finish the last paragraph just before it. Another
example is for attributes that can only have one possible value it is
possible to omit the value all together; an example of this is the
`border` attribute in HTML. Here is some example HTML illustrating these
two shortcuts:

```html
<p> 
    One problem with SMGL was that it was very flexible in what it accepted. Partly because
    it was intended to be written by people and so included a number of short-cuts to make
    writing easier. 
    
<p border>
    An example of this is that end-tags are optional in cases where they
    can be predicted from the context. 
```

This is a problem when it comes to writing a parser that can process an
SGML document. The parser needs to know all of these possible shortcuts
and insert the 'obvious' tags and attribute values in the right place.
This makes parsers for SGML very complex and in fact there were never
very many parsers written; this stopped the widespread uptake of SGML in
applications.

### The XML Revolution

By 1997 the web was starting to gain momentum and it was seen that there
was a need to represent data for exchange on the web and to better
represent the *semantics* (meaning) of the data that was available on
the web. XML was a development of the older SGML standard (in fact it is
an [application profile](http://en.wikipedia.org/wiki/XML#History) of
SGML). It simplified the rules but retained a lot of the features of
SGML. XML still used angle brackets, tags, attributes etc. The rules of
XML were simplified so that it was no longer possible to omit an end tag
even if it was obvious from the context. Attributes must have a value
and must be enclosed in double or single quotes, etc. These changes
meant that writing a parser for XML was much easier than for SGML; the
first XML parsers were written very soon after the release of the
standard and many more followed.

The availability of XML meant that an application developer could define
their own markup language for use in data exchange instead of relying on
HTML or another generic standard. If I was publishing information about
books I could make the following XML available:

```xml
<booklist>
    <book>
        <title>Time and Tide</title>
        <author>Ima Writer</author>
        <publisher>Sharp and Pointy</publisher>
    </book>
    <book>
        <title>Again and Again</title>
        <author>June Bug</author>
        <publisher>Nice and Sweet</publisher>
    </book>
</booklist>
    
```

In comparison to an HTML encoding that might use a table for this
information, the XML version adds 'meaning' by using tag names that will
probably mean something to the programmer who reads this. It is possible
to write a DTD to describe the booklist XML format and that could define
exactly what each element meant, but even without a DTD, there is a
sense in which this format is *self documenting* to a degree. The
ability to write a DTD means that a group of developers who wanted to
exchange data could get together and agree on a standard XML document
type to use and then document this in a DTD that could be used to check
the documents.

The XML DTD provides a valuable property of the language: the ability to
check the validity of a document without having to understand any of the
data in it. A standard XML processor can take a document and a DTD and
check if it conforms. If so, the document is said to be *valid*. This is
a useful step because it means we can reject badly formed documents
without spending time processing them fully. If an XML document doesn't
have a DTD, then it can still be *well-formed* as long as it follows the
syntax rules of XML (proper nesting of tags, every start tag has an end
tag etc.). If a document is well formed then we can at least process it
with an XML parser. DTDs are optional with XML where they were required
for SGML documents.

### Using XML

We discussed parsing HTML in [the last chapter](crawling.md) and said
that since HTML is a tree structure, a natural thing for a parser to do
is return a tree-like data structure, usually called the Document Object
Model or DOM. Since XML is just like HMTL in this respect we also make
use of the DOM abstraction for XML document parsers. Python provides a
few XML parsers and two DOM based parsers namely
[xml.dom.minidom](https://docs.python.org/3/library/xml.dom.minidom.html)
and
[xml.etree.ElementTree](https://docs.python.org/3/library/xml.etree.elementtree.html#module-xml.etree.ElementTree).
The first of these uses the very standard DOM interface that is very
similar in different languages. So if you are skipping between
Javascript and Python then using this module will give you a similar way
to interact with XML documents in Python to the way that you will use in
Javascript.

Here is a simple example of some Python code to parse the sample book
list XML file shown above. This uses the `xml.dom.minidom` module to
first parse the document, then find all of the book elements and extract
the values from each property of the book.

```python
from xml.dom.minidom import parseString

# read the XML text from a file
with open("books.xml") as fd:
    xmltext = fd.read()

document = parseString(xmltext)

for book in document.getElementsByTagName('book'):
    title = book.getElementsByTagName('title')[0].firstChild.data
    author = book.getElementsByTagName('author')[0].firstChild.data
    publisher = book.getElementsByTagName('publisher')[0].firstChild.data
    
    print((title, author, publisher))
    
```

As you can see, handling XML is at the same time relatively simple since
we can navigate the tree quite easily, and quite long-winded, since the
code required to get the text from inside the element is quite long.
Given a known XML format it is relatively easy to write robust code to
extract the relevant information from the XML. In fact, given a DTD it
is possible to automatically generate code to parse documents that
conform to the DTD.

### XML In Practice

When XML was developed by the W3C the vision was that it would take over
from the earlier HTML standard as the language of the web. A new version
of HTML called XHTML was developed that translated the standard into XML
terms. XHTML documents follow the rules of XML so that end tags were
required and empty tags were written with the XML syntax `<br />`.
However, XHTML adoption was poor - many authors continued to copy and
paste HTML code or write what they understood to be correct without
checking with the standard. Eventually, the W3C decided to standardise
HTML version 5 outside of the SGML or XML worlds and the use of XML for
web pages is no longer promoted.

XML did get adopted in a wide range of applications. It is used for
configuration files for software applications, for storing documents
(Microsoft Office uses an XML format at the heart of the newer .docx,
.xlsx and .pptx formats) and for sending data between applications. This
last use is of interest to us in the context of the web since XML is
widely used to transmit machine readable information from web services
to programmatic web clients.

One of the major uses of XML on the web is in the
[SOAP](http://www.ibm.com/developerworks/webservices/tutorials/ws-understand-web-services1/ws-understand-web-services1.html)
standard for web services. SOAP defines a way of calling remote
procedures over the web. You send an XML document in a POST request to a
service endpoint with the procedure name and parameters, and the
endpoint calls the procedure and returns an XML result. SOAP is not a
topic for this book; in many ways it is not a web technology - just a
technology that uses HTTP as a communications medium. To understand that
statement, note that HTTP and the web is about making resources
available via URLs - each URL names a distinct resource and we can use
the HTTP operations (GET, POST, DELETE, etc.) to carry out operations on
the resource. SOAP bypasses this idea and just allows you to call
procedures on the server via a single SOAP endpoint URL. That URL
doesn't represent a resource, it's meaning is purely procedural.
However, SOAP is an important technology for interconnecting services
and is widely used in Business to Business (B2B) transactions.

While the XML documents in SOAP don't represent resources, there are
many applications where XML is used as an alternate representation to
provide machine readable versions of resources on the web. We've seen
how XML can be a more meaningful representation of data than when it is
embedded in an HTML document. If I want to implement a web application
that exposes some data to a client in a machine readable way, then XML
is a good choice. Take the example of a search engine. In general it
will return an HTML representation of the results of a search, but if
the client is a script rather than a browser, it could return an XML
version that used meaningful names for the parts of the data and omitted
all of the additional markup that was only needed to present the page in
the browser. An example could be:

```xml
<searchresults search="example" hits="301502" time="0.003">
    <hit>
        <url>http://example.org/one</url>
        <summary>This is what I found on this page...</summary>
    </hit>
    <hit>
        <url>http://example.org/two</url>
        <summary>This is what I found on this other page...</summary>
    </hit>
</searchresults>
    
```

A script could take this information and do whatever it wanted to
process it - for example the script might be interested in the ranking
of a particular site for a given set of search terms. In this case, the
XML representation is an alternative to the HTML version. We could
arrange for the application to serve this version if the [Accept
header](#accept) preferred XML to HTML and so use the same URL for
searches returning different formats of result.

Another use of XML is in sending data to web applications. In a normal
POST request, the Content-Type of the body of the request is
`application//x-www-form-urlencoded` meaning that it is a URL encoded
version of form data. However, it is possible to use an Content Type in
a POST body and in many cases XML is more appropriate than the URL
encoded format for sending data. One example might be when the data
being sent is quite large or has a complex structure. The URL encoding
is ok for simple property-value pairs but can't easily handle nested
structures. So, an application can be written to expect XML in the body
of a POST request and use an XML parser to extract data rather than the
standard form data parser.

Finally, it is possible to use a [CSS stylesheet with an XML
document](http://www.w3.org/Style/styling-XML.en.html) to make it more
human-readable in a web browser. Since there is no fixed XML vocabulary,
we can't link a stylesheet in the same way as in an HTML page (with the
`link` tag), so another mechanism is needed. XML uses a *processing
instruction* to reference a stylesheet. The stylesheet is just like one
for HTML except that any tag name is allowed and there are no default
rules (no paragraphs or tables) - all elements are inline by default so
if you want anything to be a block you need to say so explicitly. To add
a stylesheet to the book example above we would insert a processing
instruction:

```xml
<?xml-stylesheet href="style.css"?>
<booklist>
    <book>
        <title>Time and Tide</title>
        <author>Ima Writer</author>
        <publisher>Sharp and Pointy</publisher>
    </book>
    <book>
        <title>Again and Again</title>
        <author>June Bug</author>
        <publisher>Nice and Sweet</publisher>
    </book>
</booklist>
    
```

Here's a sample stylesheet that can be applied to this document - store
this in `style.css` and the above file in `books.xml` and you should be
able to view it in any web browser and see the stylesheet applied.

```xml
booklist, book, title, author, publisher{
    display: block;
}
booklist {
    width: 300px;
    border: 1px solid black;
    margin: auto;
}
book {
    padding: 2em;
}
title {
    font-size: large;
    font-weight: bold;
    text-align: center;
}
author {
    color: red;
}
publisher {
    color: green;
}
```

JSON
----

While XML provides an excellent solution for representing data in a
machine readable format, it has come in for a lot of criticism. One of
the main ones is that there is a lot of overhead in dealing with XML
data: it adds all of those start and end tags to the data meaning files
are bigger and it needs to be parsed which adds processing time. This
has been called the [angle bracket
tax](http://blog.codinghorror.com/xml-the-angle-bracket-tax/) (and see
[here for a
followup](http://blog.codinghorror.com/revisiting-the-xml-angle-bracket-tax/)).
Over time this has led to many people looking for alternatives to XML
that would be easier to process and perhaps easier to read. One format
that has now gained a lot of momentum is [JSON](http://www.json.org/).

JSON is the Javascript Object Notation. It is simply the way that
Javascript data is written to a file - in fact it is Javascript code
that could be executed to recreate a particular data structure. While it
originates in Javascript, it is now used to send data between many
different languages and most languages have a library that can parse
JSON data into a native data structure. A JSON structure is either a
list or a collection of name-value pairs. In Python these correspond to
lists and dictionaries. Here's a simple example of JSON representing the
same data as our book list XML example.

```json
[
    {
        "title": "Time and Tide",
        "author": "Ima Writer",
        "publisher": "Sharp and Pointy"
    },
    {
        "title": "Again and Again",
        "author": "June Bug",
        "publisher": "Nice and Sweet"
    }
]
    
```

This example encodes the data as a list with each element being a set of
name-value pairs. This can be read into Python with the following code:

```python
import json

with open("books.json") as fd:
    data = json.load(fd)

print(data)
```

The advantage of JSON over XML is that the overheads for parsing the
data are much lower and in general, JSON adds much less extra to the
data meaning files are usually smaller. In particular, parsing JSON in
Javascript in your web browser can be particularly efficient since JSON
is just Javascript code (however, see the [note later about
security](json-security)).

JSON lacks some of the features of XML that make it particularly
suitable for data exchange and archival storage of data. Since we can
write a DTD or schema for an XML language, we can validate a document in
a separate step to actually processing it. This is quite a powerful idea
since it can make applications more robust. JSON lacks this ability
although there has been some work on developing a [schema language for
JSON](http://jsonschema.net/) that might do something like this. The DTD
is also a way to document a particular XML structure and to advertise
the structure that is required by a particular application. In terms of
archival storage, XML and the associated schema documents provide a much
more descriptive way of storing data than simple attribute value pairs
in JSON. Another important feature of XML is the ability to use a
namespace prefix on tags and so allow mixing of tag names defined by
multiple standards; this would allow me to create a single XML document
that referred to `title` from a book tag-set `books:title` and another
from a Real Estate tag-set `realestate:title`.

In practice this means that there are places where XML is the right
solution and there are others where JSON is more appropriate. In most
modern web applications where small data sets are exchanged between a
server and a client, JSON is the most appropriate solution and has
gained a lot of support over the last few year.

### Security and JSON

Earlier I mentioned that parsing JSON in Javascript was particularly
efficient since JSON is Javascript code. The reason for this is that the
underlying Javascript parser could be used to parse the data rather than
having to implement a parser in Javascript itself. However, this opens
up a serious security hole in a Javascript application. If I retrieve a
packet of data from a URL expecting it to be a list of objects, it is
possible that an attacker has inserted malicious Javascript code into
the JSON data stream. If I were to pass this directly to the Javascript
parser, the malicious code could be executed and the application would
be vulnerable. For this reason, even in Javascript, a separate JSON
parser is usually implemented at the application level rather than
relying on the core language parser. Even given this added complexity,
parsing JSON is usually much faster than parsing the equivalent XML.


### Example: JSON in the Database

One use of both XML and JSON is to store complex data structures in a relational
database.   For example, if I want to store a list of values in a database then I 
would need to store each list item as a separate record in a special table.  To avoid
this complexity it is sometimes useful to convert a complex data structure into 
a string and store the string value instead.  In this example we'll use JSON
to store a list of integers in a database table.  

First we'll set up a simple database table to store a name and a data value.

```python
import json
import sqlite3

def create_tables(db):
    """Create a sample table"""

    sql = """
DROP TABLE IF EXISTS samples;
CREATE TABLE samples (
    name text unique primary key,
    data text
);
    """

    db.executescript(sql)
    db.commit()
```

To store some data in the database we write the function `set_sample` that takes a
name and a data item.   The data is a Python list and to store it we need to 
convert it to a JSON string using the Python `json` module.

```python
def set_sample(db, name, data):
    """Set the data associated with a name"""

    cur = db.cursor()
    data_j = json.dumps(data)
    sql = "INSERT INTO samples (name, data) VALUES (?, ?)"
    cur.execute(sql, [name, data_j])

    db.commit()
```

Here `data_j` will be the string version of `data` that we can store in the database table. 
This could be a list but could also be any complex Python data structure such as a
dictionary or list of dictionaries.    To retrieve the data associated with a name
we write a function `get_sample`:

```python
def get_sample(db, name):
    """Return the data associated with a name
    or None if the name is not found"""

    sql = "SELECT data FROM samples WHERE name=?"
    cur = db.cursor()
    cur.execute(sql, [name])
    result = cur.fetchone()
    if result:
        data =  json.loads(result['data'])
        return data
    else:
        return None
```

The first part of this function just queries the table for the record matching the
given `name`.  If a result is found it converts the JSON data back to a Python 
data structure with the `json.loads()` function.  This is then returned.  In the case
when no record is found matching `name` we return `None`.  

We can now use these functions:

```python
db = sqlite3.connect("sample.db")
db.row_factory = sqlite3.Row
create_tables(db)

set_sample(db, "steve", [1, 2, 4, 5])
set_sample(db, "diego", [4, 5])

steve = get_sample(db, "steve") 
diego = get_sample(db, "diego") 
print("Steve:", steve) # prints [1, 2, 4, 5]
print("Diego:", diego)# prints [4, 5]
```

This provides an example of storing serialised JSON data in a database field.   There 
are some good reasons why you should not do this in a simple case like this one - using
a properly normalised database design would allow you to store and query these lists directly
in the database.  In some cases though the data we are storing is what is known as 
[semi-structured data](https://en.wikipedia.org/wiki/Semi-structured_data) - it has
structure but does not conform to a rigid schema.  In this case, XML or JSON can be 
a good format to represent the data and storing 'blobs' of JSON or XML data in a 
relational database can be a useful option.  

A final alternative would be to use a non-relational database such as [CouchDB](http://couchdb.apache.org/)
which stores JSON data natively and is optimised for this task.  Such databases
are becoming popular in the web application domain because of their close fit
to the JSON data objects that are often transferred between client and server. 

