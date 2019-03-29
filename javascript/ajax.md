AJAX
====

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

## The Role of JavaScript

Recall that JavaScript can be used to change the contents of HTML
elements. The `innerHTML` property can be used to set or retrieve the
HTML between the start and end tags of an object. Here's a simple
example:

```html
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
      var httpRequest = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        var httpRequest = new ActiveXObject("Msxml2.XMLHTTP");
      } 
      catch (e) {
        try {
         var httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
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
httpRequest.onreadystatechange = function() {
        if (this.readyState === 4) {
            if (this.status === 200) {
                text = this.responseText;
                alert(this);
            }
        }
}
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

```javascript
    httpRequest.open('GET', '/likes');
    httpRequest.send(null);
```

Only when the `send` method is called is the request actually made. The
main Javascript thread then continues (to handle any other user input)
and the callback function will be called when the response returns.

Here is a summary of the properties of the `XMLHttpRequest` object
including a few that we've not yet mentioned.

 | Property           | Description
 |--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 |onreadystatechange  | Reference to an event handler function/method that is called on every state change in the request.
 |readyState          |The [state of the object](http://msdn.microsoft.com/en-us//library/ms534361%28en-us,VS.85%29.aspx): 0 (uninitialized) 1 (loading) 2 (loaded) 3 (interactive) 4 (complete)
 |responseText        |the response as a string
 |responseXML         |the response as an XML DOM object or `null` if the response was not XML
 |status              |The response status code (eg. 200)
 |statusText          |The response status text (eg. "OK")
 |----

## XML and JSON Data

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
var nameNode = response.responseXML.getElementsByTagName("name")[0]
// get the first child (text) node
var nameTextNode = nameNode.childNodes[0]
// get the text content
var name = nextTextNode.nodeValue
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

## AJAX in jQuery

[jQuery](jquery.md) is a Javascript library that makes many common Javascript
tasks easier to express.  jQuery has support for AJAX requests that make
the common cases a lot clearer in code. The code for the previous example 
to make a request to the `/likes` endpoint and handle the returned 
JSON data would look like this: 

```javascript
$.get({
    url: '/likes',
    success: {function(data) {
        console.log(data.name)
        console.log(data.dance)
    }}
})
```

The `$.get` function implements the common case of sending a GET request and takes
an object parameter that has properties defining the URL to request and a function
to call when the request returns.   This success function is called with the data
that was returned and if this data was in JSON format, we can immediately make
use of it (if the data was XML we can also handle it in a similar way to 
the example above).   

jQuery also provides a `$.post` function to make a POST request or the more general
`$.ajax` function that can send any kind of request with the appropriate configuration. 
For example, to send a POST request with two form variables: 

```javascript
$.post({
    url: '/comment',
    data: {
            'user': 'Steve',
            'message': 'Hello World!'
    },
    success: function(data) {
        console.log("post succeeded")
    }
})
```

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
page based model. It can avoid redundancy since the data does not need to
be re-sent for every page refresh and all of the HTML decoration around
the data only needs to be sent once.

If we look at the requirements for this kind of architecture it meshes
very well with the kind of [Web API](../data/webapi.md) that we
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
sometimes called 
[Backend as a Service](http://en.wikipedia.org/wiki/Mobile_Backend_as_a_service) (BaaS
or sometimes Mobile Backend as a Service due to its popularity for
mobile development). These services provide the basic CRUD operations on
a database via an HTTP JSON API that can be used from your web or mobile
application.

