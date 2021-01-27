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
linked to with `<script></script>` tags. 

We can embed the script directly:

```html
<script>
    // your script goes here
        alert('Hello World')
</script>
```
This tag can go anywhere in the HTML page and there can be many script tags in one
page.  The code is written directly inside the tag so this is only really suitable for
short fragments of code.  **In practice, you would almost never use this way of embedding
Javascript in a real application.**  Instead you would refer to an external script:

```html
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
downloaded and executed.  

In modern browsers there is a solution to this problem in the `defer` attribute
on the `script` tag.  For example:

```html
    <script src="/static/sample.js" defer>
```

In every modern browser, this will defer the execution of the Javascript code until
the page has completely loaded. This means that we can add the `script` tags to load
Javascript to the page `head` just as we do with CSS assets. 

[This page on HTML5Rocks](https://www.html5rocks.com/en/tutorials/speed/script-loading/)
discusses the range of issues around loading Javascript into the browser for 
those who want a deeper view.

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
  for (let j=0; j<count; j++) {
    document.write(message)
  }
}

write_times('hello', 10)
```

Note that the input arguments are not typed as they would be in Java or
C. The final line shows the newly defined function
in use.

This function also illustrates the use of the `for` loop which has the same syntax
as in C++ or Java with the exception of the variable declaration using let instead
of a type specifier.  

Functions in Javascript can also be anonymous - defined without a name. Also, since
functions are just values in the program (in the same way as in Python) they can be
assigned to variables. So we can achieve the same as the above with the following code:

```javascript
let write_times = function (message, count) {
    for (let j=0; j<count; j++) {
      document.write(message);
    }
}
```

This might seem a little odd but there are some common uses of this 
idiom in Javascript so it is important to understand it. 

A very common example is to create an [event handler](events.md). This is a function that will be
called when some event happens.  To do this we set a variable within the Document Object Model
(representing the current page in the browser) to a function. For example, this function
will be called when the page has finished loading:

```javascript

window.onload = function() {
    console.log("Page Has Loaded");
}
```

We also often pass functions as values to other functions. Here's an example from the 
[events chapter](events.md) that adds a handler for the click event on an element. Notice
that the anonymous function is the second argument to the `addEventListener` function:

```javascript
let el = document.getElementById("outside")
el.addEventListener("click", function(event) {
    alert("Event type: " + event.type );
})
```

Since this is such a common thing to do in Javascript, there is a new more compact syntax
for functions called __arrow functions__.   There are some subtle differences between 
these and regular functions which we'll point out later but the two examples above
could be re-written more compactly as:

```javascript

window.onload = () => { console.log("Page Has Loaded"); }
```

```javascript
let el = document.getElementById("outside")
el.addEventListener("click", (event) => { alert("Event type: " + event.type ); })
```

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

Variables in Javascript should be introduced with one of the keywords `var`, `let` or `const`.  
This is optional when creating a variable - if it isn't present, Javascript will
look for an existing variable in the current scope (eg. within a
function) and if it does not find it, look in the next level until it
gets to global scope - if it never finds a variable of that name it will
be created in global scope. So, without one of these keywords you are
effectively using global variables inside your functions. 

The difference between these keywords is subtle.  Firstly `const` is the simplest,
this defines a constant value - one that won't change. It can be global or local to
a block of code (curly braces).   On the other hand `var` and `let` seem quite similar; 
both introduce a variable that can be changed and can be used in global or local scope. 
The difference is that inside a function, `var` declares a variable that will exist
everywhere in the function while `let` declares a variable that will only exist within
a particular block.   Some examples will help to illustrate this.

```javascript
var gg = 12;   

function simple() {
    var hh = gg;
    gg = hh + 1;
    return hh;
}
simple();
```
in this exmaple, the variable `gg` is a global variable, the reference to it inside the function
will modify the global value.  The variable `hh` only exists within the function, so `hh` will be
undefined after the function call.

```javascript
var gg = 12;   

function simple() {
    var gg = 99;
    return gg;
}
simple();
```
Here, since we've used `var` to declare the variable in both places, the declaration inside 
the function replaces the initial one - so after the function call `gg` will have the value 99.
If the intention is to declare a local variable in the function, that can be done with `let`:

```javascript
var gg = 12;   

function simple() {
    let gg = 99;
    return gg;
}
simple();
```

So, one rule would be to always use `let` within functions, but in fact you can really just use
`let` all the itme. There aren't many situations when `var` is a better choice.  

One place you might forget to declare a variable is in a for loop:

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
    for(let i = 0; i<10; i++) {
        console.log(i);
    }
}
```
Since `let` declares a block-scoped variable, the value of `i` will be undefined outside
of the loop. This is what you would expect coming from another language like Java. 

So, the general rule is to always declare variables before they are used. Use
`const` for variables that won't change.  Use `let` for variables that will
change. 


### Arrays and Strings

Strings in Javascript are similar to those in Python. Both single and 
double quotes can be used (but Python's triple quote notation is not
supported).  They can contain unicode characters with special symbols if
you wish.

```javascript
let s1 = "Hello World!"
let s2 = 'Hello World!'
let s3 = 'Hola món!'
let s4 = 'မင်္ဂလာပါကမ္ဘာလောက'
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
let months = ['January','February',
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
let last = months.pop()
// and the first
let first = months.shift()
// get the first three remaining months
let three = months.slice(0, 3)
```

Strings can be concatenated using the `+` operator:

```javascript
let newstring = s1 + 'How are you today!'
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
let myCar = new Object()
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
let myCar = {
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
let today = new Date();
let birthday = new Date("Dec 25, 1993")
//show the date
console.log(today.toString())
// show the date in GMT timezone
console.log(today.toGMTString())
```


### Javascript Gotchas

Javascript is an odd language, there are many things about it that don't seem
to make sense if you are used to other languages and can be the source of
bugs.  There are some useful guides to a number of non-obvious features:
* [Seven Javascript Quirks](https://developer.telerik.com/featured/seven-javascript-quirks-i-wish-id-known-about/)
* [12 Javascript Quirks](http://2ality.com/2013/04/12quirks.html)

I'll go over a few of these here.  

#### Equality Testing

The first issue relates to comparison operators.  Javascript has both double and triple
equals operators to compare whether two values are the same but these behave quite
differently.  The double equals operator `==` will try as hard as it can to make
the values be equal by converting the type of a value if necessary.  So comparing
the string `"1"` to the integer `1` will succeed:

```javascript
let x = 1
if (x == "1") {
    console.log("They are the same!")
}
```

This can be exactly what you want but it can also be a source of bugs when two things
you thought would be different end up being the same.  If you use the triple equal 
operator `===` the type coercion will not happen and the comparison will succeed only
if the values really are the same.  So this code will print the message in the else clause:

```javascript
let x = 1
if (x === "1") {
    console.log("The are the same")
} else {
    console.log("Not the same because of triple equals!")
}
```

Since the odd behaviour of double equals can be a source of bugs, best practice in Javascript is
to always use triple equals when comparing values. 

#### Two kinds of nothing

Javascript has two special values that sort of mean nothing.   Python for example has
the special value `None` and Java has `null`, these are used to indicate when a
variable holds nothing or a function returns no value.   Javascript has the special 
value `null` for this purpose and it has more or less the same meaning.  However, 
Javascript also has the special value `undefined` which is the result of evaluating
a variable that is undefined.  In other languages this would throw an error, but Javascript
just returns this special value.  

#### Implicit conversion

Similar to the double equals comparison, there are other times when Javascript converts
the type of values without being asked.  One of these is with boolean tests. The following
values will convert implicitly to `false`:

* `undefined` or `null`
* `false`
* Numbers `+0`, `-0` and `NaN` (Not a Number - eg. Math.sqrt(-1))
* the empty string `''`

everything else is considered to be `true`.  So I can use these values directly in an if
statement:

```javascript
let x = ''
if (x) {
    /* this will not run because '' is false */
}
```

Another case that can trip you up is the implicit conversion of types to strings.  If I write
the following:

```javascript
x = '5'  /* a string */
console.log( x + 1 )
```
the output will be `51` rather than `6` because the number `1` was converted to a string and
we then get a string concatenation operation `'5' + '1'` rather than an addition.

### Semicolons

Javascript code can include semi-colons at the end of statements:

```javascript
x = '5';
console.log( x + 1 );
```

however, the semi-colon is optional and can be left out in almost all cases.  One
place it is required is if you want to include two statements on one line:

```javascript
x = '5'; console.log( x + 1 );
```

For the most part then you can write Javscript with no semi-colons and all will be well.
There are though some obscure cases when a missing semi-colon might get you 
in trouble.  

## Modules

In most programming languages, we break up an application into more than one file. This 
helps with code management and also allows us to structure an application to put
certain things into one module to make it self contained.  In Javascript it has 
always been difficult to do this as it lacked a formal module mechanism.  People reverted
to weird tricks to write code that could be used in a modular fashion.  Fortunately,
the ES6 standard introduced module import/export and nearly all browsers now implement
this feature (the main exception is the old Internet Explorer). 

To write a Javascript module we make use of the [`export`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export) keyword somewhere in the file. There are many options here
but I'll just cover the simplest case which is to list the symbols to be exported
at the top of the file.  Here's an example, assume it is stored in the file `namegen.js`:

```javascript
export {maxNameLength, generateName};

const maxNameLength = 1024;
const unexportedVariable = "useless";

function generateName(length) {

    if (length <= maxNameLength) {
         length = maxNameLength;
    } 
    return 'a'.repeat(length);
}
```
In this example, we define a variable and a function that are exported and a second variable that 
is not.  Another module that imports this module can get access to `maxNameLength` and `generateName` 
but not to `unexportedVariable` which is only usable inside this module.

Importing is similarly simple, making use of the `import` keyword as you might expect. The simplest
case is where we just name the symbols we want to import from another module. Here is an example:

```javascript
import {generateName} from './namegen.js'

console.log(generateName(10));
console.log(maxNameLength);   // will be undefined
```

Here we import only the `generateName` function and we can make use of it as if it was defined in 
this file.  The variable `maxNameLength` will not be imported and so trying to use it will give a 
result of `undefined` (that special Javascript value that means the variable doesn't exist).  

In some cases you want to import everything from a module. In this case we need to give a
prefix for the imports to prevent a symbol from the imported module clashing with one defined
locally - this is more likely if you just say import everything since the list of exports might
change at some point in the future.  So we would write:

```javascript
import * as namegen from './namegen.js'

console.log(namegen.generateName(10));
console.log(namegen.maxNameLength);   
```

Note that we need to refer to the function and variables with the defined prefix.  Trying to use
them without the prefix won't work.

One thing to understand is what is the path name we should use after the `from` keyword. This
is either a relative or absolute path to the file that we want to import. This is a URL, it
could begin with http and reference a file on another server (but see below for some caveats). 
Most often though you will be referencing a module on the same server and will use either a
relative or absolute path.  
My example above is a relative path, it starts with `./` because a single period is an alias
for the current directory (in Unix based systems, and this carries over to URL paths). A
relative path can't be just the file name. So `'./namegen.js'`
says look in the current directory for the file `namegen.js`.  You could also refer to a subdirectory
like `'./modules/namegen.js'` if you want to keep all of your modules in a subdirectory - but note the
relative path still begins with a period.  

The second alternative is an absolute path. For example, `'/modules/namegen.js'` - the path begins
with a forward slash and the browser will resolve it as it would if it saw this in the 
`href` attribute of a link. It will make a request to the same server for this URL path. 

It is possible to import a module from another server, something like:

```javascript
import {example} from 'http://example.org/some/module.js'
```
The browser will try to load this URL to get the module contents. However, there are rules as 
to where you can load code from. By default, this will be blocked by a policy which says that
a Javascript module can only load code from the same server: CORS or Cross Origin Resource Sharing policy.
It is possible to configure your server to return HTTP headers that permit your Javascript
to load modules from another site.  This prevents malicious code infecting your Javascript
and loading bad code from some random evil hacker server.   So, in general you won't 
use a full URL to import a module. 

### Loading Modules into the Browser

Once you have converted your code to use `import` statements your Javascript files become
Javascript modules.  We are used to loading Javascript into the page with a `<script>` 
tag:

```html
<script src="script.js" defer>
```

(where `defer` means we defer loading until the page has finished loading).   If you use `import` in
`script.js` and try to do this you will get an error message in your console. Something like
`"SyntaxError: import declarations may only appear at top level of a module"`.  To fix this
we need to tell the browser that what we're importing is a module, which we do with the 
`type` attribute:

```html
<script src="script.js" type=module defer>
```
This primes the browser to expect a module and it will then be happy with import statements. The big 
difference is that when a module is loaded, the code is executed as normal but all of the 
symbols defined in the module are not available in global scope in the browser.  Using modules
also enforces the CORS policy for more secure coding. 

We've been discussing the browser loading these modules since that is where we are running
our Javascript most of the time. However, there might be other systems loading these modules, 
in particular it might be running under the Node.js system which runs Javascript outside of
the browser.  Import/export statements can also be used by so-called _bundlers_ which read
your Javascript code and bundle it up into a compact form suitable for delivery to 
the browser - eg. it might combine all of your modules into a single file to avoid the
browser having to make many HTTP requests.  

## Summary

There is a lot more to Javascript than this chapter has covered. You should refer to other
sources to learn the details of the language.  What I've tried to do here is
to point out some highlights and points of difference with other languages
that you might be familiar with.  The goal of this text is to give one view of how
Javascript is used in developing modern web applications.  Most of the important 
detail is in _how_ it is used and how the application works in the browser.  

