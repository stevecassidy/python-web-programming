
An AJAX Example
---------------

To show an example of an AJAX application we will develop an AJAX
version of the *likes* application that has been used in previous
chapters. As a starting point we'll use the version that was developed
in the [Web API](../data/webapi.md) chapter but modified so that it
will only serve an HTML page for the root URL (`/`) - all other pages
return JSON responses. The database (model) part of the application is
the same; here is the controller part:

```python
@app.route('/')
def index():
    """Home page"""
    info = dict()
    info['title'] = 'AJAX ListMaker!'
    return template('jsonlikes.tpl', info)
        
@app.post('/likes')
def like(db):
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
def getlikes(db):
    """Get a JSON version of the likes data"""
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
contain any data (the `index` handler does not reference the database)
and so the first thing we will need to do is to retrieve the list of
likes and include them in the page. Here is the outline of a function
that creates a request object to query the `/likes` URL:

```javascript
function displayLikes() {
    
    var httpRequest = makeRequest();

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
    var text = "";
    var result = JSON.parse(this.responseText);
    for(var i=0; i<result.likes.length; i++) {
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
    
    var httpRequest = makeRequest();

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
