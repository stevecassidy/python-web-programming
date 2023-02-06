

Testing Python Programs
=======================

Testing is a fundamental part of software development and web software
development is no different. We need to be sure that the code we write
does what we expect and continues to do so as changes are made to the
implementation. While it's possible to test code by hand, automated unit
testing is a less error prone way of running a set of tests and
validating the results.

There are two styles of testing available as part of the standard Python
library. The `doctest` module implements a simple form of test that are
written as part of the documentation for a procedure. The `unittest`
module provides a more complex style of testing using clases similar to
the JUnit framwork for Java. This chapter will describe both styles of
testing and give examples of how they can be used in program
development.



Easy Testing with `doctest`
---------------------------

Perhaps the easiest way to start testing in Python is using the
[doctest](http://docs.python.org/2/library/doctest.html) module. Writing
tests with `doctest` is a matter of capturing the way that you call your
procedures and the results that you expect in the interactive Python
shell. The commands and their output are recorded in the documentation
string for the procedure to be tested, and so form part of the
documentation for the procedure - this in itself is often quite useful
as it illustrates how your code can be used.

Let's work through an example of writing and testing a procedure compute
the power of a number. The procedure will have the following signature
and documentation string:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided"""
    
    pass
```

Note that the word `pass` here is a Python statement that does nothing,
it's used, as here, where we need a statement of some kind to make the
code compile, but we don't want to do anything (or don't know what to do
yet). We'll replace `pass` with the actual implementation later.

Before we write the code, the *Test Driven Development* methodology says
that we should write the tests. For `doctest`, we write out what we'd
expect if we were to call the procedure in an interactive Python
session:

```
>>> power(2)
4
>>> power(4)
16
>>> power(2, 3)
8
```

In this example I've written out a few test cases with the expected
results. To turn this into a test, we add the examples to the
documentation string for the procedure:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided
    
>>> power(2)
4
>>> power(4)
16
>>> power(2, 3)  
8
    """
    pass
```

To run the tests we include the following lines at the end of the module
(file) contianing the code and tests:

```
if __name__ == "__main__":
    import doctest
    doctest.testmod()
```

If this module is run (either on the command line or via Eclipse), the
output is as follows:

```
> python3 power.py
**********************************************************************
File "power.py", line 5, in __main__.power
Failed example:
    power(2)
Expected:
    4
Got nothing
**********************************************************************
File "power.py", line 7, in __main__.power
Failed example:
    power(4)
Expected:
    16
Got nothing
**********************************************************************
File "power.py", line 9, in __main__.power
Failed example:
    power(2, 3)
Expected:
    8
Got nothing
**********************************************************************
1 items had failures:
   3 of   3 in __main__.power
***Test Failed*** 3 failures.
```

As you can see, all of the tests failed and a message is shown for each
about what test is being run and what went wrong. Now, I can write code
to make the tests pass. Now one way to implement this procedure to pass
the first two tests would be to return the square of the input `x`:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided
    
>>> power(2)
4
>>> power(4)
16
>>> power(2, 3)  
8
    """
    
    return x*x
```

Now, if we re-run the module, the output is:

```
> python3 power.py
**********************************************************************
File "power.py", line 9, in __main__.power
Failed example:
    power(2, 3)
Expected:
    8
Got:
    4
**********************************************************************
1 items had failures:
   1 of   3 in __main__.power
***Test Failed*** 1 failures.
```

Now only one test is failing, the first two tests that are asking for
the square of the input generate no output. Sometimes it's useful to see
some output from the passing tests (if only for reassurance that
something is happening). To do this we can add the `-v` option on the
command line:

```
> python3 power.py -v
Trying:
    power(2)
Expecting:
    4
ok
Trying:
    power(4)
Expecting:
    16
ok
Trying:
    power(2, 3)
Expecting:
    8
**********************************************************************
File "power.py", line 9, in __main__.power
Failed example:
    power(2, 3)
Expected:
    8
Got:
    4
1 items had no tests:
    __main__
**********************************************************************
1 items had failures:
   1 of   3 in __main__.power
3 tests in 2 items.
2 passed and 1 failed.
***Test Failed*** 1 failures.
```

As I complete the implementation of `power` I can re-run the tests to
check that my implementation matches my expectations. Once it does, the
output (without the `-v` option) should be empty; I can then move on to
the next piece of work.

If I later discover a bug in the code, the tests can be updated to
reproduce the bug and help me correct it. For example, if I find that
when I call the function with the second argument greater than 5, the
wrong result is returned, I can add a new line to the tests:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided
    
>>> power(2)
4
>>> power(4)
16
>>> power(2, 3)  
8
>>> power(2, 6)
64
    """
   ...  
```

Now I can run the tests and I expect the new one to fail - this
reproduces the bug. I can now work on fixing it, safe in the knowledge
that when the test passes, the bug will be fixed. For completeness I
would probably add more than one test to illustrate the bug (eg. one
even and one odd value).





Unit Testing with `unittest`
----------------------------

The second style of tests in Python is implemented using the `unittest`
module. In this case, tests are written separately to the code being
tested, but the idea that we are calling the procedures under test and
checking the results remains.

A unit test in Python is a class with one or more methods with names
starting with `test`. The test methods will generally call the code
under test and make assertions about the results. A test runner runs all
of the test methods and reports the results as pass/fail including any
messages generated in the process. To illustrate, here's a simple
example of a unit test.

```
import unittest

class Test(unittest.TestCase):

    def testNothing(self):
        """Illustrate the unit testing framework"""
        
        s = "this is a string"
        
        words = s.split()
        self.assertEqual(len(words), 4, "expected four words")
        
if __name__ == "__main__":
    unittest.main()
   
```

In this example we import the `unittest` module and define a subclass of
`unittest.TestCase` to contain our test methods. We define one test
method as an example which splits a string into words and then tests
whether the length of the result is 4. The assertion is written as a
call to `self.assertEqual` which takes three arguments, the first two
are values that are supposed to be the same, the third is a message to
display if the assertion fails.

The final part of the test file is the *main* section which calls
`unittest.main()`. This call finds all of the tests in the file and runs
them, reporting the results. There are other ways of running tests but
this is the simplest method.

If you execute this file from the command line, you'll see the following
output:

```
.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK   
   
```

The test we wrote passed so we see no output other than the number of
tests that were run. If you are working in Eclipse, you can run your
test files in a slightly different way. From the "Run" menu choose "Run
As..." and select "Python unit-test". This will run your tests and show
the output above, but also give you a PyUnit tab next to the console
with a breakdown of the tests and a few handy controls. In the
screenshot below you can see the result of running the simple tests
above, since everything passed I get the green bar, if there had been
failures the bar would be red and there would be details shown of the
errors or failure messages.

<div class="figure">

![Screenshot of Eclipse running a python unit test](eclipse-pyunit.png)
Screenshot of Eclipse running a Python Unit test.



A little more interesting is what happens when a test fails. Let's add
another assertion to the sample test above that will fail:

```
import unittest

class Test(unittest.TestCase):

    def testNothing(self):
        """Illustrate the unit testing framework"""
        
        s = "this is a string"
        
        words = s.split()
        self.assertEqual(len(words), 4, "expected four words")
        
        self.assertTrue(3==4, "three does not equal four")
        
if __name__ == "__main__":
    unittest.main()
   
```

Here I've used another kind of assertion `self.assertTrue` which will
fail unless the first argument evaluates to `True`. My test will fail so
we should see the result of a failure. Here's the output generated:

```
======================================================================
FAIL: testNothing (testfail.Test)
Illustrate the unit testing framework
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/steve/workspace/practasks/src/testfail.py", line 13, in testNothing
    self.assertTrue(3==4, "three does not equal four")
AssertionError: three does not equal four

----------------------------------------------------------------------
Ran 1 test in 0.000s

FAILED (failures=1)
  
```

You can see here the failure message ("three does not equal four") and
the location of the failure in the test code. This should allow you to
go in and debug the problem. If you're running the tests in Eclipse, the
location is a link directly to the offending line, just click on it and
debug.

### A Real Example

In the previous example we tested built in Python procedures, of course
what we want to do is test our own code. In this case, the code being
tested will be in a separate module to the test code. Let's look again
at an example of testing the `power` procedure. Our main module will be
contained in the file `power.py`:

```
def power(x, y=2):
    """Return x to the power of y, y defaults
    to 2 if not provided"""
    
    pass
```

The test module will import this module and then define some tests. In
writing tests we need to think about what the important characteristics
of the target procedures are and what might go wrong in their
implementation. In this case we have a default argument, we should test
that it does in fact default to 2, and we should test that the procedure
works for interesting values of y, for example y=0, y=1 and y=20. These
are interesting because 0 and 1 are unusual (did we consider that the
power could be 0 or 1?) and 20 is big. So, we can write the test file as
follows:

```
import unittest

# import the procedure we're testing
from power import power

class Test(unittest.TestCase):

    def testPowerDefaultValue(self):
        """Does the exponent argument properly default to 2"""
        
        self.assertEqual(4, power(2), "failure with default arg")
        self.assertEqual(16, power(4), "failure with default arg")
        
    def testPowerVariousExponents(self):
        """Test various values of exponent for power"""
        
        self.assertEqual(1, power(10, 0), "10^0 should be 1")
        self.assertEqual(10, power(10, 1), "10^1 should be 10")
        self.assertEqual(100000000000000000000, power(10, 20), "10^20 should be very large")
        
if __name__ == "__main__":
    unittest.main()  
  
```

I've included two test methods here, the first tests the default value
of the exponent, the second tests various values of exponent. Each test
has a number of assertions about the returned value of the procedure
`power`. Note that at the top of the file we import the `power`
procedure from the `power` module so that we can use it in the tests.
Running the tests gives the following output, both of my tests fail:

```
> python power_test.py
FF
======================================================================
FAIL: testPowerDefaultValue (__main__.Test)
Does the exponent argument properly default to 2
----------------------------------------------------------------------
Traceback (most recent call last):
  File "power_test.py", line 11, in testPowerDefaultValue
    self.assertEqual(4, power(2), "failure with default arg")
AssertionError: failure with default arg

======================================================================
FAIL: testPowerVariousExponents (__main__.Test)
Test various values of exponent for power
----------------------------------------------------------------------
Traceback (most recent call last):
  File "power_test.py", line 17, in testPowerVariousExponents
    self.assertEqual(1, power(10, 0), "10^0 should be 1")
AssertionError: 10^0 should be 1

----------------------------------------------------------------------
Ran 2 tests in 0.001s

FAILED (failures=2)
  
```

The error messages here are a little more complicated than those for the
`doctest` module but reading them carefully shows where the failure
occured in each case. The first test failed when trying to compute
`power(2)`, the second on `power(10, 0)`. I can now read through the
test to understand what might be going on. Obviously in this case I've
not actually written the code, but in general I will be using these
messages to help debug my code.

If I fix my implementation and re-run the tests I'll eventually get the
output:

```
> python power_test.py
..
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
```





Testing and Debugging
---------------------

Testing effectively is a big topic, we've only really covered the basics
here. There are more assertions that you can use in your tests, you can
find out about them from the [python documentation on
unittest](http://docs.python.org/3/library/unittest.html). Testing more
complicated code can require special techniques. In our case we'll want
to test web applications which raises another set of problems, but we'll
look at them as we discover how web applications are written in Python.

Having a set of unit tests for your code is the most useful tool in
debugging your programs. Breaking your problem down into procedures is a
fundamental part of building a complex piece of software, but it leaves
you with a problem that each procedure only does a small part of the
task, so you can't test the whole application until you've written all
the procedures. Unit tests give you a way of testing each individual
procedure to ensure that it meets your expectations.

The [Test Driven Development](http://www.agiledata.org/essays/tdd.html)
methodology suggests that you should write your tests before you write
any code. This approach forces you to think about what your procedures
are going to do in enough detail before you start writing them -
something you should be doing anyway. Whether you write your tests first
or not, you should write tests early in the development cycle to allow
you to run every bit of code you write and check that it does what you
expect.

When you are writing code there will inevitably be bugs creeping in;
either your code crashes or returns the wrong values for some input.
Having a set of tests help in debugging firstly because it gives you a
repeatable way of running your code without having to retype commands
yourself over and over. It can also allow you to capture the specific
cases that are causing trouble in an assertion or specific test. For
example, say you are writing a credit card number validator and for some
reason you get the wrong answer for a given card number. You can write a
test with that card number value and then go in with the debugger to
work out what is going on when the test is running. When you've fixed
the bug, having the test there ensures that it doesn't emerge again when
you add new features.

Sometimes debugging large programs causes problems because they are
large. Unit tests allow you to run smaller parts of your program and get
them working independently. This means that when you put them together,
they are more likely to do what you intended and will be easier to
debug.





[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
