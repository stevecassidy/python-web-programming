

Scripting Forms
===============



POST and GET Requests
---------------------

You'll recall that when a user fills out a form on an HTML page, the
browser will collect together the form data and send either a GET or
POST request to the URL defined in the `action` attribute, depending on
the `method` attribute. When the method is GET, the form data will be
encoded and added to the URL in the GET request; when the method is
POST, the form data is encoded in the same way but this time is sent as
the *body* of the request.

Just as we can make requests for web pages using `urlopen` we can also
mimic the behaviour of the browser in sending form data back to a
server. By default, `urlopen` will send a GET request when given a URL
but if we supply an extra `data` argument, it will send a POST request.
We can use this facility to automate the submission of forms on the web.

There are many reasons one might wish to automate form submission.

-   Automated testing of web applications: if we are able to send
    requests, including form submissions, it is possible to write a
    script to automate functional testing of an application.
-   Automating search: being able to submit queries to a search engine
    automatically can help in evaluating the visibility of a site to
    different search terms.
-   Automating messaging: imagine a service that can send out a message
    as a Tweet and a Facebook post. This could be implemented by a
    script that submitted forms to the respective services.
-   Repetitive tasks: we can automate a repetitive task such as sending
    messages to a large number of users or submitting multiple entries
    for an online competition.

This last example highlights how it might be possible to behave badly
with this knowledge of how to script HTTP requests. It is relatively
easy to submit large quantities of votes for online polls or entries for
competitions with a script. If you are running such a website, you will
want to guard against this kind of behaviour if you want your poll to be
representative or your competition fair. We'll look at the problem of
blocking this behaviour later in this chapter.





Sending a GET Request
---------------------

```
<form method='GET' action='http://bing.com/search'>
    <label for='q'>Query:</label><input name='q'>
    <label for='first'>First Result</label><input name='first'>
    <input type='submit'>
</form>
     
```

This form can be used to send a query to the [Bing](http://bing.com)
search engine from Microsoft. There are other form fields that are
normally sent but just sending the `q` field will get a page of results.
I've also added the `first` field which tells Bing which result to start
with - this is used in returning the different pages of results. (Note
that Google used to support queries like this but has now made it more
complicated to send queries from third party sites). To simulate this
query from a script we need to send the form field in a GET request.
This means encoding it as part of the URL following a `?` character; so
to search for 'cheese' we would send a GET request to
`http://bing.com/search?q=cheese&first=0`. For a simple query this is
just a string concatenation but in general, we are supposed to encode
the query string so that characters that are not allowed in a URL are
replaced by entities. To search for "Steve's Homepage" we need to add
`Steve%27s%+Homepage` - for a discussion of the encoding scheme see
[Percent-encoding](http://en.wikipedia.org/wiki/Percent-encoding) on
Wikipedia.

Luckily we don't need to implement this encoding ourselves, `urllib`
contains a function `urllib.parse.urlencode` to do this for us. Using
this, we can write a function to submit a query to Bing as follows:

```
from urllib.parse import urlencode
from urllib.request import urlopen

def bingsearch(term, first):
    """Perform a search on Bing for this term, return 
    the resulting search page starting with the result
    number 'first'"""
    
    url = "http://bing.com/search"
    
    data = urlencode({'q': term, 'first': first})
    
    queryurl = url + "?" + data
    
    fd = urlopen(queryurl)
    content = fd.read()
    fd.close()
    
    return content.decode('utf-8')
     
```

The `urlencode` function takes a dictionary of form fields and values
and returns a string with the encoded data. This string is then added to
the end of the URL following a `?` character and the page is requested
as in the previous chapter. The resulting page will contain all of the
links to matching pages found by Bing. We could use the `get_links`
function from the previous chapter to extract the links from the page
for further processing.





Sending a POST Request
----------------------

```
<form action='/submit' method='POST'>
    <label for='name'>Name</label>:<input name='name'>
    <label for='age'>Age</label>: <input name='age'>
    <input type='submit'>
</form>
     
```

For an example of a POST request we will consider the above form that
can be used to submit a name and age to a web application. If this form
is served from the page `http://127.0.0.1:8080/form` then the URL we
need to submit to is `http://127.0.0.1:8080/submit`. The code to submit
the form is similar to the GET example above, but this time we need to
pass the form data to the `urlopen` function instead of adding it to the
URL. Here is the code:

```
def send_name_age(name, age):
    """Perform a search on Bing for this term, return 
    the resulting search page starting with the result
    number 'first'"""
    
    url = "http://127.0.0.1:8080/submit"
    
    data = urlencode({'name': name, 'age', age})
        
    fd = urlopen(url, data.encode('utf-8'))
    content = fd.read()
    fd.close()
    
    return content.decode('utf-8')
     
```

To pass data into `urlopen` it must be formatted as a byte string, this
is the reason for the call to `data.encode('utf-8')`. Again the content
returned will be whatever the web application returns in response to
this form submission.

It is worth noting that `urlopen` will by default follow any "303 See
Other" (redirect) responses that it gets in response to the initial
request. That means that if you send a login request with a username and
password which returns a redirect response, you will get back the
contents of the redirected page.

In the example of a login page, it would be common to have a cookie
returned with the response. If we wanted to carry out requests on behalf
of the logged in user, we would need to save the cookie and send it back
to the site in later requests, just as the web browser would do. Python
provides an object called
[`CookieJar`](https://docs.python.org/3/library/http.cookiejar.html#http.cookiejar.CookieJar)
to keep track of cookies. To use it we need to install a custom request
handler for the `urllib` module:

```
import http.cookiejar, urllib.request
cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
r = opener.open("http://example.com/")
    
```

Once installed, the cookie jar will keep track of cookies in the same
way that the browser does, sending them back to the appropriate sites
when requests are made.





Blocking Automated Scripts
--------------------------

Given the ease with which we are able to write scripts to automate web
requests, it would seem to be difficult to ensure that any poll or
competition on the web could be run fairly. An application running such
a service would need to take steps to limit automated responses. Some
examples of how to do this are listed here, along with ways to get
around them:

-   Use a cookie to keep track of users and prevent multiple submissions
    from the same user. Easily fooled by not taking notice of cookies -
    or taking notice only enough to submit the form.
-   Hide your form through Javascript. The page returned contains one
    form but Javascript is used to modify it in some way - by adding
    fields or changing the action URL. Get around this by looking at the
    HTTP traffic sent when the form is submitted by the browser.
-   Keep track of user IP addresses, only allow one submission per
    IP address. This is harder to fool but can backfire since many
    organisations will share a single IP address over multiple users, so
    you would be blocking all employees from taking part if you blocked
    on IP address.
-   One entry per email address. To get around this I can either fake an
    email address or if you require me to authenticate by sending a
    message to the address, I can set up as many fake email addresses as
    I wish using various mail services.
-   Rate limiting: only allow a certain number of requests per
    second/minute/hour from a given IP address. This is better than
    blocking the address all together but I can fool it by slowing down
    the rate at which I send in votes. This means I get less votes but I
    can still beat the system if I run for long enough.
-   Require a CAPTCHA: make the user enter text from a fuzzy image.
    These devices are meant to tell the difference between people and
    scripts and are difficult to break. There has been use of machine
    learning methods to automatically crack the image codes but the most
    cost effective way is to pay people on the 'net to enter them
    manually - this can be worthwhile if the pay-off for submitting many
    forms is sufficient.
-   Require verified registration before accepting a submission. This
    will be more difficult to break if registration requires responding
    to an email and decoding a CAPTCHA but in the end it may just slow
    down the level of automation rather than stop it.

In the end it is an arms race between the people running the service and
the people trying to automate submissions. Ultimately anything that can
be done in a browser can probably be done by a script so we should be
very careful about what transactions are allowed over the net and the
level of trust we can place on them.





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
