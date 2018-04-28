Javascript
==========

The Language
------------

Javascript is an object oriented language which started life as an
embedded scripting language within a web browser. It was developed first
by Netscape (and called LiveScript) for use in the Navigator browser,
had it's name changed when Sun Microsystems became involved and was soon
copied by Microsoft (as JScript). The language was later standardised by
ECMA as ECMAScript which is perhaps the 'proper' name of the language
but everyone calls it Javascript.

The name Javascript is confusing (perhaps by design) because the
language is not related to Java and is in fact quite a different kind of
language. The syntax is somewhat similar in that they both share the
core syntax of C-like languages, but the design philosophy behind them
is very different and they are useful for different tasks.

Javascript is a *dynamically typed* language, meaning that you don't
declare the types of variables (just like Python). A variable can hold
any type of data and it's up to the programmer to ensure that they know
what the type of a variable is to avoid errors. Errors such as trying to
add an array to an integer will be discovered only at run-time; whereas in
a statically typed language like Java they would be found at compile time.
Dynamically typed languages are generally thought to be easier for non-expert
programmers to learn and lend themselves to quick scripts to solve specific
problems.  Writing larger applications and ensuring code is bug-free can
be more difficult unless programmers are very careful. 

Javascript is an *object oriented* language, but unlike Python or Java,
objects in Javascript are not based on predefined class definitions.
Instead they are built around the idea of *prototypes* (objects inherit
from other prototype objects) and new fields and methods can be added at
run-time as needed. Objects can be thought of as general purpose
containers with _slots_ which can hold either data of any type or
functions which act like methods. This is a bit different to the way of
thinking in Java and Python but has some interesting consequences that
are exploited in the way that Javascript programs are written.

The most common environment to run Javascript code is the web browser. All modern
web browsers come with a Javascript execution component that will run code
embedded in web pages that are being viewed.  However, in recent years, the
use of Javascript as a _server side_ language is becoming more common.  The
[node.js](https://nodejs.org/en/) project provides a runtime environment for 
Javascript that does not rely on a browser and can be used to write general
purpose scripts including server-side web applications.  The popularity of
Javascript outside the browser can perhaps be attributed to the rise of
the front-end developer who knows Javascript and therefore wants to use it
to perform scripting and write server-side code.   The node.js eco-system is
now very well established and any practicing web developer needs to have 
some familiarity with Node and the NPM package manager that is used to
distribute Javascript software. 

When Javascript is running in the web browser, 
the main resource that a Javascript program has access to is
the data structure corresponding to the HTML page currently being
viewed. Javascript programs are able to interact with this data
structure, querying it and updating it and so affect the content that is
being viewed by the user. Javascript can also respond to events that
occur in the browser, such as a user moving the mouse over a particular
element, clicking on a link or entering text into a form. In this way,
Javascript is used to enhance the user experience and build interactive
applications within the web browser.

These chapter might one day expand to be a proper Javascript tutorial but
at the moment the goal is just to give a flavour of the language. There
are lots of resources on the net for learning about Javascript but if
you are already a programmer, the best way is to try to write some code
and use reference materials and code examples to work things out.


Running Javascript in the Browser
------------------

To associate JavaScript code with a web page, the code is embedded in the page or
linked to with
`<script></script>` tags. 

We can embed the script directly:

```javascript
  <script language="Javascript">
    // your script goes here
    alert('Hello World')
  </script>
    
```
This tag can go anywhere in the HTML page and there can be many script tags in one
page.  The code is written directly inside the tag so this is only really suitable for
short fragments of code.  **In practice, you would almost never use this way of embedding
Javascript in a real application.**  Instead you would refer to an external script:

```
  <script src="/static/sample.js">
```
Either of these methods of including Javascript has the same effect, the
code is loaded and executed directly. A script tag can be placed at any
point in the page, either in the head or body. The code is able to modify
the current page *up to that point* via the DOM (see below) and it can 
insert content into the current page with `document.write`.   

For this reason,
whenever a `<script>` tag is seen, the rendering of the HTML page is halted
while the script is executed and then resumed when it is done.    This can 
slow down the loading of a page if there are many scripts or if running some 
scripts takes a long time.   For this reason it is common to put all
script tags that load external Javascript at the *end of the body section* of
the HTML page.  In this way, the page is fully loaded before the Javascript is
downloaded and executed.  (Note that there are 
[alternatives to this](https://www.html5rocks.com/en/tutorials/speed/script-loading/)
but that browser support is still not 100% and so they can't be relied on).



Elements of Javascript
----------------------

This text does not attempt to teach you everything about the Javascript language.
The goal is to point out some important features and show you how to 
achieve some common tasks with Javascript.  You should refer to 
other sources to learn the language itself. 
E.g. [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript).


### Functions

Functions can be defined in Javascript much like any other procedural
language:

```javascript
function write_times(message, count) {
  for (var j=0; j<count; j++) {
    document.write(message)
  }
}

write_times('hello', 10)
```

Note that the input arguments are not typed as they would be in Java or
C. The final line shows the newly defined function
in use.

This function also illustrates the use of the `for` loop which has the same syntax
as in C++ or Java with the exception of the variable declaration using var instead
of a type specifier.  

Functions in Javascript can also be anonymous - defined without a name. Also, since
functions are just values in the program (in the same way as in Python) they can be
assigned to variables. So we can achieve the same as the above with the following code:

```javascript
var write_times = function (message, count) {
    for (var j=0; j<count; j++) {
      document.write(message)
    }
}
```

This might seem a little odd but there are some common uses of this 
idiom in Javascript so it is important to understand it.

### Debugging Output

Since your Javascript program is running in the web browser, we need a way to 
log messages so that we can see them for debugging or other purposes.  In Python
we would insert a `print` statement in code. In Javascript we use `console.log` 
and the output appears in the browser Javascript console which can be 
found via the browser developer tools.

All modern browsers also have a very good interactive debugger that can be 
used to step through your code and place breakpoints.  Get to know your 
developer tools!

### Variables and Scope

Variables in Javascript should be introduced with the `var` keyword.  
This is optional when creating a variable - if it isn't present, Javascript will
look for an existing variable in the current scope (eg. within a
function) and if it does not find it, look in the next level until it
gets to global scope - if it never finds a variable of that name it will
be created in global scope. So, without the `var` keyword you are
effectively using global variables inside your functions. Best practice
is to always use `var` to make a new variable.

One place you might forget to use `var` is in a for loop:

```javascript
function counter() {
    for(i = 0; i<10; i++) {
        console.log(i);
    }
}
```

While this code will work ok, it is silently creating or referring to a global
variable `i` as the loop counter.  Since Javascript can run asynchronously (many
threads at once) it is possible that some other function will also be modifying
`i` at the same time, causing this loop to behave oddly.  So, always use `var` in
writing your for loop:

```javascript
function counter() {
    for(var i = 0; i<10; i++) {
        console.log(i);
    }
}
```

Scope can sometimes be confusing in Javascript and there is a real danger of 
bugs caused by conflicting global variable and function names if two 
Javascript files are loaded that both create names in global scope. 
If two files define a function called `render`, then the file that is 
loaded last will overwrite the first definition.  Even more problematic
can be code that creates global variables -- if two functions rely on the same
global variable that could result in very subtle bugs that are hard to track down.

To avoid this kind of problem, it is common to use one of a number of methods to
avoid using global scope.  These are all ways of working around the fact that 
Javascript does not provide an official way to define modules that do not 
clash with each other.  In Python for example we can define functions inside
one file (module) and we need to import these into another module to use them. 
In Javascript, every file that is loaded comes into the global namespace. 

One method, which we will use in this text, is to enclose code in an anonymous function
that is immediately called.  Here's an example:

```javascript
(function() {
    var name = 'Steve';
    
    function sayhello(who) {
        console.log("Hello" + who);
    }
    sayhello(name);
})()
```
This code defines an anonymous function with no arguments `(function() {...})`.
The body of the function
is the code we want to run, it defines a variable and a function and then calls the 
function which will output 'Hello Steve' on the browser console.  Immediately after
defining the function we call it - notice the parentheses right after the code block
`(function() {...})()`.  Since we call the function, the body of code inside
will be executed but the variable and function we defined will only exist within
the function, not in the global scope.  So, the overall effect of this is to
allow us to define and use some variables and functions without polluting the global
scope and causing possible name collisions. 

So once again the pattern is:

```javascript
(funciton() {
    // your code here
})()
```
Note that we can't use this if we want to define functions that are to be used
by other code blocks.  In that case we sometimes do want to have functions defined in global
scope. However, there are alternatives which we will see later in some examples.


### Arrays and Strings

Strings in Javascript are similar to those in Python. Both single and 
double quotes can be used (but Python's triple quote notation is not
supported).  They can contain unicode characters with special symbols if
you wish.

```javascript
var s1 = "Hello World!"
var s2 = 'Hello World!'
var s3 = 'Hola món!'
var s4 = 'မင်္ဂလာပါကမ္ဘာလောက'
```

Strings are objects and can be operated on with methods (just like Python) and 
then can be subscripted with the square bracket notation.

```javascript
console.log(s1[3])
// methods do not modify the string 
console.log(s1.toUpperCase())
console.log(s1)
// just say hello
console.log(s1.substr(0, 5))
// note that length is a property, not a function
console.log(s1.length)
```

Here is the definition of an array of strings in Javascript:

```javascript
var months = ['January','February',
              'March','April','May','June','July','August',
              'September','October','November','December'];
        
```

This is just a different syntax for the same thing. Arrays in Javascript
are just the same as those in most other languages (they're called lists
in Python); they can be indexed with a number starting from zero and
they have various methods to manipulate the contents.

Arrays in Javascript (just like Python but not like Java) can contain 
different _typed_ data. So I can have an array that contains both
numbers and strings.

Note that arrays in Javascript are objects that have methods, just like
in Python. So I can operate on an array using these methods:

```javascript
// get the name of the month from a month number
function getMonth(N) {
    return months[N+1]
}

// confuse things by reversing the array - note that this modifies it in place
months.reverse()
// and sort it in place too
months.sort()
// remove the last element
var last = months.pop()
// and the first
var first = months.shift()
// get the first three remaining months
var three = months.slice(0, 3)
```

Strings can be concatenated using the `+` operator:

```javascript
var newstring = s1 + 'How are you today!'
```


### Javascript Objects

Like Python, Java and C++, Javascript is an object oriented language but
the way that objects work in Javascript is very different from any
of those languages.  

Javascript objects are _prototype based_.  So, rather than defining
a class in source code and then creating instances of that class we
just create an object and then add data and methods to it. 
Javascript objects can change at run time, getting new properties
and new methods.  Here's an example:

```javascript
var myCar = new Object()
myCar.make = 'Holden'
myCar.model = 'Astra'
myCar.year = 2009
myCar.describe = function() {
    return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year
}
```

The first line creates a new instance of `Object` which is the top 
of the class hierarchy in Javascript (everything is an `Object`).  The
remaining lines add three properties and a method `describe` that 
returns a description of the car.  

Note that the method uses the variable name `this` to refer to 
the instance (like `self` in Python).   Properties can be accessed
using the dot notation `myCar.year`, or alternately using 
square brackets `myCar['year']`.   Note that this is then quite
similar to a Python dictionary - a collection of properties and 
values - and in fact objects in Javascript can be thought of as 
a kind of associative array of keys and values, some of which can
be functions.  This is more obvious if we use an alternate syntax for
making the object:

```javascript
var myCar = {
    make: 'Holden',
    model: 'Astra',
    year: 2009,
    describe: function() {
            return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year
    } 
}
```
This looks very similar to a Python dictionary with the exception that property
names (keys) don't need to be in quotes and you can't have a comma after the last
key-value pair.

This way of working with objects is not going to be the most useful -- there needs
to be a way to define methods for all cars, rather than doing it one car
at a time.  Javascript manages this via _prototypes_.  A prototype is an
object that is used as a kind of template for making new objects.  The way that 
a prototype is defined looks odd to anyone familiar with other object oriented
languages.  Here's an example:

```javascript
function Car(make, model, year) {
    this.make = make
    this.model = model
    this.year = year
}

Car.prototype.display = function() {
    return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year
}

// create a new car
myCar = new Car("Holden", "Astra", 2009)
// call the display method
console.log(myCar.display())
```

The first part of this definition is a function called `Car` that acts as
the constructor for the object.  This is just a regular function, the difference
is how it is used.  To create a new instance of this prototype we use the
`new` keyword and call the constructor function.  This has the effect of
creating the new object and making it available to the function via the
variable `this`.  The constructor in this case sets the object properties. 

The second part of the definition is to assign a function to the property
`Car.prototype.display`.   `Car.prototype` is an object itself that is the
prototype for all cars.  Any methods that are defined on this object will 
be available to all instances of `Car`.  

### Built In Objects

Javascript comes with a large collection of built in object prototypes that
you can make use of in your code.   Consult
 [a good reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript) 
to get a
list of all of them.  You'll see many of these in examples in later parts 
of this text.   One useful example is the `Date` prototype:

```javascript
var today = new Date();
var birthday = new Date("Dec 25, 1993")
//show the date
console.log(today.toString())
// show the date in GMT timezone
console.log(today.toGMTString())
```

## Summary

There is a lot more to Javascript than this chapter has covered. You should refer to other
sources to learn the details of the language.  What I've tried to do here is
to point out some highlights and points of difference with other languages
that you might be familiar with.  The goal of this text is to give one view of how
Javascript is used in developing modern web applications.  Most of the important 
detail is in _how_ it is used and how the application works in the browser.  