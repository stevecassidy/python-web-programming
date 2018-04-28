

Python Modules
==============



Overview
--------

So far we've looked at the core Python language, everything we've seen
is built into Python. One of the major features of Python though is the
very broad range of modules that are shipped with the standard
distribution. These modules do everything from cryptography to parsing
web pages and sending email and as you learn to develop in Python you
will learn more about their capabilities.

The Python standard library is documented in the [Module Index]()
section of the Python manual. You'll find chapters on all of the modules
that include examples of how to use them; it's well worth skimming
through it and exploring anything that looks interesting so that when
you're working on a problem, you remember that there is a relevant
module. In this course we'll only use a few modules and probably only a
small part of each of them.

In some cases, the problem you have isn't solved in the standard library
but someone has published a third party module that does the job. The
[Cheese Shop]() is a register of third party modules and installing them
is easy thanks to the [pip]() tool that will download, build and install
a module from the command line.

To use a module in your application, you need to import it into your
program. You do this with the `import` statement before you use anything
from the module. For example, to use the `listdir` procedure from the
`os` module (which returns a list of files in a directory) we would
write:

```
import os

print(os.listdir("."))
    
```

(The argument to `listdir` is the directory to list, I gave it "." which
stands for the current directory). Note the dot notation between the
module name `os` and the procedure name. The dot is used in Python as a
general way to refer to components of objects, we saw it when we looked
at strings and sequences (remember `numbers.sort()` and `str1.upper()`).
In this case the we're referring to a procedure inside a module.
Sometimes you'll see multiple dots because modules can be nested, e.g.
`os.path.exists()`.

Sometimes you just want one procedure from a module, in this case you
can use `from xxx import yyy` notation. This allows you to use the raw
name of the procedure without the module name:

```
from os import listdir

print(listdir("."))
    
```

You can import more than one name:

```
from os import listdir, getcwd

print("Current directory:", getcwd())
print(listdir("."))
    
```

You can even import all the exported names from a module
(`from os import *`). However this is discouraged because it generally
means that you didn't think it through - the danger is that you import a
name that clashed with something in your own program.

Finally, you can change the names that you import. You might do this if
the name you were importing might clash with another name in your
program of from another module.

```
from os import listdir as showMeTheFiles

print(showMeTheFiles("."))
    
```

The rest of this chapter will briefly describe some useful Python
modules.





The `os` Module
---------------

This module contains various procedures for accessing operating system
services in a platform independant manner. For our purposes, the main
things we will use are to access the file system although the module
also provides access to running processes. A few useful procedures are:

-   `os.listdir(dirname)` returns a list of the names of the files in
    the directory `dirname`.
-   `os.getcwd()` returns the current working directory that your script
    is running from.
-   `os.mkdir(dirname)` creates a new directory with the given name

A sub-module `os.path` provides many procedures to help manipulate file
names (path names including the directory names) in a platform neutral
way.

-   `os.path.join(dirname, filename)` joins the two names together with
    the right directory separator for the platform, that is, use a
    forward slash (/) on Mac and Linux and a backward slash (\\)
    on Windows. You should use this to manipulate path names so that
    your code will work on any platform.
-   `os.path.split(pathname)` returns a tuple (head, tail) where `tail`
    is everything after the last directory separator and `head` is
    everything before it.
-   `os.path.basename(pathname)` returns the last part of the path name,
    after the last directory separator.
-   `os.path.exists(filename)` returns True if the filename is an
    existing file, False if not.
-   `os.path.isdir(name)` returns True if the name is an existing
    directory, False otherwise.

<div class="section exercises">

### Exercises

1.  







The `re` Module: Regular Expressions
------------------------------------

Regular expressions are patterns that match all or part of a string,
they are very useful in any kind of text processing application and
every programmer should understand how and when to use them. The Python
`re` module provides support for various operations using regular
expressions, this section gives some details of the most useful parts of
this module.

A regular expression is a pattern specified in a special language where
certain symbols affect the way that strings are matched. For example,
the '.' character will match any character in a string, so the regular
expression `'...'` will match any sequence of three characters, whatever
they are. The full language is quite complicated but the most useful
parts are simple to master. We'll first look at a simple example pattern
and show some of the things you can do with it, then describe the most
useful parts of the regular expression language.

If I want to find all of the dollar amounts in a text I can write a
simple regular expression that matches things like \$4,000, \$3, \$200
etc. (for simplicity, I'm ignoring amounts with a decimal point).
Basically I'm looking for a dollar sign, followed by one or more digits,
possibly with commas. That last sentence gives a model for the regular
expression I need to write, I just need to encode that in the regular
expression language:

-   **A dollar sign**: `'\$'` the dollar sign is special in the regular
    expression language, it means match at the end of a string, so we
    need to preceed it with a backslash to just match a dollar.
-   **followed by one or more digits possibly with commas**:
    `'\$[0-9,]+'` The square bracket notation matches any character from
    the set in brackets. In this case I include the digits 0-9
    (shorthand for including all the digits) and the comma character.
    The + sign after the brackets means do this one or more times.

So the final pattern we have is `'\$[0-9,]+'`, this should match any
dollar amount in a text. Let's see how to apply this to search for
occurrences of dollar amounts in a text.

The `re.search` procedure finds matches to a pattern in a string. The
returned value from the `re.search` method is a match object which
contains details of the matching text. If there is no match then it
returns `None`. So, the first use of this procedure is to simply test
whether the pattern is present or not, since None evaluates to False and
the match object to True in a test, we can write:

```
 
import re

def string_has_money(text):
    """Return True if this text string
    contains a dollar amount, False otherwise."""
    
    dollar_re = r'\$[0-9,]+'
    if re.search(dollar_re, text):
        return True
    else:
        return False
 
```

Next I might want to find what the dollar amounts are in a string. For
this I need to interrogate the return value of the `re.search`
procedure. As I said, this is an object and we can call the `group()`
method to find what was matched:

```
 
import re

def get_money_from_string(text):
    """Return the first dollar amount from the
    text string or None if none is found."""
    
    dollar_re = r'\$[0-9,]+'
    match = re.search(dollar_re, text)
    if match:
       return match.group()
    else:
       return None
 
```

I might also want to find all of the matches to this pattern. There are
two ways to achieve this. The procedure `re.findall` returns a list of
strings that match the pattern and the procedure `re.finditer` allows
you to iterate over the matches with a for loop. So, I can find all
dollar amounts like this:

```
 
import re

def get_all_money_from_string(text):
    """Return a list of the dollar amounts from the
    text string or the empty list if none is found."""
    
    dollar_re = r'\$[0-9,]+'
    return re.findall(dollar_re, text)
 
```

Finally, I might want to censor a text by replacing any dollar amount
with \$\$\$\$CAPITALISM\_SUCKS!!!!. I could do this with the `re.sub`
procedure:

```
 
import re

def censor_text(text):
    """Replaces any dollar amount in the text
    string with a suitable anti-capitalist message.
    Returns the resulting string."""
    
    dollar_re = r'\$[0-9,]+'
    message = "$$$$CAPITALISM_SUCKS!!!!"
    return re.sub(dollar_re, message, text)
 
```

These are just a few of the things you can do with the regular
expression library. In particular the match object that is returned by
`re.search` has many more capabilities that are useful for more
complicated patterns.

### More on Regular Expression Patterns

Here are the most useful parts of the regular expression language. A
more complete reference can be found [in the Python
documentation](http://docs.python.org/library/re.html#regular-expression-syntax).

'.'
:   Matches any character except newline

'\[\]'
:   Used to indicate a set of characters and matches any one of
    those characters. You can include ranges like \[a-z\], \[0-4\],
    \[A-F\] as well as explicit sets like \[abc\]. Special characters
    like . and + lose their meaning inside of square brackets so
    \[0-9.\] matches either a digit or a period.

'\\d'
:   Matches a decimal digit, equivalent to '\[0-9\]'

'\\s'
:   Matches any whitespace character, space, tab or newline etc.

'\\S'
:   Matches any non-whitespace character, the opposite of \\s.

'\\w'
:   Matches any alphanumeric character or underscore, equivalent
    to \[A-Za-z0-9\_\].

'\*'
:   A modifier which means that the previous pattern matches zero or
    more times.

'+'
:   A modifier which means that the previous pattern matches one or
    more times.

'?'
:   A modifier which means that the previous pattern is optional
    (matches zero or one time).

<div class="section exercises">

### Exercises

1.  Regular expressions can be used to locate HTML tags in a web page.
    When a search engine is creating an index of a web page, it must
    remove the tags to leave just the words behind. Write a procedure
    `remove_html` which takes a string containing HTML text and returns
    the text with all of the HTML tags removed. Remember that HTML tags
    can be upper or lower case and can opening tags can
    contain attributes.
2.  Another requirement for a search engine processing a web page is to
    extract all of the URLs contained in a page. Write a procedure that
    uses a regular expression to match all of the anchor tags
    (&lt;a href="http://www.example.com/"&gt;) and returns a list of the
    URLs found. Assume that anything inside of the href attribute is a
    URL but note that either single or double quotes or no quotes at all
    are allowed around the attribute value.







Copyright © 2009-2012 Rolf Schwitter, Steve Cassidy, Macquarie
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
