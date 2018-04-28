Javascript Events
=================

One of the ways to run Javascript code is in response to actions taken
by the user on the page. Javascript supports a number of event handlers
that are triggered by user interaction. Examples are the `click` event
handler which can be added to any element to trigger a fragment of code
to run when the user clicks on that element.

The easiest way to add a handler for an event is to use a HTML attribute
inline in the page. The attributes for each event are prefixed by the
word 'on', so to set a `click` event handler I would add an `onClick`
attribute to an element:

```HTML
<img src='foo.jpg' onClick="alert('this is a test');">
        
```

In this case the fragment of javascript code would run if the user
clicked on this image. Any javascript can be included in an attribute
value but it is best to keep this brief and just call a handler function
that is defined in a script block elsewhere on the page.

Another way to add handlers is via the `addEventListener` method for a
DOM element. This has the advantage that it can be done from within a
code block running elsewhere in the page and that it can add multiple
handlers for a single event to an element. Here's an example from the
[Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener) 
on using this method:

```javascript
// Function to change the content of t2
function modifyText(new_text) {
  var t2 = document.getElementById("t2");
  t2.firstChild.nodeValue = new_text;    
}
// Function to add event listener to table
var el = document.getElementById("outside");
el.addEventListener("click", function(){modifyText("four")}, false);
```

The sample code defines a handler function `modifyText` which is then
attached to the element with id "outside". Note that the second argument
given to `addEventListener` is an anonymous function that calls the
handler with a given argument and returns false.

There's a good list of the different events and the browsers that
support them on [this MDN page](https://developer.mozilla.org/en-US/docs/Web/Events).


