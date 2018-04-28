

A Little More Python
====================



Procedures
----------

A procedure is a named block of statements that performs an operation.
Instead of writing each time:

```
print('Python is not a snake!')
print('Python is a programming language!')
```

You can write a procedure using a `def` statement, followed by a name, a
parameter list (representing zero or more comma-separated parameters)
and a block of statements:

```
def explain_python():
    """Print a message explaining what Python is."""
    
    print('Python is not a snake!')
    print('Python is a programming language!')
```

Note that the first thing in the body of the procedure is a string that
explains what the procedure does. This is the *doc string* and is used
as part of the online help in the Python environment. It is a good idea
to get into the habit of always including a doc string in your procedure
definitions to document the parameters and return value of the procedure
and any side effects (like printing) it might have. We often use the
triple quoted string as above to allow newlines in the doc string.

To define this procedure you can just copy and paste the above code into
the Python command line (we'll look later at saving it in a file). The
procedure can then be called just like any built in procedure:

```
>>> explain_python()
Python is not a snake!
Python is a programming language!
```

Procedures are values that can be assigned to variables.

```
>>> perl = explain_python   # make a copy of the procedure and call it perl
>>> perl()
Python is not a snake!
Python is a programming language!
```

As with other programming languages, procedures are an important
abstraction when writing code. The above example is trivial but in
general a procedure will do an identifiable piece of work in your
program. Writing something as a procedure allows you to re-use the code
several times but it also allows you to break down your problem into
parts that can be solved separately. Deciding when to use a procedure
for a part of your problem is something you will learn as you become a
better programmer.

The following procedure checks whether a number is a prime number. It
uses one parameter (`n`) in the parameter list and a `return` statement:

```
def is_prime_number(n):
    """Return True if n is a prime number,
    False otherwise"""
    
    count = n / 2
    while count > 1:
        if n % count == 0:
            return False
        count -= 1
    return True
```

The return value is the result of the procedure that is sent back to the
caller of the procedure. In our case the value is a boolean value,
either `True` or `False`:

```
>>> is_prime_number(7)
True
>>> is_prime_number(4)
False
```

Note that unlike Java or C++, the parameters do not have associated type
declarations, again this is because Python is a dynamically typed
language and we don't need to specify the types of variables. This means
that I could call the above procedure with a string instead of an
integer, this would cause a run-time type error:

```
>>> is_prime_number("yes")
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "<console>", line 2, in is_prime_number
TypeError: unsupported operand type(s) for /: 'str' and 'int'
```

The error message says that you can't use the `/` operator on a string
and an integer. If this were Java or C++, this error would have been
caught at compile time, with Python we need to do the checks ourselves.





Python Program Structure
------------------------

Once you are writing procedures in Python you should move beyond just
typing commands at the command line and start storing your programs in
files. You can do this without learning anything new, just enter the
Python code you typed into the command line in a file and save it in a
file ending in `.py`. You can then run the code by passing the file name
to the Python interpreter. So, take the first example from the last
section, we define a procedure called `explain_python` and then call it;
let's store these commands in a file `explain.py`.

```
  
def explain_python():
    """Print a message explaining what Python is."""
    
    print('Python is not a snake!')
    print('Python is a programming language!')
    
    
explain_python()
```

Now at the system command line (eg. the Terminal if you're on OSX, the
Command Prompt if you're on Windows) you can pass the file name to the
python interpreter:

```
C:\Users\Steve> c:\Python33\python.exe explain.py
# or on OSX
steve> python3 explain.py
  
```

Note that on Windows you might have to give the full path to python.exe
if it's not in your PATH, on OSX you shouldn't need to do that. In
either case, Python will run the commands which define the procedure and
then call it and you should see the appropriate messages.

If you are working in Eclipse, running is even easier. Eclipse with
PyDev installed provides a Run menu (and a green Run button) where you
will find a Run As option. This should allow you to select "Python Run"
from that menu and your program will be executed by sending it to the
Python interpreter. Eclipse captures the output and shows it to you in
the console. The big advantage of using Eclipse is that if there are
errors when running your code, it will provide clickable links to let
you jump to their location. To run your code for a second time, you can
usually just hit the green run button and it will re-do the previous
run.

That's not the full story however. In general, Python programs are made
up of more than one file. It's generally good practice to split your
code up into modules (files) with a common function, so you might put
all of your database code in one module and your input/output code in
another. When you do this, you will typically also have a main module
which calls the procedures defined in the others. We won't be looking at
programs that need multiple modules until later but there's one habit
that you should get into now that will prepare you for that time.

Python doesn't have any concept of a *main* procedure like Java or C++
do. So when you execute a file like the one above it just defines all
the procedures and runs all the commands that are included in the file.
The *main* part is really any command that's not inside a procedure.
This is generally fine but if you ever wanted to import the above module
into another program, the Python interpreter would still run the
commands - so you would get your printed explanation whenever the module
was imported. To guard against this, there is a convention in Python
programs to put the *main* part of your program inside an if statement
like so:

```
def explain_python():
    """Print a message explaining what Python is."""
    
    print('Python is not a snake!')
    print('Python is a programming language!')
    
if __name__=='__main__':
    explain_python()
  
```

The test on the if statement uses a built in variable `__name__` which
is set by the interpreter to have a different value depending on how
this module (file) is being used. If the module is the one being run by
the interpreter, the value of `__name__` will be the string
`'__main__'`, but if this module is being imported into another program,
the value of `__name__` will be the name of this module (that is,
`'explain'` if you called the file `explain.py`).

If that's a bit confusing, don't worry too much. The important thing is
that you use the construct above to contain any calls to procedures that
you want to use in your program. You'll see more examples as we go
through more details of the language.

<div class="section exercises">

### Exercises

1.  Go through the procedure examples in the previous section and save
    them all in a single file `examples.py`. At the end of the file use
    an `if __name__=='__main__':` block to write test calls to all the
    procedures, printing out the results.
2.  Write a pair of modules (this.py and that.py) and import one into
    the other to see the different values of the `__name__` variable.
    Each one could define a procedure to print out the value of
    `__name__`. The code for `this.py` could look like this:

    ```
    def this():
       """show me the __name__"""
       print('This name is ', __name__)
       
    if __name__=='__main__':
       import that
       that.that()
       
    ```

    The code for `that.py` would be similar with this and that
    switched around. Run each file and note the values of `__name__`
    that are displayed.







More on Procedures
------------------

In Python, it is possible to specify default values in the parameter
list of a procedure, for example, this procedure computes the power of
an input value, the power defaults to 2:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided"""
    
    r = 1
    for i in range(y):
        r = r * x
    return r
```

You can then call this procedure with one or two values, if the second
value is not provided, the default value is used:

```
>>> power(3)
9
>>> power(3,3)
27
```

In Python, you can pass a keyword argument to a procedure by using the
corresponding parameter name (if you like). Let's take the following
procedure:&lt;/&gt;

```
def display(name, age, sex):
    """Print out name, age and sex in a nice format."""
    print('Name: ', name)
    print('Age:  ', age)
    print('Sex:  ', sex)
```

You can call this procedure in the following ways - with or without the
parameter names ("name", "age" and "sex"):

```
>>> display('John', 23, 'male')
Name:  John
Age:   23
Sex:   male
>>> display(name='John', age=23, sex='male')
Name:  John
Age:   23
Sex:   male
>>> display(age=23, name='John', sex='male')
Name:  John
Age:   23
Sex:   male
>>> display('John', sex='male', age='23')
Name:  John
Age:   23
Sex:   male
```

You can also write a procedure in such a way that it can accept an
arbitrary number of values:

```
def sum(*args):
    r = 0
    for i in args:
        r += i
    return r
```

Here the parameter `*args` accepts an arbitrary number of values and
will be a tuple in the procedure for further processing, as you can see
in the example which computes the sum of the values passed in. You can
call this procedure in the following ways:

```
>>> sum(5, 6, 8)
19
>>> sum(3, 3, 3, 3, 3)
15
```

### Variable Scoping

Let's talk about the **scope** of variables: a variable defined in the
body of a procedure has **local** scope and is therefore only valid
**within** the procedure. You can access the content of a **global**
variable inside the body of a procedure. But if you want to change a
global variable within a procedure, you have to use the "global"
keyword. Here is an example that illustrates the use of a "global"
variable within a procedure:

```
def demo():
    """Demonstrate variable scope"""
    
    global name
    name = 'John'
    sex = 'Male'
    print('Within the procedure:', name, age, sex)

name = 'Monkey'
age = 50
sex = 'Female'
print('Outside the procedure:', name, age, sex)
demo()
print('Outside the procedure:', name, age, sex)
```

The output of this program looks as follows:

```
Outside the procedure: Monkey 50 Female
Within the procedure: John 50 Male
Outside the procedure: John 50 Female
```

Note that the global variable `name` was modified inside the procedure
because of the global declaration. The global `sex` was not changed
because without the global declaration in the procedure, Python creates
a local version to shadow the global variable. The value of the global
`age` can be used within the procedure without a global declaration, as
long as we don't want to modify it.

<div class="section exercises">

### Exercises

1.  Write a procedure that takes a string and returns the number of
    words in the string. Make sure that the procedure as a doc-string
    that explains the argument and the return value.

    Show how to call the procedure to work out how many words are in
    this question.

2.  Write a procedure to test whether a string is a palindrome - that is
    it reads the same forwards as backwards. The procedure should take a
    string and return True if it is a palindrome and False otherwise.
    Include some tests of your procedure in your answer: examples of
    calling the procedure with various strings to check that it works
    as expected.

3.  Write a procedure 'splitwords' that takes a string and returns a
    list of the words in that string.

    Write a second procedure 'censor' that takes a list of words and
    returns a new list where every second word is replaced
    with "\*\*\*\*".

    ```
     
    >>> words = splitwords("this is my string")
    >>> censor(words)
    ['this', '****', 'my', '****']
    ```

4.  Write a procedure to count the frequency of occurrence of words in
    a string. It should return a dictionary containing the words as keys
    and the frequency count as data. Eg:

    ```
    >>> s = "some string...that's long"
    >>> freq = fcount(s)
    >>> freq['the'] 
    12
    >>> freq['string']
    1
    ```

    The basic idea is to increment the count if the word is already in
    the dictionary and initialise it to 1 if it's not.







File Handling
-------------

The most common way to read from a file, is to open it and then to
iterate over the lines of the file in the following way:

```
f = open('myfile.txt','r')

for line in f:
    print(line)

f.close()
```

The built-in procedure `open` takes two paramters, the first is the file
name to open, the second is a mode string. The mode string can be "r" to
read data, "w" to write data, "rw" to read and write and "a" for
appending data to the end of an existing file. When you are finished
reading or writing from a file, you should close it, if you don't close
it, Python may not actually write the file on disk since it caches file
contents in memory to improve execution speed. If you cannot read from a
file, Python rises a `ValueError` exception.

If you want to read all lines from a file and return them in a list of
strings, you can use the `readlines` method as follows:

```
f = open('myfile.txt','r')

lines = f.readlines()
print(lines)

f.close()
```

There are similar methods for writing a string to an open file: the
method `write()` writes a string to a file and the method `writelines()`
writes a list of strings to a file. Note that these two methods do not
add a newline (`\n`) to the strings.





Copyright © 2009-2012, Rolf Schwitter, Steve Cassidy, Macquarie
University

[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
