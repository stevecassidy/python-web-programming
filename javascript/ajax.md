

AJAX
====



About AJAX
----------

[AJAX](https://developer.mozilla.org/en/AJAX) stands for Asynchronous
Javascript and XML. It is a simple coding technique that allows
Javascript code to make HTTP requests but gives rise to an important
architectural style for building web applications. AJAX allows the
developer to break the normal cycle of web behaviour where each action
results in the delivery of a whole HTML page. Instead, an AJAX request
can be made to return just enough data to update the current page to a
new state. This changes the web from a *page based* application to one
where a user interface presented in a web browser carries out
transactions on a remote server. As such, AJAX has made a significant
difference to the way that web applications are written and to the user
experience of the web.

AJAX refers to two main technologies: Javascript and XML. Javascript is
the scripting language implemented in the browser that is used to make
requests and update the page being viewed. XML is the language used to
exchange data between the server and the browser client. However, AJAX
techniques can be used with other data formats and it is now much more
common to use JSON for data interchange than XML. The AJAX acronym is so
well known now that changing it to AJAJ is unlikely even if it better
reflects current practice.

The other keyword in AJAX is *Asynchronous* which means that the
requests that are sent by Javascript do not block the further execution
of the script. The request is sent and is executed in the background.
When the response is returned by the server, the system calls a function
that has been registered as a *callback* at the time of the request. The
callback function handles the response and updates the page. This
asynchronous behaviour means that the main script can continue to
process user interaction while the request is in progress, meaning that
the application always feels like it is 'live' to the user.

A common web transaction is submitting a form to update some piece of
information presented in a page. For example, adding a new message to a
conversation in a forum. In the regular web context the HTML page is
delivered containing the current conversation and a form to submit a new
message. The user enters the message and submits the form. The server
stores the new message and returns a new page with all of the old
messages plus this new one. Clearly there is redundancy here since the
old messages are sent multiple times to the client. Using AJAX, the form
is submitted via a Javascript request, the response comes back as a JSON
(or XML) and is inserted into the current page. The old messages don't
need to be re-sent and so the response appears much faster and less
network bandwidth is used.

This change makes web applications much more similar to desktop
applications in the way that they update the display and transfer
information. It allows web applications to be more responsive and to
continue to react to user input due to the asynchronous nature of the
request. This has allowed the web to be used as a platform for
developing versions of traditional desktop applications such as mail
readers, word processors and spreadsheets. The web has become a
cross-platform implementation option for developing sophisticated
applications.





The Role of JavaScript
----------------------

Recall that JavaScript can be used to change the contents of HTML
elements. The `innerHTML` property can be used to set or retrieve the
HTML between the start and end tags of an object. Here's a simple
example:

```
<html>
  <head>
    <title>Demo: Change Unit</title>
  <head>
  <body>

    <script type='text/javascript'>
    function change_unit() {
        document.getElementById('strong_text').innerHTML = 'COMP348';
    }
    </script>

    <p>Welcome to <strong id='strong_text'>COMP249</strong></p>
    
    <input type='button' onclick='change_unit()' value='Change Unit'/>
  </body>
</html>
        
```

In contrast to the script above, in an AJAX script, the data that is
inserted into the page comes from a request sent back to the server.
This is enabled by the `XMLHttpRequest` object in Javascript which
embodies an HTTP request and allows the script to process the response
to the request without blocking the rest of the browser interface.
`XMLHttpRequest` was first introduced in Internet Explorer 5 and later
copied in an incompatible way by Mozilla and other browsers. The Mozilla
implementation became more widely used and is now standard in all modern
browsers, however for code to work in older versions of Internet
Explorer you will usually use the following code to create a new request
object:

```javascript
  function makeRequest() {
    if (window.XMLHttpRequest) { // Mozilla, Safari, ...
      httpRequest = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        httpRequest = new ActiveXObject("Msxml2.XMLHTTP");
      } 
      catch (e) {
        try {
          httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
        } 
        catch (e) {}
      }
    }
    return httpRequest;
  }
        
```

This function creates a new request object and returns it. Our script
can then use this request object by providing a URL, a payload (for a
POST request) and a callback function. The callback function will be
called when the request returns and will be passed the response that
comes back. Here is an example callback function:

```javascript
httpRequest.onreadystatechange = function(){

        if (this.readyState === 4) {
            if (this.status === 200) {
                text = this.responseText;
                alert(this);
            }
        }
};
        
```

This callback function just pops up an alert box with the text returned
from the request. The request object is accessed via the Javascript
`this` variable - the callback function is actually a method of the
request object and `this` refers to the current instance as it does in
Java or C++. The first thing the function does is to check the
`this.readyState` which is used to indicate the status of the request. A
value of 4 means that the request is complete (other values tell you
that the request is in different stages of progress); this indicates
that this callback function might be called before things are really
done so we first check that all is well and only then try to process the
result. We then check `this.status` to make sure that the request
succeeded. This means that we don't want to do anything if we got a 404
or other error response - although we could carry out a different action
in this case. `this.responseText` is the verbatim content of the
response that the server sends back. This sample callback function uses
this to create an alert box.

The details of what will happen when the request has returned are now
set up but we've not yet made the request. To do that we need to set the
URL and request method and then invoke the request. Here's an example of
how to do that:

```
    httpRequest.open('GET', '/likes');
    httpRequest.send(null);
        
```

Only when the `send` method is called is the request actually made. The
main Javascript thread then continues (to handle any other user input)
and the callback function will be called when the response returns.

Here is a summary of the properties of the `XMLHttpRequest` object
including a few that we've not yet mentioned.

  Property             Description
  -------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  onreadystatechange   Reference to an event handler function/method that is called on every state change in the request.
  readyState           The [state of the object](http://msdn.microsoft.com/en-us//library/ms534361%28en-us,VS.85%29.aspx): 0 (uninitialized) 1 (loading) 2 (loaded) 3 (interactive) 4 (complete)
  responseText         the response as a string
  responseXML          the response as an XML DOM object or `null` if the response was not XML
  status               The response status code (eg. 200)
  statusText           The response status text (eg. "OK")





XML and JSON Data
-----------------

Two properties of the XMLHttpRequest object may contain data:
`responseXML` stores a DOM structured object of any XML data;
`responseText` stores the data as one complete string. As an example of
handling XML data, assume that the response is an XML document
containing the following:

```XML
<?xml version="1.0"?>
<lecturer>
  <name>Bob Bobalooba</name>
  <dance>The Boogaloo</dance>
</lecturer>
```

The `responseXML` property of the response is a standard DOM object so
we can use the DOM methods to access the data. Here's example code to
get the name value from this document:

```javascript
// get the first 'name' tag
var nameNode = response.responseXML.getElementsByTagName("name")[0];
// get the first child (text) node
var nameTextNode = nameNode.childNodes[0];
// get the text content
var name = nextTextNode.nodeValue;
    
```

Having extracted the data from the XML document we could now update the
page or carry out whatever user action we wanted following the request.

Note how `XMLHttpRequest` makes handling an XML response easy - this is
what it was designed to do and at the time it was put forward, the
expectation was that XML would be used in the response. We are now more
commonly using JSON in the response, that needs a little more work but
is overall a lot easier to handle.

There is no built in support for JSON responses but it is easy to parse
the `responseText` that is returned into a Javascript object or list.
While we could just use the `eval` function in Javascript to evaluate
the JSON text as code, it is safer to use the JSON parser package which
is not vulnerable if the JSON contains some executable code as well as
data. To repeat the earlier example from XML, here is a JSON
representation of that data:

```javascript
{
    'name': 'Bob Bobalooba',
    'dance': 'The Boogaloo'
}
```

To parse this we can use the built in `JSON` object as follows:

```javascript
var result = JSON.parse(this.responseText);
var name = result.name;
var dance = result.dance;
    
```

You can see from this code why developers prefer JSON to XML for writing
web scripts, there is no overhead to find the relevant bits of
information in the XML DOM, we just access the Javascript object that is
constructed. Add to this the faster parsing speed for JSON vs. XML and
it is clear why JSON is preferred in most applications.





AJAX Application Architecture
-----------------------------

The architecture of applications we have dealt with up to now has been
based on delivering new pages for each transaction that is carried out
by the user. The page is constructed on the server via a template and
sent back to the client. If we want to add a new message to a list, the
user sends a form, we add it to the database and redirect to the main
page; when the main page is requested we query the database and
construct a new page with the new message.

AJAX enables a different architecture. We can deliver a single starting
page containing no data but with Javascript code to query the server and
populate the page with messages. Submitting a new message can be done
via an AJAX call which could return the additional content that needs to
be added to the page (or a full list of messages if new ones might have
been added elsewhere). Following the AJAX call the page can be updated
with the new information. In this model we only ever deliver one HTML
page to the client, the rest of the data and interaction is done via
AJAX requests.

The AJAX model can be a lot more efficient and responsive than the older
page based model. It can avoid redundancy since the data doesn't need to
be re-sent for every page refresh and all of the HTML decoration around
the data only needs to be sent once.

If we look at the requirements for this kind of architecture it meshes
very well with the kind of [Web API](../dataweb/webapi.html) that we
discussed in an earlier chapter. We want to be able to request data as
JSON so that we can update the page. We want to be able to submit
requests from Javascript and get JSON responses. All of this is provided
by the kind of Web API discussed earlier.

So, in implementing an AJAX application we can have well delineated
client-server architecture where the server implements an HTTP based API
returning JSON and the client is written in Javascript hosted in a
single HTML page.

This architecture is also well suited for adaption to different
front-ends for different purposes. We've already seen that the HTTP API
can be used to interface Python scripts to web data and this use of
HTML/Javascript clients is a second use case. A third and very important
use case is the mobile application. A mobile app can use a Web API to
interact with a transactional data store; the app might be implemented
as a native application or a mobile web application -- this is just a
variation on our HTML/Javascript client with a design that is suited to
the mobile device.

This kind of design is now embodied in a new kind of service provider
sometimes called [Backend as a
Service](http://en.wikipedia.org/wiki/Mobile_Backend_as_a_service) (BaaS
- or sometimes Mobile Backend as a Service due to its popularity for
mobile development). These services provide the basic CRUD operations on
a database via an HTTP JSON API that can be used from your web or mobile
application.





An AJAX Example
---------------

To show an example of an AJAX application we will develop an AJAX
version of the *likes* application that has been used in previous
chapters. As a starting point we'll use the version that was developed
in the [Web API](../dataweb/webapi.html) chapter but modified so that it
will only serve an HTML page for the root URL ('/') - all other pages
return JSON responses. The database (model) part of the application is
the same; here is the controller part:

```

@app.route('/')
def index():
    """Home page"""

    info = dict()
    info['title'] = 'AJAX ListMaker!'

    return template('jsonlikes.tpl', info)
    
@app.post('/likes')
def like():
    """Handle the /likes POST request from a JSON submission"""
        
    if 'likes' in request.json:
        likes = request.json['likes']
    else:
        likes = []

    for like in likes:
        if like != '':
            store_like(db, like)
    
    return "Success"

@app.get('/likes')
def getlikes():
    """Get a JSON version of the likes data"""
   
    db = COMP249Db()

    info = dict()
    # get the list of likes from the database
    info['likes'] = get_likes(db)
    
    return info


@app.route('/static/')
def static(filename):
    return static_file(filename=filename, root='static')
```

The application will accept a JSON POST submission to register one or
more new likes and will respond to a GET request on '/likes' with a JSON
list of likes. To build an AJAX application from this we need an HTML
page that makes appropriate AJAX calls. The original page will not
contain any data (the `index` handler doesn't reference the database)
and so the first thing we will need to do is to retrieve the list of
likes and include them in the page. Here is the outline of a function
that creates a request object to query the `/likes` URL:

```
function displayLikes() {
    
    httpRequest = makeRequest();

    httpRequest.onreadystatechange = function() {
        if (this.readyState === 4) {
            if (this.status === 200) {
                // process the response
            }
        } 
    }
    
    httpRequest.open('GET', '/likes');
    httpRequest.send(null);
}
```

The callback handler needs to take the JSON response and parse it to
extract the list of likes. Recall that the JSON response will have the
following form:

```javascript
{
    'likes': ['eggs', 'cheese', 'bread']
}
```

Our goal is to display this in the HTML page. If we assume that the page
has a `<ul>` element with a known identifier then our handler just needs
to insert the list items into this element for display. So, in our
starter HTML page we will add:

```HTML
 <ul id='things'>
 </ul>
    
```

We can now insert list items for each liked thing as follows:

```javascript
    text = "";
    result = JSON.parse(this.responseText);
    for(i=0; i<result.likes.length; i++) {
        text += "<li>" + result.likes[i] + "</li>";
    }
    document.getElementById('things').innerHTML = text;
    
```

This code constructs a string consisting of the list item elements and
inserts them as the `innerHTML` property of the unordered list. This
replaces the previous contents of the list and so updates the display.
An alternative would be to use the DOM interface to create new elements
and contents but this code has the same effect and is simpler.

Having written this code we need to arrange for it to be called when the
page is loaded so that the initial list of items are displayed in the
page. To arrange for this we can use the `window.onload` property which
should be set to a function that will be called when the page in the
current browser window has finished loading. In our case we want
`displayLikes` to be called so we add the following inside the `<head>`
of the page:

```HTML
<script language='javascript'>
    window.onload = displayLikes;
</script>
        
```

### Handling Updates

The next task is to handle new likes entered by the user. In the
original application these were handled by a simple form submission that
prompted a page reload. We want to use the same form but instead of
submitting it directly we will construct a JSON POST request instead. So
the form doesn't need a `method` or `action` attribute. We remove these
and add an id for the input element so that we can identify it from the
Javascript handler:

```HTML
  <form>
      <legend>What do you like? </legend>
      <ul>
        <li><input id='likeinput' name='likes'></li>
      </ul>
      <button onclick='return formsubmit();'>Submit</button>
  </form>
        
```

The submit button on the form has been replaced with a `button` element
where we have set an `onclick` handler that will call the function
`formsubmit` when pressed. Note the technique here that the `onclick`
handler returns the value of the function. If the handler returns
`false` then the form will not be submitted (recall that the default
action is to submit the form to the same URL as the page, so not setting
an action doesn't prevent submission).

The job of the `formsubmit` handler is to take the text entered in the
input box, construct the right JSON data and send a POST request back to
the server. When the request returns, it should arrange to call the
`displayLikes` function to update the display. Here's the implementation
of `formsubmit`:

```javascript
function formsubmit(){
    
    httpRequest = makeRequest();

    httpRequest.onreadystatechange = function() {
        if (this.readyState === 4) {
            if (this.status === 200) {
                displayLikes();
            }
        } 
    }
    
    // set up the request parameters
    httpRequest.open('POST', '/likes');
    list = [document.getElementById('likeinput').value]
    data = JSON.stringify({'likes':  list});
    
    httpRequest.setRequestHeader('Content-Type', 'application/json');
    httpRequest.send(data);

    // reset the form entry
    document.getElementById('likeinput').value = "";
    
    return false;
}
    
```

The first part of the function sets up the AJAX callback function which
just calls `displayLikes` to update the page. The second part sets up
the rest of the request parameters. We construct the data to be sent by
first creating a list containing the value entered in the `likeinput`
entry in the form. We use `JSON.stringify` to create a JSON string
representation of the object with a single `likes` attribute. We then
set the content type of the request and send the request with the JSON
data as the payload.

The final step in the function is to reset the value in the form to the
empty string and return `false` so that the form is not submitted.

We can put all of the Javascript code together in a single `likes.js`
file that is then loaded in the head of the HTML page.

```HTML
    <head>
        <title>List Maker</title>
        <script src='/static/likes.js'></script>
        <script language='javascript'>
            window.onload = displayLikes;
        </script>
    </head>
        
```

This is a relatively simple AJAX application. It illustrates the use of
a single HTML page with no content that uses Javascript to make AJAX
requests to update the page content and to submit requests to the
server. The same architecture can be used for much more complex
applications. Next time you visit Facebook or GMail, note how the
initial page loaded is essentially empty and the content arrives after a
bit of script activity. If you use your browser tools to observe the
requests being made, you will see AJAX in action.



<div class="slide">

### Benefits of AJAX

AJAX has the following benefits:
better performance and efficiency
-   small amount of data transfer from the server

more responsive interfaces
-   creating the illusion that updates happen instantly

reduced or eliminated waiting time
-   only the relevant page elements are updated

increased usability
-   client can communicate with the server without page loads.



<div class="slide">

### Potential Problems

Benefits look attractive, but there are a few drawbacks:
writing and maintaining complex JavaScripts
-   requires substantial JavaScript skills

breaking the page paradigm
-   the concept of a page is no longer valid

accessibility
-   changes may not be detected by screen reader tools

new UI interactivity requires learning
-   new and unexpected functionality might be confusing.



<div class="slide">

### Security Issues

-   The request must go to the same domain as the source web page.
-   Restriction is implemented by browsers to prevent cross-site
    scripting attacks.



<div class="slide">

### Toolkits

-   Writing AJAX code is complex and error prone.
-   Many common tasks have been factored out into toolkits.
-   Using [toolkits](http://ajaxian.com/resources/) takes advantage of
    the work of smart people.
-   For example:
    -   [The Dojo Toolkit](http://dojotoolkit.org/): The kitchen sink
    -   [Script.aculo.us](http://script.aculo.us/): rich effects built
        on Prototype
    -   [jQuery](http://jquery.com/): a fast and concise JavaScript
        library
    -   [ExtJS](http://extjs.com/): a cross-browser JavaScript library
    -   [MochiKit](http://www.mochikit.com/): MochiKit makes JavaScript
        suck less





[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
