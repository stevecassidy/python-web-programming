

Object Oriented Python
======================

Python is an object oriented language. Objects go to the heart of the
language in the sense that all of the built in container types (list,
tuple, dict string) are objects and all of the modules in the standard
library use objects and present object based interfaces. If you write
any non-trivial Python program you will be using objects. Unlike Java
however, you can *write* Python programs without using an object
oriented style. Python programs can be purely procedural and just make
use of the built in objects. This flexibility supports different
programming styles with Python, from quick and dirty scripts to solve a
simple problem to fully engineered applications.

In this course, you won't *need* to write programs with objects except
in a few cases - notably when you are writing and using unit tests. This
chapter summarises the main features of objects in Python so that you
can understand programs if you see them and begin writing object based
code if you wish to do so. It isn't an introduction to object oriented
programming - but if you've already written in that style, then you
should be able to pick up enough information here to write this way in
Python.



Python Classes
--------------

The class definition in Python defines the content and behaviour of an
object in terms of member variables (to hold data) and methods (to
define behaviour). In an application program, we would make an
*instance* of a class which we could use to call the methods. An example
of creating and using an instance can be seen in this string example:

```
>>> l = list()
>>> l.append(3)
>>> l.append(4)
>>> print(l)
[3, 4]
>>> l.reverse()
>>> l
[4, 3]
    
```

Here I've created an instance of the built in `list` class, which gives
me an empty list, and then called the `append` method to add two
integers to the list. I print the list and finally call the `reverse`
method to reverse the elements of the list.

Most classes that we deal with will be like the list class in that they
will hold some data and present an interface to updating or accessing
the data.

Here is a simple class definition that might represent an on/off switch:

```
class Switch:
    
    # switch state, True == on, False == off
    state = False
    
    def on(self):
        """Turn the switch on"""
        self.state = True     
        
    def off(self):
        """Turn the switch off"""
        self.state = False
        
    def toggle(self):
        """Turn on if we're off, off if we're on"""
        
        if self.state:
            self.off()
        else:
            self.on()
    
```

In the example, the class definition is introduced with the keyword
`class` and the name of the class. By convention, class names are
capitalised but this is not a requirement of the language. The class
definition is a code block and so is introduced by a colon at the end of
the class statement and indented by four spaces. In the body of the
class definition we have two kinds of things: *data attributes* (`state`
in the example) define variables to hold the data belonging to the class
instances and *methods* (`on`, `off` and `status`) define the operations
that are supported on instances of the class.

The method definitions in the example are really just the same as the
procedure definitions that we've already seen, except that they have a
special argument called `self`. This argument is required for any method
and its value is the instance of the class on which the method is being
called. It is equivalent to the `this` variable in C++ and Java, except
that it must be explicitly included as a parameter where those languages
define it automatically for any method. Inside the body of the methods
we refer to the data attribute via the `self` variable using the dot
notation, as in `self.state`. Similarly, we call methods on the instance
in the same way, as in the definition of the `toggle` method which calls
`self.on()` or `self.off()`.

To create an instance of this new class we use the name of the class
like a procedure, in this case with no arguments. We can then call the
methods of the class. Here's an example:

```
>>> sw = Switch()
>>> print(sw.state)
False
>>> sw.on()
>>> print(sw.state)
True
>>> sw.toggle()
>>> print(sw.state)
False
    
```

In this example we create a new `Switch` instance and assign it to the
variable `sw`. We then print the value of the state attribute for this
instance and call the `on` and `toggle` methods. The output will show
that the state of the switch is changed by the methods (try it for
yourself to confirm this).

### The `__init__` Method

In the Switch example, there was no initial information needed to
initialise the instance. The starting state was just defined as False
for all new instances. It is possible to define an explicit constructor
for a class that may take additional arguments. The name of the
constructor in Python is `__init__` and it is defined like any other
method. To extend our example, here is a version with a constructor that
takes an initial state argument:

```
class Switch:
    
    def __init__(self, state=False):
        """Initialise the switch"""
        
        self.state = state
        
    def on(self):
        """Turn the switch on"""
        self.state = True     
        
    def off(self):
        """Turn the switch off"""
        self.state = False
        
    def toggle(self):
        """Turn on if we're off, off if we're on"""
        
        if self.state:
            self.off()
        else:
            self.on()
   
```

Note the differences here. The data attribute `state` is not explicitly
initialised in the class body, instead it is set in the constructor to
have the value of the state parameter (which defaults to False if not
provided). Any method can create new data instances like this but it is
most common to do so in the constructor. We can now create instances of
Switch in one of two ways:

```
sw1 = Switch()      # initial state will default to False
sw2 = Switch(True)  # initial state set explicitly to True  
  
```

This example also shows how additional parameters are declared for
methods, they are just added after the `self` parameter. Note that when
we call the method (or the constructor) we provide one less parameter
than in the method declaration - the initial `self` parameter is added
by the Python runtime.

`__init__` is one example of a special method that has a defined meaning
in Python. There are others, all beginning and ending with two
underscores, that define special behaviour. An example is the `__str__`
method which is called whenever Python wants a string representation of
the instance. We won't go into these here but you can follow this up in
the [Python
documentation](http://docs.python.org/3/reference/datamodel.html#basic-customization).





[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
