

Building a Web API
==================



What is a Web API?
------------------

In earlier chapters we discussed the idea of using Python scripts as web
clients to retrieve HTML pages and an HTML parser to scrape data from
within the page. We then said that there is a better way to make data
available to scripts, namely using a format that is designed for machine
consumption such as XML or JSON. This chapter discusses some of the
design decisions in building such an API and shows some examples of a
Bottle application that returns JSON data.

In its simplest form, a web API is a way of making the resources in a
web application available in machine readable form. This would enable a
script to retrieve a version of the data hosted in an application
without having to screen-scrape HTML. A more sophisticated API will
allow all of the operations that are supported by the application to be
carried out by scripts as well as by humans through the regular web
interface.

In this context it is useful to reiterate the idea of a *resource* on
the web. A resource is that thing referred to by a Uniform Resource
Locator or URL. We can retrieve a representation of a resource with a
GET request. A resource can correspond to any thing that is stored and
manipulated by an application: a message, a personal profile, a
document, a real-estate listing, the record of a bid in an auction. A
resource can also be a collection of other resources, such as all of the
listings on an auction site or all of the documents relating to a
meeting.

When we design a web application, we should try to think about what the
resources are in the application and give each one a meaningful URL. A
collection will often have a URL ending in a `/` like
`http://example.org/listings/` while an individual resource would be
'within' the collection like
`http://example.org/listings/bathroom-chair1293`. A URL is a unique
identifier for a resource, so should include enough information to name
it uniquely. This might include a distinct numeric code or other
identifying information. Here's an example from The Guardian newspaper
that includes date information as well as the title:
`http://www.theguardian.com/technology/askjack/2015/may/05/how-does-a-domain-name-scam-work`
- part of this URL is also a collection
(`http://www.theguardian.com/technology/askjack`) that contains all
articles in this column, and `http://www.theguardian.com/technology` is
all of the technology articles.

Designing URLs is a tricky task and there is no simple rule to follow.
There are some useful discussions on the web: [Kyle
Neath](http://warpspire.com/posts/url-design/), [David
Marland](http://www.smashingmagazine.com/2014/05/02/responsive-design-begins-with-the-url/).

A web API isn't just about retrieving resources. A complete URI will
support creating new resources and updating existing ones as well: all
of the operations that are supported by the regular web application.
This is often referred to as CRUD - Create, Read, Update, Delete: the
operations that might be implemented on resources and collections. With
an web API, these operations correspond to the HTTP verbs: GET (read),
POST (create or update), PUT (create), DELETE (delete). A well designed
API will support the CRUD operations on resources using these different
verbs. So to add a new message to a collection of messages on a site we
would use a POST request to the URL that refers to the collection of
messages. To update (edit) a message, we'd send a POST request to the
URL for the message itself. This style of API is part of what is known
as [REST](http://en.wikipedia.org/wiki/Representational_state_transfer)
(Representational State Transfer). REST is an architectural style for
building web applications but at its core it supports naming resources
with URIs and implementing operations on these via the HTTP verbs.





Implementing a JSON Response
----------------------------

Bottle makes it very easy to return JSON content in a response. If the
return type of a handler is a Python dictionary, it will be converted to
JSON in the response. Building on the [database backed
'likes'](../bottle/bottle-sqlite.html) application from the earlier
chapter on databases, we'll develop a simple example JSON based API. As
a reminder, here is the main page of that application that returns a
list of the current likes and the form as an HTML page:

```
def index():
    """Home page"""

    db = COMP249Db()

    info = dict()
    info['title'] = 'Welcome Home!'
    # get the list of likes from the database
    info['likes'] = get_likes(db)

    return template('dblikes.tpl', info)
     
```

If we want to be able to get a version of this data as JSON, we can
write a separate handler for a different URL and return a dictionary:

```
@app.get('/likes')
def getlikes():
    """Get a JSON version of the likes data"""
   
    db = COMP249Db()

    info = dict()
    # get the list of likes from the database
    info['likes'] = get_likes(db)
    
    return info
     
```

This version just returns the `info` dictionary that has one entry for
the key `likes` that will be a list of the current entries from the
database. If we send a GET request to this URL we get the response:

```
{
"likes": [
          "Cheese",
          "eggs",
          "bananas",
          "fruit in general"
         ]
}
     
```

Note that I've formatted this to make it easier to read - by default it
will be returned without any newline characters. The result is a JSON
object with a `likes` property who's value is a list of strings. It
contains the same information that would be used to populate the HTML
template, but in a form that can easily be read by a script via a JSON
parser.





A Client for our Web API
------------------------

Now that we have a machine readable result returned from our
application, we can write a Python client to read this data. It is
simple to write a client that sends a request with `urllib`, we then
need to parse the JSON result into a native Python data structure. This
can be done with the [json]() module. Here is a function that will
return a list of likes by querying the remote web api:

```
from urllib.request import urlopen
from urllib.parse import urljoin
import json

BASE_URL = 'http://127.0.0.1:8080/'

def get_likes():
    """Query the web API for all of the current likes
    return a list of strings"""
    
    url = urljoin(BASE_URL, '/likes')
    
    with urlopen(url) as fd:
        text = fd.read().decode('utf-8')
        
    likes = json.loads(text)
    
    if 'likes' in likes:
        return likes['likes']
    else:
        return []

if __name__=='__main__':
    
    print(get_likes())
     
```

This module uses a global variable `BASE_URL` that holds the URL of the
web application. We then add to the URL in the `get_likes` function to
get the URL of the endpoint we want to access. We then make a request to
the URL using `urlopen`. Using the `json.loads` function we parse the
string containing the JSON result into a Python structure which will be
a dictionary. We then check whether the property `'likes'` is in the
dictionary and return the value if it is.

Reflecting on what we've implemented here, we have a Python web
application running on our local machine that has a local database and
serves HTML pages containing a form. We can interact with that form and
add 'likes' to the database. When we request the URL
`http://127.0.0.1:8080/likes` the web application queries the database,
gets a Python list of likes, inserts them into a Python dictionary and
then returns them. Bottle turns this dictionary into JSON and sends it
back to the client. Our client script receives the JSON response, parses
the JSON into a Python dictionary and extracts the list of likes. This
is a roundabout way of passing data from one script to another but the
big advantage is that these scripts could be running on different hosts
or could be written in different languages and this would work fine.
HTTP is being used as an inter-application protocol to exchange data
between running systems.





The Update Operation
--------------------

We can now read data in machine readable form using an HTTP request. The
next step is to be able to update the data stored on the server - to add
a new like. To do this we need a POST request, just like submitting the
form on the web page. In fact we already have a handler for this, since
the POST handler for the `/likes` URL accepts a url-encoded form
containing the new like and stores it in the database. At one level
then, we don't need to do anything, however, we could make the API a
little more consistent if this request also used JSON in the same format
as returned by the GET request. This would also allow us to set more
than one like in one request. So, let us extend the POST handler to
accept either an encoded form or a JSON object containing a property
`'likes'`; if we get a JSON object we add all of the items to the
database.

The first task is to test whether the request contains a url-encoded
form or a JSON payload. We can do this using the Content-Type header in
the request which Bottle makes available as `request.content_type`.

```
@app.post('/likes')
def like():
    """Process like form post request"""

    # initialise likes to an empty list
    if request.content_type == 'application/json':
        return likes_json()
    else:
        return likes_form()

def likes_json():
    """Handle the /likes POST request from a JSON submission"""
    
    if 'likes' in request.json:
        likes = request.json['likes']
    else:
        likes = []

    for like in likes:
        store_like(db, like)
    
    # response with an updated list of likes as JSON
    return {'likes': get_likes(db)}
    
```

In implementing this I've split the two kinds of response into two
handler functions to keep them simple and then called the appropriate
one based on the content type of the request. The form handler is the
same as the original handler but the JSON handler uses the
`request.json` property supplied by Bottle which is the parsed JSON
object (Bottle is smart enough to provide this when the content type is
`application/json`). The JSON handler also handles multiple likes and
adds them all to the database and returns an updated list of likes
rather than a redirect to the home page. This is more appropriate
behaviour for a request that we will make from a script.

Now let's look at a client for the new API endpoint for adding likes.
This will have to encode the list of likes as a JSON object and send the
request with the appropriate content type. To do this we need to do a
bit more work thank before with `urlopen`; we need to make an explicit
`Request` object to be able to set the headers. Here is a client
function that will add a new list of likes and return the updated list
from the response:

```
def add_likes(likes):
    """Add the strings in likes to the remote application
    return a list of the new set of likes"""
    
    url = urljoin(BASE_URL, '/likes')
    data = {'likes': likes}
    
    params = json.dumps(data).encode('utf8')
    req = Request(url, data=params, 
                       headers={'content-type': 'application/json'})
    
    # send request and decode the response
    with urlopen(req) as fd:
        text = fd.read().decode('utf-8')
        
    if text:
        likes = json.loads(text)

    if 'likes' in likes:
        return likes['likes']
    else:
        return []
    
```





Summary
-------

This chapter has introduced the idea of designing a web based API for
providing access to the resources served by a web application. We've
shown how to implement some of the basic operations (Read and Update)
using Bottle examples and looked at a simple client for the API. There
is a lot more to this topic because web APIs can become very complex.
For example, we might need to deal with authentication, which is
complicated because we can't ask someone to fill in their username and
password in a script. We also need to deal with the Create and Delete
operations from CRUD.





Copyright © 2015, Steve Cassidy, Macquarie University

[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
