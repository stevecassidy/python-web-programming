

Writing Web Applications in Python with Bottle
==============================================



Web Applications
----------------

A web application consists of code that responds to HTTP requests to
return an HTTP response. A *web application* is not the same as a *web
server*; the server is listening on the network socket for requests and
decoding them and then sending back the response. The web application is
the code that takes the request information and generates the response.
To write a web application we need a way to send the request information
from the server to the application code; there are many ways to do this
for different combinations of web server and application environment.

In Python, the low-level interface to web applications is called WSGI
(Web Server Gateway Interface). It defines a standard way of defining a
procedure to act as as web application.  
While it is possible to write an application using the low-level WSGI
standard, it is usually much more convenient to use a higher level
abstraction in the form of a *framework*. This means that we use a
python module that does some of the work for us and takes away some of
the complexity of dealing with the low level WSGI standard. There are
many frameworks to choose from for Python ([see this
list](https://wiki.python.org/moin/WebFrameworks)) but we will use the
[Bottle](http://bottlepy.org/) framework because it is simple and
doesn't do everything for us - the goal of this course is for you to
learn how the web works, so we don't yet want to use a framework that
hides all of the detail from you.

We'll explore Bottle in lots of detail but to show you a simple example,
a simple Bottle web application would be:

```python

from bottle import Bottle

app = Bottle()

@app.route('/')
def index():
    return "Hello World, how are you?"

@app.route('/about')
def index():
    return "Tell me about yourself."
```

The first thing that this example does is create a Bottle application
object. This is going to be used when we come to run the code. (Note
that you will see examples of Bottle apps without this, we'll use it
because it helps with testing your code later on).

This example defines two 'pages' in the application - that is it will
respond to two different URLs. Each URL is called a *route* and the code
associates this route with a procedure that returns the content to be
sent back to the browser. So if this application gets a request for the
home page (eg. `http://localhost:8000/`) then it will return the "Hello
World..." message. If it gets a request for the 'about page' (eg.
`http://localhost:8000/about`) it will return the "Tell me..." message.
In this simple example these are plain text; we'll see how to make them
return HTML pages shortly.

This structure for the Bottle application emphasises one important
feature of web applications. The job of the application is to respond to
requests forwarded by the server; each request is for a particular URL.
The application must receive the request, process it, and generate a
response. Bottle allows you to arrange your code so that one procedure
deals with one request; this makes it easy to see what your code is
doing and helps with debugging.

Bottle is built on top of the WSGI standard and so it is compatible with
all kinds of other Python web infrastructure. For example there are
modules that implement authentication and sessions and they can be used
directly with Bottle applications. You don't need to worry about this
just now but it is reassuring to know that what you are doing is aligned
with core Python infrastructure.

This is a simple example of an application, we now need to look at how
to run it.

### The Web Server

The web server is the piece of software that handles HTTP requests from
the client and generates a response to send back. In a production
environment, you will use a server like Apache, Ngnix or Microsoft
Internet Information Server. These are large software systems that are
designed to handle many requests per second as fast as possible. While
we are developing code, there is no need to run under such a server and
in fact it's a bit of a pain to have to deal with it. When working with
Python it is common to use a simple server written in Python and that's
what we will do. It means you don't need to install anything other than
Python and Bottle to develop this code but since Bottle uses the WSGI
standard interface, anything that you develop could be deployed on a
production quality server quite easily.

Bottle provides a development server that you can use by adding a single
line to your application. Here's the entire code of our first example,
including the server:

```python
from bottle import Bottle

app = Bottle()

@app.route('/')
def index():
    return "Hello World, how are you?"

@app.route('/about')
def about():
    return "Tell me about yourself."

if __name__ == '__main__':
    app.run(debug=True)
    
```

What we've added is a bit of code that will only run if we run this
Python module (file) directly (`if __name__=='__main__')`) but not if it
is imported by another module. This is a common Python trick and is
equivalent to the main class in a Java program. In this case we have one
line of code which just calls the `run` method on the application. We've
passed one named argument to turn on debug mode in the server.

When you run the above Python code, it will start a web server listening
on port 8080, you should see the following output:

```
Bottle v0.12.8 server starting up (using WSGIRefServer())...
Listening on http://127.0.0.1:8080/
Hit Ctrl-C to quit.
```

This indicates that the server is listening for requests on port 8080 on
the local machine (127.0.0.1 is the IP address of the 'loopback' network
interface on every computer, meaning that it refers to the computer
itself). If you copy and paste that link into your browser you should
see a page with our "Hello World..." message; you should also see the
following printed in the terminal window:

```
127.0.0.1 - - [11/Feb/2015 16:06:37] "GET / HTTP/1.1" 200 25
127.0.0.1 - - [11/Feb/2015 16:06:38] "GET /favicon.ico HTTP/1.1" 404 742
```

This is a log from the web server showing what requests were received
and the response code (200) and content length (25 bytes) that were
returned. The second request for `/favicon.ico` is not one you made
directly, your web browser generally sends this request to any site you
visit to get the little icon that is shown in the address bar. In this
case, Bottle doesn't know what to do with a request for this *route* and
so returns a 404 (Not Found) response. If you enter that URL into your
browser directly (http://127.0.0.1:8080/favicon.ico) then you'll see the
debugging error message that Bottle generates.

You can also request the other URL that we've included in the
application: http://127.0.0.1:8080/about. This should give you the "Tell
me..." page and you should see another line in the logs. Your
application is working! We now need to see how to make it do something
more useful.

From now on I won't include the server part of the script in my
examples, since I will concentrate on the definition of the application
itself. To run all of the future examples you can use the same main part
as in the example here.

### Exercises

1.  Make your own copy of the script above and run it to reproduce the
    results shown here.
2.  Modify the content of the 'page' returned for each URL by changing
    the string that each function returns - add some HTML markup, for
    example put a link to the About page in the home page and
    vice versa.
3.  See what happens when you request a URL that isn't dealt with by
    the application. Try a few different paths at the end of the URL and
    observe the log entry displayed and the results returned. Eg.
    `http://127.0.0.1:8080/python`,
    `http://127.0.0.1:8080/courses/comp249.html`.
4.  Modify the application so that it does respond to
    `http://127.0.0.1:8080/python` with a new message by adding a new
    route and a new procedure to the code.


More on Routes
--------------

The `@app.route('/about')` line before each procedure in a Bottle web
application is a Python construct called a *decorator*. It is a way of
changing the way a procedure works, in this case it is the way that
Bottle associates your procedures with different URL paths. From the
discussion of [the structure of URLs](../web/webworks.html#title5) we
recall that the part of the URL after the network location is sent in
the HTTP request to the server. So a request for
`http://example.org/home/index.html` will result in an HTTP request
being sent to the server at `example.org` that would look something like
this:

```
GET /home/index.html HTTP/1.1
Host: example.org
Accept: text/*
```

The server accepts this request and looks at the path that has been
requested - `/home/index.html` in this case. It decides how to deal with
this, in this case it will send it along to our Bottle application.
Bottle tries to match the path up with one of the routes that we have
declared in our application, if it matches, it calls the procedure and
returns the response that it generates.

So far we've seen a simple route that just names the URL path that it
should apply to. However, Bottle provides a way to match patterns in the
URL path and have a single procedure apply to more than one path. Let's
illustrate this with a simple example that generates 'home pages' for
different people based on their name. We want a URL like
`http://127.0.0.1:8080/people/Steve` to return a custom page for user
Steve. Our first implementation will just put the users name in the
page. We use the URL pattern `@app.route(/people/<who>)` as where the
`<who>` part is a pattern that will match anything in the URL. Since the
text matched by the pattern can vary, the procedure now takes an
argument which is passed the text from the URL. It can then use this
text in generating the page. The name of the argument must be the same
as the name between angle brackets in the path. Here's the code:

```python
@app.route('/person/<who>')
def homepage(who):
    """Generate the home page for a person"""

    return "<p>This is the home page for " + who + ".</p>"
```

If you add this to your application then you should be able to add any
name to the URL to get a custom page; try the following:
`http://127.0.0.1:8080/people/Steve`,
`http://127.0.0.1:8080/people/Steve%20Cassidy`,
`http://127.0.0.1:8080/people/a`,
`http://127.0.0.1:8080/people/%3Cb%3Ehello`. Note that we can include
special characters in a URL by encoding them via the % code numbers.
`%20` is a space character; what are the characters in the final
example? Can you explain what appears in your browser?

The route pattern in angle brackets will only match one path component
in a URL, so if you try to access
`http://127.0.0.1:8080/people/Steve/Cassidy`, you will get a 404 error
page saying that the page is not found - this is because there is no
route to match the URL. We can use more than one pattern in a URL to
match more path elements; for example to match first and last names:

```python
@app.route('/person/<first>/<last>')
def homepage(first, last):
    """Generate the home page for a person"""

    return "<p>This is the home page for " + first + " " + last + ".</p>"
```

Note that with two patterns in the URL, the procedure needs to accept
two arguments for the two values matched. Again, the names of the
arguments must match the names in the angle brackets. With this code in
place we can access `http://127.0.0.1:8080/people/Steve/Cassidy` and get
the generated page.

Rather than spelling out paths bit by bit, we might want to allow any
number of path elements at the end of a URL. We can do this in Bottle by
using the `:path` modifier after the pattern name. This then allows the
pattern to match the `/` character. Let's modify the earlier example:

```python
@app.route('/person/<who:path>')
def homepage(who):
    """Generate the home page for a person"""

    return "<p>This is the home page for " + who + ".</p>"
```

Now when we access the URL `http://127.0.0.1:8080/people/Steve/Cassidy`
the single pattern matches `Steve/Cassidy` and we get a page with the
message *"This is the home page for Steve/Cassidy."*. Note that this
pattern really just allows you to match names with the slash (/)
character in them, they don't have to be paths as such. So what about
the example:
`http://127.0.0.1:8088/person/%3Cb%3Ehello%3C/b%3E%20there`. Can you
explain what you see in your browser here? Why does this example only
work with this latest code?

Routes in Bottle can match any URL pattern and pass information from the
URL to the procedure that will generate the result. This means that your
application can respond to a possibly infinite number of URLs. The kind
of URL we used above for a person is actually quite a common one in web
applications - look at the URL of your Facebook profile page for
example. Obviously you would normally do much more work to generate the
page - the user name is used as a key to look up data in a database to
populate the page. We'll look at examples like this later on in the
text.


Using the Request
-----------------

All input to our web application comes via the HTTP request that is sent
to the web server. The server receives this request and parses the
header to determine how to deal with it - in our case the request is
sent along to our python script using the WSGI standard and Bottle
arranges for the right procedure to be called depending on the URL in
the request. Many other things are included in an HTTP request that can
be of use in generating the response to be sent back to the client.
These can include form fields and uploaded files but also things like
the IP address of the user, the page that linked to this page etc. Later
we'll learn how to use some of this information in generating responses.
For now we'll look at a simple example of generating a page from the
request.

Bottle provides a global variable `request` who's value is an object
that represents the current HTTP request. We need to import this from
the `bottle` module in order to use it in our code. Let's look at a
simple example that includes one property of the request in the page
that is returned. We'll use the IP address of the browser (client) and
the user-agent header that the browser sends as part of the request.

```python
from bottle import Bottle, response, request

app = Bottle()

@app.route('/about')
def about():

    result =  "<p>Your IP address is:" + request.remote_addr + "</p>"
    result += "<p>Your browser is: " + request.environ['HTTP_USER_AGENT'] + "</p>"

    return result
```

This is the first example of a web application that doesn't just return
something we've typed in. We access the two bits of information we want
in slightly different ways. The [bottle request
object](http://bottlepy.org/docs/dev/api.html#bottle.LocalRequest) has a
property `request.remote_addr` for easy access to the remote IP address.
However, to get at the user-agent string we need to look in the WSGI
environment dictionary that is held in `request.environ`. This just
illustrates two different ways to access information from the request in
your code. Most of the time you'll just use the properties that Bottle
exposes but sometimes it will be necessary to look into the environment.

We can extend this example a bit further and look in more detail at what
is in the WSGI environment. This example will also illustrate how we can
write helper procedures to generate parts of the page for us.

As we saw in earlier chapters, a dictionary in Python is an associative
array where names (keys) are associated with values. A dictionary is an
object and has a number of useful methods. We're interested here in
using an iterator over the keys in the dictionary - `for key in d:` will
iterate over every key in turn. We then use the square bracket notation
(`d[key]`) to retrieve the value associated with a given key. Given a
dictionary, here's the Python code to print out all of the key-value
pairs:

```python
d = {'name': 'Steve',
     'age': 21,
     'favourite_colour': 'green',
     'likes_cheese': 'yes'
     }

for key in d:
    print(key, d[key])
```

Building on this, we can write a procedure to take a dictionary as a
parameter and return an HTML string listing the keys and values:

```python
def dict_to_html(dd):
    """Generate an HTML list of the keys and
    values in the dictionary dd, return a
    string containing HTML"""

    html = "<ul>"
    for key in dd:
        html += "<li><strong>%s: </strong>%s</li>" % (key, dd[key])
    html += "</ul>"
    return html
   
```

We can now make use of this procedure in a new WSGI application that
returns an HTML page containing this information:

```python
@app.route('/about')
def about():

    result = dict_to_html(request.environ)

    return result
  
```

On my machine, a request for http://localhost:8080/ when running this
application gives me the following page:

<div class="figure">

![screenshot of web browser showing the environment
application](wsgi-environ.png)


When you run the application you will see something different. Note that
the environment that we are given in the `request.environ` parameter
contains information about the request (e.g. HTTP\_HOST,
REQUEST\_METHOD) but also general information about the execution
environment (e.g. HOME, DISPLAY).


### Exercises

1.  The list of environment variables looks a little messy the way it
    was generated above. Make it a little better by sorting the list of
    keys before generating the page.
2.  When you change the URL you are requesting, part of the environment
    changes to communicate this to your script. Access the following
    URLs and note what has changed in the environment:
    -   http://localhost:8080/about?register=yes
    -   http://localhost:8080/about?name=Steve



Manipulating the Response
-------------------------

In the examples above, the response returned to the browser was
interpreted as an HTML page because the default behaviour in Bottle is
to return a response with the `Content-Type` header set to `text/html`.
In some cases we might want to tell the browser that we're returning a
different kind of data, for example, plain text or an image. To do this
we need to manipulate the response before it goes back to the server and
is sent on to the client. Bottle provides a global object called
`response` to allow us to change any part of the response that will be
sent back. Here's an example of changing the content type of the
response:

```python
from bottle import Bottle, response

app = Bottle()

@app.route('/about')
def about():
    response.content_type = 'text/plain'
    return "Tell me about yourself."
```

If you make this change to your sample program and run it, then request
`http://127.0.0.1:8080/about` in your browser you should see a slightly
different result. The text should show up in a fixed width font and if
there is any HTML markup you'll see it literally. If you peek at the
HTTP request using your browser's developer tools, you'll see that the
response type returned is `text/plain`.

The response object allows us to manipulate other aspects of the
response as we'll see when we start developing more complex applications
later. For example you can change the status code to generate an error
page or a redirect response.


Static Files
------------

In any web application there are some resources that will be *static* in
that they are not generated by application code but are fixed for the
whole application. Examples are CSS stylesheets, Javascript files and
images. These will be referenced by the HTML generated by your
application and so we need to know their URL so that we can reference
them properly.

Since these files don't change, there is no real need to invoke an
application python script to generate them. In a production setting,
these files might be served directly by the main web server or even
given to an offsite web server to handle. However, during development,
we need them to be served by our python development server, hence we
need some way of handling them in our code.

A common pattern is to use a fixed URL path when referring to static
files; so, for example, I might use the prefix `/static/` and arrange
for all static resources to be served from there. In a standard server
setup, this URL path would be mapped to a directory on the server. If we
put our Javascript file in a subdirectory, eg. `js/fancy.js` then we'd
use the URL `/static/js/fancy.js` to reference it in the HTML files.
Similarly `images/face.png` would map to `/static/images/face.png`.

In production, the web server would be configured so that any URL
starting with `/static` was served directly from the configured
directory. This will be much faster than invoking our Python application
to serve the file. Web servers are optimised for serving static files
and do it very efficiently.

In development, we need to add some code to our application to handle
this URL prefix. This code will look at the URL and extract the filename
that corresponds to the resource, read that file and send it back. It's
possible (and informative) to write this code but Bottle also gives us
[an
implementation](https://bottlepy.org/docs/dev/tutorial.html?highlight=static#routing-static-files)
that is easy to use. Here is the standard route handler that we can
include in our application to handle requests for static files:

```python
from bottle import static_file

@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root='static')
```

The route uses the `:path` qualifier which matches any path after the
URL, not just a single filename. We import the `static_file` handler
from Bottle and pass it the path and the location of the root directory.
In this example I've used a *relative path* which will be interpreted
relative to the current working directory. This is convenient for
development, we create a directory called `static` inside our project
(next to `main.py`) and store static files in there.

