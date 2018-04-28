

Using SQLite from Python
========================



Introducing SQLite
------------------

[SQLite](http://www.sqlite.org/) is a lightweight relational database
system implemented as a shared library that can be embedded into
applications. It is widely used in applications by Apple, Adobe, Google
and many others, it is ideal if you want the benifits of a real SQL
database without the overhead of installing a large database
application. For web development, it provides a lightweight alternative
to larger production databases like MySQL, Oracle etc. Since it supports
most of the standard SQL language, applications can be developed using
SQLite and easily ported to a larger, production database system when it
is required.

SQLite runs on most platforms and can be
[downloaded](http://www.sqlite.org/download.html) and installed easily.
The standard installation provides a command line application that will
let you create and query databases. There are also a number of
applications both free and commercial that provide graphical interfaces
to SQLite databases, a list is maintained on [the SQLite
Wiki](http://www.sqlite.org/cvstrac/wiki?p=ManagementTools). You may
want to install one of these if you want to experiment with creating
databases and using SQL. As we will discuss later, there are also a
number of interfaces between various programming languages and SQLite
including Python, Java and others.

SQLite supports most of the standard SQL language. We won't provide an
introduction to SQL here as there are many available on the Web and in
various texts. We will include many examples as we go through the
features of SQLite and the Python interface; for many simple
applications, variations on these examples will be all that you need.

One important point of difference between SQLite and most other
relational database systems is that SQLite stores data in a single file
that is portable between different systems. If you create a database
with MySQL or Microsoft SQL Server, the database is stored somewhere on
your hard drive in an undisclosed location and access is mediated by the
server software. With SQLite, the database is stored in a single file
that you can manage just like all your other files. Where most database
systems require you to configure the name of the server, the port used
for communication and the username and password required to access it,
SQLite only needs to know the name of the database file. If you want to
back up your database, you can just take a copy of the file. If you want
a copy to carry around with you, just put it on your flash drive.

Here's a simple example of creating a database, inserting some data and
querying the database using the command line SQLite client. You can
start this on Windows by installing the software from the link above and
running `sqlite3` in a Command Prompt window or on Mac OS X using
Terminal.app. In this example I've used my Mac:

```
Macintosh> sqlite3 test.db
SQLite version 3.4.0
Enter ".help" for instructions
sqlite> create table people (first varchar, last varchar, age integer);
sqlite> insert into people values ("Steve", "Cassidy", 21);
sqlite> insert into people values ("Mary", "Mullins", 23);
sqlite> select * from people;
Steve|Cassidy|21
Mary|Mullins|23
sqlite> select * from people where age>21;
Mary|Mullins|23
```

This example creates a database in a file called `test.db` with a simple
table containing three fields for first and last name and age. Two of
these are strings of arbitrary length (varchar) and the last is an
integer value. Two rows are inserted into the table and a query is run
to select all of the rows. The second query finds only those rows where
the age field is greater than 21.





The Python SQLite Interface
---------------------------

The most common use of SQLite is from application programs as an
embedded datbase. SQLite itself is written as a system library in C
which means that it is relatively easy to port to new environments (eg.
your mobile phone) and can be linked into applications written in many
languages. For our purposes, the Python SQLite interface is most
relevant and there are a number of alternatives to choose from. We will
make use of the most popular of these which is
[pysqlite](http://pysqlite.org/).

Pysqlite provides an interface between SQL and Python such that we can
query the database using SQL and get the results back as Python data
structures. There are some bells and whistles that allow you to change
the way that you deal with results etc but the core of the interface is
simple. Here are the main concepts that you need to understand. One good
thing is that these concepts are shared with most other database
interfaces so that when you want to convert your code to MySQL in the
future you don't need to learn a new interface.

The first thing that is needed is a connection to the database system. A
connection object embodies all the required information to send queries
to the database and get responses back. For SQLite all that is needed to
create a connection is the name of the database file.

```
>>> from sqlite3 import dbapi2 as sqlite
>>> conn = sqlite.connect("test.db")
   
```

The next step is to create a cursor object from the connection; a cursor
is used to issue queries and retrieve results. Once we have a cursor we
can issue a query; this example reproduces the database creation shown
earlier.

```
cur = conn.cursor()
cur.execute("create table people (first varchar, last varchar, age integer)")
cur.execute('insert into people values ("Steve", "Cassidy", 21)')
cur.execute('insert into people values ("Mary", "Mullins", 23)')
conn.commit()
```



Note the use of single quotes to enclose the SQL query that contains
double quote characters. The above code creates the database and inserts
two rows in the same way as the first example. The call to
`conn.commit()` commits the changes that have been made, effectively
ensuring that they are saved to the database. Note that the commit
method is called via the connection object, not the cursor.

Running queries on the database is done in a similar manner with the
`execute` method of the cursor object. However, the most important thing
here is to get at the results of the query. This is done with one of the
methods `fetchall`, `fetchone` or `fetchmany`. As you might guess these
return all, one or a given number of rows from the result. The result of
`fetchall` and `fetchmany` is a list of sequences of the returned
matches from the query. The result of `fetchone` is a single sequence.
Here are some examples.

```
>>> cur.execute("select first,last,age from people")
<sqlite3.Cursor object at 0x6e980>
>>> cur.fetchone()
('Steve', 'Cassidy', 21)
>>> cur.fetchone()
('Mary', 'Mullins', 23)
```

In the first example, `fetchone` is used to return the next row from the
result; successive calls to `fetchone` return successive rows, when
there are no more `None` is returned.

```
>>> cur.execute("select first,last,age from people")
<sqlite3.Cursor object at 0x6e980>
>>> cur.fetchall()
[('Steve', 'Cassidy', 21), ('Mary', 'Mullins', 23)]
   
```

In this example, `fetchall` is used to get all results rows as a list.
Note that this returns a list (square brackets) of tuples (round
brackets) where each tuple contains three values corresponding to the
variables first, last and age in the query.

In both of these examples I've explicitly named the values I want
returned rather than using `select * from people`. It's a good idea to
get into the habbit of doing this since you might change your database
schema to add more fields and doing so could then introduce subtle bugs
into your code. If you name the fields, you know which the first second
and third elements are going to be in your result.

Using these methods we can write some simple code that runs a query and
generates a string containing an HTML table:

```
cur = conn.cursor()
cur.execute("select first, last, age from people")

table = "<table>"
table += "<tr><th>First</th><th>Last</th><th>Age</th></tr>"
for row in cur.fetchall():
     table += "<tr><td>" + row[0] + "</td>""
     table += "<td>" + row[1] + "</td>"
     table += "<td>" + row[2] + "</td></tr>"

table += "</table>"
   
```

All of the above conforms to the stanard Python database interface
specification (`dbapi`) and will work with most databases you can access
from Python. Pysqlite has a few extensions which make working with it a
little easier but which are non-standard. I'll point out two of these
here as they can make code a little neater.

Firstly, you can execute SQL directly via a connection object without
having to first create a cursor. Calling the `execute` method of a
connection runs the SQL and returns a cursor object that you can use as
above. Secondly, Pysqlite has an extension that makes the resulting rows
returned from a query behave like dictionaries rather than tuples. If
you use this you can address the fields by name rather than by numerical
position which makes your code more readable and less prone to bugs.
Here's the above example again using these two extensions.

```
# first add the Row class to the connection
# which makes all query results behave like dictionaries
conn.row_factory = sqlite.Row

# now run our query directly via the connection
cur = conn.execute("select first, last, age from people")

# and generate the table using names to index the results
table = "<table>"
table += "<tr><th>First</th><th>Last</th><th>Age</th></tr>"
for row in cur.fetchall():
     table += "<tr><td>" + row['first'] + "</td>""
     table += "<td>" + row['last'] + "</td>"
     table += "<td>" + row['age'] + "</td></tr>"

table += "</table>"  
    
```

### Adding Parameters to Queries

Quote often you will want to use the value of a Python variable as part
of an SQL query. For example if we have the last name of a person in a
variable and we want to find their age, the temptation is to construct
an SQL query using the standard Python string functions:

```
lastname = "Cassidy"
query = "select age from people where last='"+lastname+"'"
cur = conn.execute(query)
...
    
```

While this will work in many cases it has a problem which stems from the
fact that we don't know in advance what the string `lastname` contains
(since it probably came from user input or via the web). In the above
example all is well but if the value of `lastname` were `"D'Arcy"` then
the query we would construct would be:
`"select age from people where last='D'Arcy'"` which is badly formed
because of the extra single quote. Even worse, if a malicious user sent
a last name of `"x'; delete from people where 'a'='a"` the query would
be
`"select age from people where last='x'; delete from people where 'a'='a'"`
which would delete every row from your database. This is the basis of
the so-called SQL Injection attack that is a very common exploit on the
web.

So, we need a better way to introduce variable values into an SQL
string. Pysqlite provides a suitable mechanism which ensures that any
special characters (like ') in the string are quoted before the SQL is
run. So, `"D'Arcy"` would be inserted as `"D\'Arcy"`. The mechanism for
this is a second argument to `execute` to carry the values to be
inserted and question marks in the query string to show where the values
should be inserted. Here's the above example done right:

```
lastname = "Cassidy"
query = "select age from people where last=?"
cur = conn.execute(query, [lastname])
...
    
```

Note that no quotes are used around the question mark in the query
string, they are inserted automatically. The second argument to
`execute` must be a sequence (list or tuple, here I've used a list) and
the question marks are substituted in order. Here's an example with two
values:

```
cur = conn.execute("select age from people where first=? and last=?", [first, last])
    
```

You should **always** use this mechanism to substitute values into your
SQL queries. Not doing so will lead to bugs and may make your web
scripts insecure.





Summary
-------

I've only covered a small amount of SQLite and Pysqlite here but this
should be enough to enable you to write some very useful scripts to
store and manipulate data. Further details are available on the web for
[SQLite]() and [Pysqlite](http://pysqlite.org/).

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


