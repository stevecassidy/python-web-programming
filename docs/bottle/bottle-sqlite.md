

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


Connecting to the Database
--------------------------

As described in [the earlier chapter](../python/pysqlite.md), SQLite stores 
databases as files and connecting to the database creates the file if
it doesn't already exist.  In a web application we need to maintain
an open connection to the database so that the handler for any request that comes in
can use the database to retrieve data to populate the page that is returned. 
One important thing to remember is that a web application is handling
many requests for multiple users and each request handler might need to
query and possibly update the database.  This means that we need to 
manage connections to the database carefully.  

A good solution to this problem is to use the 
[bottle sqlite plugin](https://bottlepy.org/docs/0.12/plugins/sqlite.html) which 
creates database connections for us and arranges to pass them to 
route handlers as required.  

```python
import bottle

app = bottle.Bottle()
plugin = bottle.ext.sqlite.Plugin(dbfile='test.db')
app.install(plugin)

@app.route('/show/:item')
def show(item, db):
    cursor = db.cursor()
    cursor.execute('SELECT id, description from items where name=?', item)
    row = cursor.fetchone()
    if row:
        return template('showitem', page=row)
    return HTTPError(404, "Page not found")
```

As this example adapted from the plugin web page
shows, we first configure the plugin with the name of the database file and
then install the plugin in our app.   Then, we give our handler an extra
argument `db` (it can go at the start or end of the argument list).  The
plugin arranges for `db` to be an open connection to the database. 

The plugin is smart in that it ensures that any outstanding transactions are
committed at the end of the request and rolls back changes if the request fails
for any reason.  The plugin makes managing database connections much easier 
when writing Bottle applications.


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
    cursor.execute("INSERT INTO likes (thing) VALUES (?)", [like])
    db.commit()
  
```

Again, the procedure is just running a bit of SQL code to insert the
data. Note the use of the ? template to insert the value into the SQL
string. In this case, there is only one value but the second argument to
`cursor.execute` must be a list or tuple; in this case I've used a list. 

Finally, the procedure to fetch data from the database returns all of the current
entries as a list.

```python
def get_likes(db):
   """Return a list of likes from the database"""

   cursor = db.cursor()
   cursor.execute("SELECT thing FROM likes")
   result = []
   for row in cursor:
       result.append(row['thing'])
   return result
```

The procedure can't simply return the result of `cursor.fetchall` since
this will be a list of `Row` objects, each containing a single value. The for
loop in my procedure iterates over the rows returned from the query and
pulls out the `thing` field of each row, appending it to the result
list. If there are no rows returned from the query, the result list will
just be empty, which is appropriate behaviour.

Now that we have the building blocks for reading and writing the
database, we can finish writing the application. To generate the main
page, we just look in the database for the list of likes rather than the
cookie:

```python
@app.route('/')
def index(db):
    """Home page"""

    info = {
        'title': 'Welcome Home!',
        'likes': get_likes(db)
    }

    return template('dblikes.tpl', info)
```

Note that since `get_likes` returns a list of strings, I need to modify
the template we used in the cookie example where I could only like one
thing at a time. I can do this by inserting the following code into the
template:

```html
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

```python
@app.post('/likes')
def like(db):
    """Process like form post request"""

    # get the form field
    likes = request.forms.get('likes')

    if likes:
        store_like(db, likes)

    return redirect('/')
```

Note that since we've written a nice interface to the database, the
application code itself is quite concise. It is much better practice to
write code like this rather than including SQL code inside the
application procedure. It also gives us more testable code since the
database interface can be tested independently of the application
itself.

We still need to make a call to `create_table` at some point to make
sure the database is established. This should be before we try to do any
reading or writing of the database and we should only create the
database once, so the call should go in the 'main' part of the code.  
We also need to initialise the bottle plugin. I've put both fragments of
code in the same place in this case to simplify things:

```python
if __name__ == "__main__":
    # code to connect to the database and create the tables
    DATABASE_NAME = 'test.db'
    db = sqlite3.connect(DATABASE_NAME)
    create_tables(db)

    # code to run our web application
    plugin = bottle.ext.sqlite.Plugin(dbfile=DATABASE_NAME)
    app.install(plugin)
    
    # run the application
    app.run()
    
```

(Note this might seem confusing. I'm connecting to the database to run the 
`create_tables` function but then connecting again in the plugin. This is
required because these are really two separate operations.)

This way, every time we run the application, a new, empty, database is
created. If you wanted to maintain the contents of the database between
runs, you would arrange to run `create_table` only once or write it so
that it doesn't remove any existing data.  One common solution is to
put the database creation code into a separate module that you can run
once to create or reset the database. You could then remove that code from
the main web application module.

That completes our little database backed application. It provides a
model for any database backed application that you might write. The read
and write procedures might get more complicated and there might be more
of them if there is more than one database table, but the general idea
should carry through to more complicated applications.





