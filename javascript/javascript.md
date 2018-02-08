

Javascript
==========



The Language
------------

Javascript is an object oriented language which is primarily used as an
embedded scripting langauge within a web browser. It was developed first
by Netscape (and called LiveScript) for use in the Navigator browser,
had it's name changed when Sun Microsystems became involved and was soon
copied by Microsoft (as JScript). The langauge was later standardised by
ECMA as ECMAScript which is perhaps the 'proper' name of the langauge
but everyone calls it Javascript.

The name Javascript is confusing (perhaps by design) because the
language is not related to Java and is in fact quite a different kind of
language. The syntax is somewhat similar in that they both share the
core syntax of C-like languages, but the design philosophy behind them
is very different and they are useful for different tasks.

Javascript is a loosly typed language, meaning that you don't need to
declare the types of variables (just like Python). A variable can hold
any type of data and it's up to the programmer to ensure that they know
what the type of a variable is to avoid errors. Errors such as trying to
add a string to a number will be discovered only at run-time; whereas in
a strongly typed language like Java they would be found at compile time.

Javascript is an object oriented language, but unlike Python or Java,
objects in Javascript aren't based on predefined class definitions.
Instead they are built around the idea of *prototypes* (objects inherit
from other prototype objects) and new fields and methods can be added at
run-time as needed. Objects can be thought of as general purpose
containers with 'slots' which can hold either data of any type or
functions which act like methods. This is a bit different to the way of
thinking in Java and Python but has some interesting consequences that
are exploited in the way that Javascript programs are written.

The main execution environment for Javascript is the web browser. It is
possible to run a standalone Javascript run-time environment and there
are a number of projects building server-side infrastructure with
Javascript (for example [node.js]()). For present purposes we will limit
the discussion to client-side Javascript in the web browser. In this
context, the main resource that a Javascript program has access to is
the data structure corresponding to the HTML page currently being
viewed. Javascript programs are able to interact with this data
structure, querying it and updating it and so affect the content that is
being viewed by the user. Javascript can also respond to events that
occur in the browser, such as a user moving the mouse over a particular
element, clicking on a link or entering text into a form. In this way,
Javascript is used to enhance the user experience and build interactive
applications within the web browser.

This chapter might one day expand to be a proper Javascript tutorial but
at the moment the goal is just to give a flavour of the language. There
are lots of resources on the net for learning about Javascript but if
you are already a programmer, the best way is to try to write some code
and use reference materials and code examples to work things out.





Running Javascript
------------------

JavaScript code is embedded in web page headers within
`<script></script>` tags. Either embed the script directly (note the use
of HTML and Javascript comments):

```javascript
<head>
  <title> ...</title>
  <script language="Javascript">
<!--
// your script goes here

//-->
  </script>
</head>
    
```

Or refer to an external script file:

```
  <script language="Javascript" src="sample.js">
    
```

Either of these methods of including Javascript has the same effect, the
code is loaded and executed directly. A script tag can be placed at any
point in the page, either in the head or body. If there is output from
the script (via a call to `document.write`) then it is inserted at the
same point in the document.

Since Javascript code is executed as soon as it appears in the page, it
is common to place script tags that load large libraries right at the
end of the file, just before the end body tag. This means that most of
the page can be rendered before the Javascript is loaded, thus speeding
up the page load as far as the user is concerned.





Elements of Javascript
----------------------

Here's a sample of code to illustrate a few langauge features:

```javascript
var months = new Array('January','February',
            'March','April','May','June','July','August',
            'September','October','November','December');

var theDate= new Date();
var day = theDate.getDate();

var textdate = 0;

if (theDate.getYear() < 2000)
  textdate = 1900;

textdate = months[theDate.getMonth()] + ' ' + day + ', '
                    + (theDate.getYear() + textdate);

document.write(textdate);
```

The first line shows the declaration of a variable with `var`, this is
optional when creating a variable - if it isn't present, Javascript will
look for an existing variable in the current scope (eg. within a
funciton) and if it doesn't find it, look in the next level until it
gets to global scope - if it never finds a variable of that name it will
be created in global scope. So, without the `var` keyword you are
effectively using global variables inside your functions. Best practice
is to always use `var` to make a new variable.

The variable declared in the second line is given the value of an array
of strings created as an object of type `Array`. This is an example of
objects as containers in Javascript. The same code could have been
written as:

```javascript
var months = ['January','February',
              'March','April','May','June','July','August',
              'September','October','November','December'];
        
```

This is just a different syntax for the same thing. Arrays in Javascript
are just the same as those in most other languages (they're called lists
in Python); they can be indexed with a number starting from zero and
they have various methods to manipulate the contents.

The second line creates an instance of a Date object using the `new`
operator - this is similar to Java's object creation except that Date is
an object rather than a class name (a minor detail unless you're going
to go deeper into Javascript). The Date object can be used as an
interface to the system date as can be seen in the next line when we
retrieve the current date with `date.getDate()`.

The next statment makes another variable called `textdate` and
initialises it to zero, an if statment then checks to see whether the
current year as returned by the `getYear` method on the date object is
less than 2000 and if so sets the textdate to 1900. Note that this
variable is holding an integer value at this point. The next line
performs a string concatenation operation to make up a string
representation of the current date. The `+` operator applied to strings
does concatenation but note that here one of the values `textdate` is an
integer. Javascript automatically converts the integer to a string in
this context so that the concatenation operation makes sense. The first
part of the resulting string is made from an entry in the `months` array
we made earlier; the index is the number of the current month as
returned from `getMonth` method on the date object.

The final line in the example calls `document.write` which is a method
of adding content to the current HTML page at the point where the
`script` tag occurs. This is the simplest method for modifying the page.

Functions can be defined in Javascript much like any other procedural
langauge:

```
function raiseP(x,y) {
  var total = 1;
  for (var j=0; j<y; j++) {
    total*=x;
  }
  return total; //result of x raised to y power
}

z = 10 + raiseP(10,20);
```

Note that the input arguments aren't typed as they would be in Java or
C. The function makes use of a local variable `total` which is declared
using the `var` keyword. The final line shows the newly defined function
in use.





The Document Object Model
-------------------------

Javascript running in the web browser has access to the currently
displayed web page via an interface called the Document Object Model or
DOM. The DOM interface is object based as it's name suggests and allows
a script to locate any part of the page, read the contents and update it
either by changing text or adding new elements to the page. There are
various ways to traverse the data structure that makes up the DOM and I
refer you to other resources for the details (eg. [W3Schools HTML DOM
tutorial](http://www.w3schools.com/htmldom/)). I'll give one basic
example here.

    // get the first h1 in the document
    header = document.getElementsByTagName("h1").item(0)

    // modify the contents
    header.innerHTML = "New Heading"

    // get the element with the id "info"
    info = document.getElementById("info")
    // get the text value of the first child element of this node
    text = info.firstChild.nodeValue

           

This example illustrates the use of the pre-defined `document` object
which is the representation of the current web page being displayed by
the browser. The first example uses `getElementByTagName` to find all of
the `h1` elements in the page and then selects the first of these using
the `item` method. The second line shows the modification of the content
of this element using the `innerHTML` property; setting this to a new
value directly affects the page being displayed. In the second example
we use a different method to find an element with a given id attribute.
We then use the `firstChild` property to find the first child node (the
first element enclosed in this element) and the `nodeValue` property to
get the text value of that node.

This is just a brief example of what can be done with the DOM. It
provides a complete interface to querying and updating the displayed
HTML page and is the key to Javascript's ability to build fully
interactive applications in the browser.





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
[Mozilla Developer Network]() on using this method:

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
support them on [this quirksmode
page](http://www.quirksmode.org/dom/events/index.html).





[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
