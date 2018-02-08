

Web Applications with SQLite
============================

SQLite is a database engine that is distributed with Python and supports
most of the SQL standard. It is ideal for developing database backed
applications and because it uses the same SQL as larger systems, it is
generally easy to port applications to a production database like MySQL
or Oracle for deployment.

This chapter discusses the development of a simple application that
stores data in an SQLite database and queries the database to generate
content in pages.



A Database Helper Class
-----------------------

To begin the application development we will first write a small helper
class to make using the database with WSGI a little easier. It is
possible to use the `sqlite3` module directly when writing web
applications but this class takes care of a few common operations and
makes application code a bit neater.

To make use of an SQLite database we use the `sqlite3` module; we first
open a connection to the database and then use a *cursor* to run queries
and get results, for example:

```python
conn = sqlite3.connect("mydatabase.db")
cursor = conn.cursor()
cursor.execute("select name, age from people where age > 21")
   
```

The helper class we will write will act like a connection. One of the
main reasons for writing this class is so that we don't have to repeat
the name of the database each time we want to make a connection. The
class will provide a default database name with the option of using an
in-memory database for testing.

Here's the definition of the `COMP249Db` class:

```python
class COMP249Db:
   """
   Provide an interface to the database for a COMP249 web application
   """

   def __init__(self, test=False):
       """
       Construct a database connection.  If test is True, use an
       in-memory database for testing purposes,
       otherwise use a database file called comp249.db
       """

       if test:
           self.dbname = ":memory:"
       else:
           self.dbname = "comp249.db"

       self.conn = sqlite3.connect(self.dbname)

   def cursor(self):
       """Return a cursor on the database"""

       return self.conn.cursor()

   def commit(self):
       """Commit pending changes"""

       self.conn.commit()
   
```

The class provides two methods, `cursor` returns a cursor from the
database connection and the `commit` method commits any changes to the
database. We can use the class just like `sqlite3.connect`:

```python
db = COMP249Db()
cursor = db.cursor()
cursor.execute("select name, age from people where age > 21")
   
```

Note that I've called the instance of the class `db` rather than `conn`
although it really is just like a connection. I'm thinking of this
object as the way that I'll connect to the database, so `db` is an
appropriate name.

Another advantage of using a helper class like this is that we can add
more methods to do useful things relating to our use of the database. A
full object oriented implementation could use methods on this class to
retrieve date from and make updates to the database. I'm going to write
some procedures below which could be written as methods. The reason I'm
not doing so is that I don't want to add in the complexity of object
oriented programming at this point for those students who aren't
familiar with these ideas. However, see the notes at the end of this
chapter for a discussion of this topic.





A Web Application
-----------------

Building on our previous example in the cookies chapter, we'll build a
sample application that presents the user with a form asking what they
like, but this time store the submitted likes in a database. We'll
display a list of the liked things below the form on the page.

We start with a basic application that accepts a form submission similar
to that used in earlier chapters. We'll extend this so that the form
data is stored in the database and displayed on the page.

The desired behaviour is that when we get a form submission, we store
the value submitted in the database and when we generate a response page
we include a list of database entries. To achieve this, we'll write two
procedures to store and read data from the database. We'll also need to
write a procedure to create the tables in the database. All of these
procedures make a kind of abstract interface to the database - we put
all of the SQL queries here and then call the procedures from within the
main application. First, let's look at the procedure to create the
database tables.

```python
def create_table(db):
    """Create database table for the likes application
    given a database connection 'db'.
    Removes any existing data that might be in the
    database."""

    cursor = db.cursor()
    cursor.execute("DROP TABLE IF EXISTS likes")
    cursor.execute("""
    CREATE TABLE likes (
       thing text
    )
    """)
   
```

This procedure just runs the SQL code to first drop the table if it
exits, and then create the table. This ensures that we start fresh with
no old data, which is good for development since we want to be able to
test with a consistent database state. Next, we'll look at the procedure
to store a new entry in the database.

```python
def store_like(db, like):
    """Store a new like in the database"""

    cursor = db.cursor()
    cursor.execute("INSERT INTO likes (thing) VALUES (?)", (like, ))
    db.commit()
  
```

Again, the procedure is just running a bit of SQL code to insert the
data. Note the use of the ? template to insert the value into the SQL
string. In this case, there is only one value but the second argument to
`cursor.execute` must be a tuple; a tuple of one thing in Python needs
to include a comma (`(like, )` rather than `(like)`), if you miss the
comma the brackets are ignored and you'll see odd behaviour. Finally,
the procedure to fetch data from the database returns all of the current
entries as a list.

```python
def get_likes(db):
   """Return a list of likes from the database"""

   cursor = db.cursor()
   cursor.execute("SELECT thing FROM likes")
   result = []
   for row in cursor:
       result.append(row[0])
   return result

   
```

The procedure can't simply return the result of `cursor.fetchall` since
this will be a list of tuples, each containing a single value. The for
loop in my procedure iterates over the rows returned from the query and
pulls out the zeroth element of each tuple, appending it to the result
list. If there are no rows returned from the query, the result list will
just be empty, which is appropriate behaviour.

Now that we have the building blocks for reading and writing the
database, we can finish writing the application. To generate the main
page, we just look in the database for the list of likes rather than the
cookie:

```python
@app.route('/')
def index():
    """Home page"""

    db = COMP249Db()

    info = dict()
    info['title'] = 'Welcome Home!'
    # get the list of likes from the database
    info['likes'] = get_likes(db)

    return template('dblikes.tpl', info)
    
```

Note that since `get_likes` returns a list of strings, I need to modify
the template we used in the cookie example where I could only like one
thing at a time. I can do this by inserting the following code into the
template:

```
         <p>Things you like:</p>
         % if likes:
         <ul>
             % for like in likes:
              <li>{{like}}</li>
             % end
         </ul>
         % end
    
```

The handler for the form submission also needs to change to store the
like into the database rater than the cookie. Here's the code:

```
@app.post('/likes')
def like():
    """Process like form post request"""

    # get the form field
    likes = request.forms.get('likes')

    if likes:
        store_like(db, likes)

    response.set_header('Location', '/')
    response.status = 303

    return 'Redirect to /'
    
```

Note that since we've written a nice interface to the database, the
application code itself is quite concise. It is much better practice to
write code like this rather than including SQL code inside the
application procedure. It also gives us more testable code since the
database interface can be tested independantly of the application
itself.

We still need to make a call to `create_table` at some point to make
sure the database is established. This should be before we try to do any
reading or writing of the database and we should only create the
database once, so the call should go in the 'main' part of the code:

```python
if __name__ == "__main__":
    db = COMP249Db()
    create_table(db)
    app.run()
    
```

This way, every time we run the application, a new, empty, database is
created. If you wanted to maintain the contents of the database between
runs, you would arrange to run `create_table` only once or write it so
that it doesn't remove any existing data. We'll leave that as an
exercise for the reader at this point.

That completes our little database backed application. It provides a
model for any database backed application that you might write. The read
and write procedures might get more complicated and there might be more
of them if there is more than one database table, but the general idea
should carry through to more complicated applications.





An Object Based Refactoring
---------------------------

As mentioned above, the COMP249Db class that we wrote could be extended
to do a more complete job of providing an object oriented interface to
the database. This section refactors the code above in a more object
oriented style. If you're not comfortable with object based programming,
this section is entirely optional.

The main goal of this object based interface is to hide all of the
detail of the database interface behind a single class. All database
operations will be carried out by methods on this class. The changes
required to the above code are quite simple; instead of using procedures
to operate on the database we convert them to methods on the COMP249Db
class. The only change needed is to replace the `db` argument with the
`self` variable:

```python
class COMP249Db:
    """
    Provide an interface to the database for a COMP249 web application
    """

    def __init__(self, test=False):
        """
        Construct a database connection.  If test is True, use an
        in-memory database for testing purposes,
        otherwise use a database file called comp249.db
        """

        if test:
            self.dbname = ":memory:"
        else:
            self.dbname = "comp249.db"

        self.conn = sqlite3.connect(self.dbname)

    def cursor(self):
        """Return a cursor on the database"""

        return self.conn.cursor()

    def commit(self):
        """Commit pending changes"""

        self.conn.commit()

    def create_table(self):
        """Create database table for the likes application.
        Removes any existing data that might be in the
        database."""

        cursor = self.cursor()
        cursor.execute("DROP TABLE IF EXISTS likes")
        cursor.execute("""
        CREATE TABLE likes (
           thing text
        )
        """

    def store_like(self, like):
        """Store a new like in the database"""

        cursor = self.cursor()
        cursor.execute("INSERT INTO likes (thing) VALUES (?)", (like, ))
        self.commit()

    def get_likes(self):
        """Return a list of likes from the database"""

        cursor = self.cursor()
        cursor.execute("SELECT thing FROM likes")
        result = []
        for row in cursor:
            result.append(row[0])
        return result
       
```

This class now contains all of the SQL code and all of the information
about the database for this application. The application will now
manipulate the database through `store_like` and `get_likes` method
calls. The changes required in the application are minimal:

```python
@app.route('/')
def index():
    """Home page"""

    db = COMP249Db()

    info = dict()
    info['title'] = 'Welcome Home!'
    # get the list of likes from the database
    info['likes'] = db.get_likes()

    return template('dblikes.tpl', info)


@app.post('/likes')
def like():
    """Process like form post request"""

    # get the form field
    likes = request.forms.get('likes')

    if likes:
        db.store_like(likes)

    return redirect('/')
    
```

The main code block also needs a minimal change:

```python
if __name__ == '__main__':
    db = COMP249Db()
    db.create_table()

    app.run()
    
```

There are other ways to write an object oriented database interface in
Python, but this shows one way of capturing all of the database specific
information in a single class that provides a clean interface to the
rest of the application.



[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).


