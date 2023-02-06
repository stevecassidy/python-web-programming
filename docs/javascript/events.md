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
  let t2 = document.getElementById("t2");
  t2.firstChild.nodeValue = new_text;    
}
// Function to add event listener to table
let el = document.getElementById("outside");
el.addEventListener("click", function(){modifyText("four")}, false);
```

The sample code defines a handler function `modifyText` which is then
attached to the element with id "outside". Note that the second argument
given to `addEventListener` is an anonymous function that calls the
handler with a given argument and returns false.

There's a good list of the different events and the browsers that
support them on [this MDN page](https://developer.mozilla.org/en-US/docs/Web/Events).

## `this` in Event Listeners

The variable `this` in Javascript is used in object methods to refer to the
object instance that the method was called on.  It behaves like the
`self` argument used in Python but it is defined implicitly rather than
having to be included as a parameter.  We can also use `this` in the context
of an event handler because of the way that events are managed in the DOM.  
In an event handler `this` refers to the element that captured or triggered
the event that the handler is responding to.  Generally this is the element 
that the event listener has been added to.   Here's an example:
```javascript
let el = document.getElementById("outside")
el.addEventListener("click", function(){
    this.css("color", "red")
});
```
In the `click` handler defined here as an anonymous function, `this` will refer to
whatever element received the click event. As the handler was bound to the element
with id `outside`, then `this` will refer to that element. 

One note of caution here. You may have seen the alternate form of functions (arrow functions)
mentioned in the [Javacript chapter](javascript.md) used in some examples.  This is a
more compact way of writing functions and is often useful in callback functions like this.
However, one significant difference between these and regular functions is that arrow
functions do not get a special `this` variable.   There's a reason for this which we'll discuss
below, but it means you need to be aware of this when you write a callback.  So the above example
would not work as an arrow function:

```javascript
let el = document.getElementById("outside")
el.addEventListener("click", () => { this.css("color", "red") });   // bad - there is no this variable
```

If you try this, you'll get an error message saying `this.css` is not a function.  

The reason for this behaviour is because of a common pattern of use where we create an 
eventhandler within another eventhandler (there are also other places where this is useful). Here's
an example. We want to create an event handler for the button `primary` which, as part of
it's action, creates a new event handler on another element `secondary`.  The job of this
new event handler is to change the color of both the primary and secondary elements.  Here's 
the example:

```javascript
function clickAction() {

  // here `this` refers to the element that was clicked
  // what ee do is add a new event handler onto another
  // element
  this.css('color', 'green');

  let sec = document.getElementById("secondary");
  sec.css('color', 'green');

  sec.addEventListener("click", function() {
    sec.css('color', 'red')
    this.css('color', 'red');
  });
}

let prim = document.getElementById("primary");
prim.addEventListener("click", clickAction);
```

Inside
the main handler (`clickAction`) the value of `this` will be the primary element
that was clicked to trigger the action.  We change the color of the element, 
then find another element with id `secondary` and change it's color to green
too.  We then add a new event listener to the secondary element so that when 
it is clicked, the color of both elements are changed to red.  However, the
value of `this` inside the new event handler will refer to the secondary element, 
not the primary one. Remember, this function won't be run until later when 
the secondary button is clicked.  So at that point, there's no way to find
the primary element - the event handler won't work. 

Instead, we use an arrow function for the second event handler:

```javascript
function clickAction() {

  // here `this` refers to the element that was clicked
  // what ee do is add a new event handler onto another
  // element
  this.css('color', 'green');

  let sec = document.getElementById("secondary");
  sec.css('color', 'green');

  sec.addEventListener("click", () => {
    sec.css('color', 'red')
    this.css('color', 'red');
  });
}
```

Since we've used an arrow function there is no new `this` created when it runs. This
means that Javascript needs to find a value for `this` by looking outside the function. 
Here we're creating what is called a [_closure_](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures)
 - the function we create here is closed
over the values of the variables that exist at the time it was created.  So, the value 
of `this` is the value it had inside `clickAction` when the arrow function was defined. 

Closures are a useful tool in building event handlers in Javascript. They can be confusing
if you are new to this idea. Understanding it involves thinking about the time that
the function is created and the time it is executed.  