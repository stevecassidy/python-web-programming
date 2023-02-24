# Javascript Objects and Classes

## Javascript Objects

Like Python, Java and C++, Javascript is an object oriented language but
the way that objects work in Javascript is very different from any
of those languages.  

Javascript objects are *prototype based*, meaning that every object
has another object as its *prototype* (except for the base object
called `Object` which has a prototype of `null`).  Classes in Java
would just be objects in Javascript - there is no difference between
a class and an instance.

The other distinct feature of Javascript objects is that they can
be modified dynamically - new members and methods can be added
after the object has been created.

There is a class system overlaid on these objects but it's use is optional.
We can just create an object and then add data and methods to it. Here's an example:

```javascript
const myCar = new Object()
myCar.make = 'Holden'
myCar.model = 'Astra'
myCar.year = 2009
myCar.describe = function() {
    return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year
}
```

The first line creates a new instance of `Object` which is the top
of the class hierarchy in Javascript.  The
remaining lines add three properties and a method `describe` that
returns a description of the car.  

Note that the method uses the variable name `this` to refer to
the instance (similar to Java and like `self` in Python).   Properties 
can be accessed
using the dot notation `myCar.year`, or alternately using
square brackets `myCar['year']`.   

Note that this is then quite similar to a dictionary in Python or
a HasMap in Java - a collection of properties and
values - and in fact objects in Javascript can be thought of as
a kind of associative array of keys and values, some of which can
be functions.  This is more obvious if we use an alternate syntax for
making the object:

```javascript
const myCar = {
    make: 'Holden',
    model: 'Astra',
    year: 2009,
    describe: function() {
            return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year;
    } 
}
```

Objects are often used as pure *data structures* in Javascript code without
adding additional methods.  This is very apparent in the rise in popularity
of the JSON format (Javascript Object Notation) for exchange of data over 
the internet.   JSON documents hold data rather than code and translate
directly to Javascript objects once parsed.

If we are using objects as associative arrays it is useful to be able to
get the property names of an object at run-time.  We can do this using the
static method `Object.keys()` which takes an object and returns an array
of the property names.  So, `Object.keys(myCar)` would return the array 
`[ 'make', 'model', 'year', 'describe' ]`.  Note that the `describe` method
is just another property name that happens to have a function as its value. 

Another useful thing to do to an associative array is to iterate over
the properties and values, we can do this in Javscript with the `for...in` 
loop:

```Javascript
for(const key in myCar) {
    console.log(key, myCar[key])
}
```

Inside the loop we use the square bracket notation to access the object
property using the key loop variable.  

You can also use the `in` keyword to check whether a given property is
present in an object. The following code will insert a new key-value
pair into an object if it isn't already present and throws an error otherwise:

```Javascript
const insertIfNotPresent = (object, key, value) => {
    if (!(key in object)) {
        object[key] = value;
    } else {
        throw(new Error(`${key} is already present in object`));
    }
}
```

If you want to remove a property from an object you can use the `delete` operator
as in this example:

```Javascript
delete myCar.year
```

## Classes

There are a number of ways of making objects in Javascript but the Class system
is the easiest to understand coming from other languages.   A class in
Javascript is way of defining a template for an object prototype.  We can
then use the `new` operator to create an object instance from a class
definition.  Here's our car example as a class definition:

```Javascript
class Car {

    constructor(make, model, year) {
        this.make = make;
        this.model = model;
        this.year = year;
    }

    describe() {
        return 'Car: ' + this.make + ', ' + this.model + ', ' + this.year
    }
}

const myCar = new Car('Holden', 'Astra', 2009);
```

The class definition is a way of defining how to make a new object and
the methods that go along with it.  Making an object like this is essentially
the same as the previous examples. This style makes sense if the reason for
having an object in your code is to represent some abstraction in your
application. If it's just for creating new data structures, you probably
would use the other methods.

Classes can inherit from each other, so we can do the usual object-oriented
example of a class hierarchy.

```Javascript
class MotorVehicle {
    constructor(year, wheels) {
        this.year = year;
        this.wheels = wheels;
    }
    getWheels() {
        return this.wheels;
    }
}

class Car extends MotorVehicle {
    constructor(year, colour) {
        super(year, 4);  // all cars have four wheels
        this.colour = colour;
    }
    describe() {
        return 'Car: ' + this.year + ', ' + this.wheels + ', ' + this.colour;
    }
}

const newCar = new Car(2009, 'white');
newCar.describe()
wheels = newCar.getWheels();
```

Here the two classes define their own constructor.  The `Car` class constructor
first calls the function `super` which invokes the constructor of its parent
class `MotorVehicle` with the given arguments.  Since cars always have four
wheels, we hard-code this value into the call to super.  The car class 
defines its own property `colour`.   When we create an instance of the `Car`
class we can call methods defined on `Car` or on `MotorVehicle` which will be
inherited.

Inheritance like this can happen with objects created in other ways, it's just
harder to establish the chain of inheritance than it is with class definitions.

## Built In Objects

Javascript comes with a large collection of built in object prototypes that
you can make use of in your code.   Consult
 [a good reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects)
to get a
list of all of them.  You'll see many of these in examples in later parts
of this text.   One useful example is the `Date` prototype:

```javascript
const today = new Date();
const birthday = new Date("Dec 25, 1993");
//show the date
console.log(today.toString());
// show the date in GMT timezone
console.log(today.toGMTString());
```
