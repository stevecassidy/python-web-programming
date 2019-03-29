

Cookies
=======

<span class="index" title="cookies">Cookies</span> are a mechanism for
maintaining state in an HTTP transaction. They allow a server side
application to store some data with the client which is returned each
time the client makes a request to the same server. Cookies are sent to
the browser via a Set-Cookie header in the HTTP response and returned to
the server in a Cookie header. To make use of cookies in a WSGI web
application we need to work out how to create and consume these headers
and manipulate their contents in our programs.

Let's look at an example of both kinds of header. Here's a response from
a server that <span class="index" title="cookies!!header fields">sets a
cookie</span>:

```
HTTP/1.0 200 OK
Date: Wed, 21 Mar 2012 03:18:25 GMT
Server: WSGIServer/0.1 Python/2.7.2+
content-type: text/html
Set-Cookie: likes=cheese
```

The last header like contains a cookie called 'likes' with a value
'cheese', the browser will by default store this locally and send it
back with any request to the same URL. Here is a request that includes
the same cookie:

```
GET / HTTP/1.1
Host: localhost:8000
Connection: keep-alive
User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.11 (KHTML, like Gecko) Ubuntu/11.10 Chromium/17.0.963.56 Chrome/17.0.963.56 Safari/535.11
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Referer: http://localhost:8000/?like=cheese
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-GB,en-US;q=0.8,en;q=0.6
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
Cookie: likes=cheese
  
```

Again the last line contains the cookie 'likes' with the value 'cheese'.
Let's look at how to generate and consume cookies with Python.



<span class="index" title="cookies!!generating in bottle">Generating Cookies</span>
-----------------------------------------------------------------------------------

In Bottle, cookies are associated with the request and response objects.
To create a cookie We use the `set_cookie` method of the response
object. This takes two parameters, the cookie name and the value, and
sets a cookie that we sent back with the response to the browser. We can
see this in this example:

```
>>> bottle.response.set_cookie('test', 'hello')
>>> print(bottle.response)
Content-Type: text/html; charset=UTF-8
Set-Cookie: test=hello
   
```

Note the printing out the response shows is the headers that will be
sent back to the browser. This could be useful sometimes in debugging
your code. In this case we see the sec cookie header With the value test
set hello.

Note that we don't yet have the other attributes of the cookie that were
in the first example - the expiry date and the path. These can be added
by adding more parameters to the set cookie call, for example:

```
>>> import datetime
>>> ts = datetime.datetime.now()+datetime.timedelta(days=1)
>>> bottle.response.set_cookie('test', 'hello', path='/', expires=ts)
>>> print(bottle.response)
Content-Type: text/html; charset=UTF-8
Set-Cookie: test=hello; expires=Sat, 21 Mar 2015 11:21:42 GMT; Path=/
   
```

In this example we use the daytime library calculating expiry date for
the cookie one day ahead of now. As you can see, and print out the
response wishing extra fields in the cookie header.

Let's look at this now in the context of a web application that sets a
cookie.

```
@app.route('/')
def index():
    """Home page"""

    info = {'title': 'Welcome Home!',
            'content': 'Hello'
    }

    bottle.response.set_cookie('visited', 'yes')

    return bottle.template('simple.tpl', info)
    
```

This application sets a cookie called visited value zero whenever the
homepage is requested. The cookie will be returned with the response
headers, and then the browser will send it back and every subsequent
request. Analysis of how to consume the cookie with Bottle.





<span class="index" title="cookies!!consuming in bottle">Consuming Cookies</span>
---------------------------------------------------------------------------------

If a browser sends a request after we set a cookie, the cookie header
will be included with every request. To find out its any cookies we can
query the Bottle request object using the `get_cookie` method. This take
a single argument, the name of a cookie, and returns a value if there is
one, or none if no cookie was sent. Using this we can extend the little
application above to check for the 'visited' cookie when the page is
requested. If the 'visited' cookie is found, Will use a different
message from the page content. Here is the code for that example:

```python
@app.route('/')
def index():
    """Home page"""

    info = {'title': 'Welcome Home!',
            'content': 'This is your first visit.'
    }

    visits = bottle.request.get_cookie('visited')

    if visits:
        info['content'] = 'You have been here before.'

    bottle.response.set_cookie('visited', 'yes')

    return bottle.template('simple.tpl', info)
    
```

The first time I request the page, there will be no cookie and so the
value of visits will be None, On the page content will be 'This is your
first visit', but the response will contain a Set-cookie header for the
'visited' cookie. On the next request, the browser will send the
'visited' cookie in the request headers. The application code Will then
get value back from `get_cookie` and the statement Will modify the page
content to 'You have been here before'. This is perhaps the simplest use
cookies we can imagine.





A Cookie Example {#a-cookie-example .index title="cookies!!python example"}
----------------

Let's develop a simple application that makes use of a cookie to record
some information. The application will present a form to ask us for
something that we like. We'll enter some text which will be submitted to
the application. The application will create a cookie called 'likes'
who's value is the text we entered and send it back to us. When we later
re-visit the application, the cookie will be sent along and the
application will display the value that we entered earlier.

There are two ways that input will be sent to this application - one
from the form that the user submits, the other from the cookie that the
application sets. We will handle these through different URLs. The form
to record a like will be sent as a POST request to the URL `/likes`, the
procedure for this will get the value submitted in the form, if any, and
set a cookie in the response. It will then return a **redirect
response** that will include the cookie, with the location set to the
URL `/`. When the browser receives the redirect response, it
automatically makes a second request for the new URL that is specified;
in this case a GET request for the `/` URL.

First then, here's the page template we'll use. It will display the
value of `likes` if it is not None, and display the form for submitting
a like value:

```html
<html>
    <head><title>{{title}}</title></head>
    <body>
         <h1>{{title}}</h1>

         % if likes:
          <p>You like {{likes}}</p>
         % end

          <form method='POST' action='/likes'>
              <legend>What do you like? </legend>
              <ul>
                <li><input name='likes'></li>
              </ul>
              <input type='submit'>
          </form>

    </body>
</html>
```

The application code to handle the form submission is as follows:

```
from bottle import Bottle, request, response, template, redirect

app = Bottle()

@app.post('/likes')
def like():
    """Process like form post request"""

    # get the form field
    likes = request.forms.get('likes')

    if likes:
        response.set_cookie('likes', likes)

    return redirect('/')
   
```

Note that the decorator on this function is `@app.post('/likes')` which
means that it will only respond to POST requests to this URL. A GET
request would result in a 404 response.

Note also that in some earlier versions of Bottle the `redirect`
function would reset the response object and wipe out the cookie we
added. If this code doesn't work for you, try updating to the most
recent version of Bottle.

The function to handle the main page is quite simple. It tries to get
the cookie value from the request using `get_cookie`; this returns
`None` if no cookie is present. The returned value is then sent to the
template for display. If the cookie has no value then the template will
just display the form; otherwise it will display the value passed in via
the cookie.

```
@app.route('/')
def index():
    """Home page"""

    info = dict()
    info['title'] = 'Welcome Home!'
    # cookie value, None if no cookie sent
    info['likes'] = request.get_cookie('likes')

    return template('cookies.tpl', info)
```

This example illustrates a simple application structure that makes use
of different URLs for different actions. Being able to handle each kind
of input separately, makes each application procedure quite simple and
easy to follow. It illustrates a simple use of cookies to keep track of
user data between requests. This isn't a realistic application; it would
be unusual to store real user data in a cookie, much more normal to use
database server side database. As we 'll see you later chapters cookies
are used as keys into this database to retrieve user data.

<div class="section exercises">

### Exercises

1.  Write an application that keeps track of how many times a user has
    visited it using a cookie. The first time a user visits they are
    sent a cookie 'count' with a value 1, every subsequent request will
    include this cookie, and the application gets the value of the
    cookie, increments it by 1 and returns it as a new cookie (note that
    if you return a new cookie with the same name as one already sent,
    the browser will overwrite its store with the new value). The
    application should return a page containing the count of number
    of visits.
2.  Extend the 'likes' application above to allow more than one thing to
    be stored in the cookie. If you get a form submission and a cookie,
    add the new 'like' from the form to the existing cookie value
    separated by a delimiter like '|'. Then, when you get a cookie, use
    the `split` method to split the cookie value into the different
    things that the user likes. Hint: write procedures to join and split
    the cookie values and call them from your application to process the
    cookies that you get.
3.  Write an application that uses cookies to enforce a 'license
    agreement' on its users. If a user has not visited before, they are
    shown a page that asks them to agree to some terms and conditions,
    if they accept them (e.g. check a checkbox and hit Submit) then they
    are given a cookie and shown the content page. If a request arrives
    with a cookie, they go straight to the content page.







[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
