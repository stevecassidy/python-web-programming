
JQuery 
===

Javascript is a complicated language and the environment of the
browser is also complicated and can be hard to understand. Because of this, 
there have been many tool-kits and libraries developed to simplify 
one or other part of the task of writing applications in Javascript. 
Some of these took-kits take a very opinionated view of how you should
write applications and provide a rich framework for the developer to
work in.  They can be quite powerful but they also have a steep learning
curve.  

This text and the course it supports is intended to teach you about how 
the technology of the web works and how things fit together to make
web applications.  From this perspective, we want to see how Javascript
interacts with the DOM within the browser and how it responds to events
to build an interactive application interface.  Using a high level tool-kit
hides a lot of the detail from the developer (for good reason) so doesn't 
serve our purpose very well.  However, using just plain Javascript makes
some things very complicated, in particular some of the things we want to be
able to do such as navigating through elements in the page, adding event
handlers and modifying the contents of the DOM.  So, there is some value in
using a toolkit that helps us with some of this but still allows us to
see what is going on at the Javascript level. For this reason we'll
make use of the [JQuery](https://jquery.com/) toolkit and this chapter gives an introduction
to it's capabilities.  

## Using JQuery

JQuery is a Javascript library but the language doesn't provide any way for 
your script to import a library in the same way that we can with Python or
Java.  Hence the way to use JQuery is to make sure that it is loaded into the
browser before any scripts that make use of it.  We mentioned before that
the best practice is to load Javascript files at the end of the body of the
html page, so if we are using JQuery we would load this first and then load 
any script files of our own. 

There are two options for loading JQuery. You can [download a version of 
the library](https://jquery.com/download/) and include it with your other
static assets as part of your project. You would then refer to it as 
something like:

```html
<script src="/static/js/jquery-3.3.1.min.js"></script>
```
Here `3.3.1` is the version of the JQuery library and `.min` refers to a
_minified_ version of the Javascript code.  This is a version with all 
of the comments and whitespace removed and with all variables replaced
by one or two character variable names.  This is a way of compiling
Javascript for delivery to the browser that makes it smaller.  Tools such
as [Webpack](https://webpack.js.org) do this to your Javascript code 
as well as many other things to help manage a web project. 

The other alternative is to load JQuery from a Content Delivery Network
(CDN).  This is a hosting network that is used to host very commonly used
files such as the JQuery library.  The CDN will serve the file from a server
as close to the client as possible from a collection of servers around
the world.  For JQuery the official CDN is at [https://code.jquery.com/](https://code.jquery.com/)
so we can include a version of the library like this:

```html
<script src="https://code.jquery.com/jquery-3.3.1.min.js"
        integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
        crossorigin="anonymous"></script>
```
Note the extra attributes here. `integrity` is a new standard called
[Subresource Integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)
that includes a base64-encoded sha384 hash of the file in the integrity 
attribute. This allows the browser to check that the file it downloads is the
one that was intended and guards against an attack that replaces a common
library with compromised code. This is important when you are trusting a third
party (the CDN) with hosting your code since they could easily replace your 
file with one containing malicious code. This standard is just starting to 
be supported by browsers. 

Having loaded the JQuery library we can start to make use of it. 

### Using JQuery as $

The JQuery library defines one new object called `jQuery` and all functions
can be called as methods on this object.  However, since this will be used
very frequently in our code it also defines the object to `$` as well.  `$` is
just a variable and any module could define it but it is most commonly used
by JQuery.  Most of our examples here will use `$` as the main JQuery function. You should
be aware that it is just a function name, not any new syntax for the Javascript language.

### Selecting things with JQuery

The first thing to look at with JQuery is how to select parts of the HTML DOM 
to work with.  While plain Javascript would use `document.getElementById` etc. 
JQuery makes it easy to select one or more elements in a similar way to 
the way we do in CSS stylesheets.  So to find all of the anchor (`<a>`) tags
in the document we use the expression:

```javascript
$("a")
```

To find the element with a given id we would use the CSS `#` prefix:

```javascript
$("#content")
```

JQuery can use the full range of CSS selectors plus a few other things to 
locate parts of the HTML DOM.  The result is either a single element or a 
collection of elements.  

### Chaining Operations

Once we have identified some elements we can operate on them by _chaining_ 
an operation using a dot after the selector.  For example, to set the color
of all second level headings to red:

```javascript
$("h2").css("color", "red")
```
Another example would be changing the content of these elements. This expression
would change them all to the same text:

```javascript
$("h2").text("New Heading")
```

Chaining can keep going adding operations one after another, so we could achieve both
of these changes like this:

```javascript
$("h2").css("color", "red").text("New Heading")
```
(What is happening here is that each operation returns a JQuery object representing
the node or nodes and so the next dotted method just applies to the same group 
after the change is made).

Operations can do various things in JQuery but we'll look at two main categories:
changing the content of the DOM and adding event handlers.  Changing the CSS style
is an example of changing the DOM. 

### Adding Event Listeners

Javascript is an event driven language and the browser environment has many events
that can be triggered by the user or by network events.  We can set up _listeners_
to handle these events using plain Javascript as described in the [Events](events.md)
chapter. Using JQuery this process is simplified and because we can select multiple
elements with one expression, it is easier to add event listeners to many elements
at once.  

A simple example would be to change the color of an element when the user 
clicks the mouse on the element.  To do this we add a `click` handler as follows:

```javascript
$("h3").click(function() {
    $(this).css("color", "red")
})
```

Here we define an anonymous function as the click handler for all `<h3>` elements. The
function uses the selector `$(this)` which refers to the element that has been clicked
on and changes the CSS for that element to red.  To achieve the same thing with 
plain Javascript would require a few more lines of code and we would need to apply the
click event handler to each element separately.  

As a side note, it would be possible to define a named function and apply it as the click
handler as follows:

```javascript
function h3click() {
    $(this).css("color", "red")
}
$("h3").click(h3click)
```

this would have the same effect but is a little bit more verbose and not really any clearer
than the version with the anonymous function.  Common practice in JQuery coding is to use
anonymous functions as in the first example; you should get used to this style of coding. 


### The Document Ready Event

One very common requirement is to run some code once the page has finished loading.  As the 
browser loads and interprets the HTML of the page it builds the DOM for the page and loads
any related resources (scripts, css, images).  Until this has completed, we don't want to run
any scripts that will modify the page.  A common way to achieve this is to bind to the
`window.onload` event which is triggered by the browser when the page has loaded.  JQuery
provides an interface to this which actually tries to run the code a little bit earlier - when
the DOM has been built even if images and other resources are still being downloaded.  This
is the `$(document).ready` handler:

```javascript
$(document).ready(funciton(){
    /* code to run when DOM is ready */
})
```

Your scripts can contain more than one call to `$(document).ready()` to have multiple code
fragments run when the DOM is ready.  

Note that if your scripts depend on looking at images, you will want to wait a little longer
to run your scripts and bind to `window.onload` instead.  In jQuery you can do this with:

```javascript
$(window).load(function() {
    /* code that manipulates images goes here */
})
```

## JQuery Examples

