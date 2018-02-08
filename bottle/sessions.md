

Session Management
==================

The HTTP protocol is stateless, which means that every HTTP request that
arrives at a server can be treated independently and the server doesn't
need to remember anything about who it sends pages to. This means that
web servers can be made very efficient and can serve large amounts of
traffic very quickly. The down-side is that we need to develop another
mechanism to keep track of an individual user's interaction with our
site. We might want to do this to enable web commerce - implementing a
shopping cart for example - or just so that we can understand our user's
better, maybe to serve them appropriate advertising.

The general model for keeping track of users is the *user session*. A
session begins when the user first visits one of the pages on our site,
and ends either after a fixed time or when the user takes some action
like logging out of the site. Sessions can be anonymous or identified
depending on the requirements of the particular site. An anonymous
session assigns a unique identifier to a user but doesn't associate that
with a real identity. An identified session asks the user to login and
identify themselves at the start of the session.


Cookies and Sessions
--------------------

User sessions are implemented using the [HTTP cookie](cookies.html)
mechanism. As discussed earlier, cookies provide a means of maintaining
state between HTTP requests by requiring that a client return a cookie
with every request once it has been sent as part of an HTTP response.

Cookies themselves can be used to store information about the client's
actions. For example, an early use of cookies was to store the items in
a shopping cart; as the user selected items to be added to the cart, the
cookie value would be updated with the item identifier and returned to
the client. In this way, the list of items in the cart is stored by the
client, not the server. Only when the user wants to purchase the items
is any server side storage needed (to represent the order). This is a
kind of session management that relies entirely on the client to store
the session state. It has the advantage of reducing the storage
requirements on the server but puts some limits on the amount of
information that can usefully be stored. While cookies can be used to
store up to around 4k of data, large cookies make each HTTP request
large and potentially impact the performance of the site. Add to this
the fact that acquiring user data is seen as a very positive thing for
business these days - user data is a valuable asset - and we find that
it is now very uncommon to implement sessions in this way.

The alternative to storing user session data in the cookie is to store
it in a server side database and use the cookie value as a key into the
database. This is the standard approach to user session management which
is implemented in most web development frameworks. The server side
database requires a single table that will store the session key and
whatever information the site wishes to associate with a user. This
might be a list of items for a shopping cart or a page visit history if
we are trying to keep track of how users are using the website.


Sessions Example
----------------

To illustrate anonymous session management we'll develop a simple
application that extends the *likes* application described in the
[SQLite chapter](bottle-sqlite.html). In that version we used a single
database table to store likes, there were no users and everyone visiting
the site would see the same list. This version will store the likes
along with a user identifier that we will pass back to the user in a
cookie. To start, we add a new table to the database to store the
session keys and modify the likes table to include the session key as a
field associated with each like:

```python 
def create_table(db):
    """Create database table for the application
    given a database connection 'db'.
    Removes any existing data that might be in the
    database."""

    cursor = db.cursor()
    cursor.execute("DROP TABLE IF EXISTS likes")
    cursor.execute("DROP TABLE IF EXISTS sessions")
    cursor.execute("""
    CREATE TABLE likes (
       thing text,
       key text
    )""")
    cursor.execute("""
    CREATE TABLE sessions (
        key text unique primary key
    )
    """)
 
```

The `key` field will be a randomly generated string that will be used to
identify the user. The `sessions` table stores all current valid
sessions so that we can validate cookies that are sent to us - if a
session key isn't in the table then it is some kind of fake cookie that
might be being used to attack our site. We add the key field to the
`likes` table so that each liked thing is associated with a session key.
When we serve a page now, we'll only list those likes for the current
user.

The next step is to write a function to create a new entry in the
sessions table. This will generate a new random key, add it to the
database and create a cookie in the response to be sent back to the
user:

```python
def new_session(db):
    """Make a new session key, store it in the db.
    Add a cookie to the response with the session key and
    return the new session key"""

    # use the uuid library to make the random key
    key = str(uuid.uuid4())
    cur = db.cursor()
    # store this new session key in the database with no likes in the value
    cur.execute("INSERT INTO sessions VALUES (?)", (key,))
    db.commit()

    response.set_cookie(COOKIE_NAME, key)

    return key
  
```

Generating a unique identifier in Python is made easy by the `uuid`
(universally unique identifier) module (UUID is an internet standard for
generating identifiers that are very unlikely to be duplicates). The
`uuid4` function generates a random identifier as an instance of the
UUID class, the code above converts this to a string and stores it in
the variable `key`. The procedure then inserts a new record into the
database with the generated session key. It then creates a new cookie in
the response using the variable `COOKIE_NAME` which we will set to a
suitable value in the application.

The next procedure we'll write will be used to find the key associate
with the current request. It will first look for a cookie and try to
validate the session key in the database. If no key is found, it will
create a new session:

```python
def get_session(db):
    """Get the current session key if any, if not, return None"""

    key = request.get_cookie(COOKIE_NAME)

    cur = db.cursor()
    cur.execute("SELECT key FROM sessions WHERE key=?", (key,))

    row = cur.fetchone()
    if not row:
        # no existing session so we create a new one
        key = new_session(db)

    return key
  
```

Here we use the `COOKIE_NAME` variable again to make sure that we're
looking for the same cookie that we sent back. We get the cookie from
the request and then check that we can find this value in the sessions
table. If it isn't found we make a new one and finally return the
session key.

The third job is to modify the code that stores and retrieves likes to
add the session key associated with the value. This involves adding the
session key as a parameter to these functions and modifying the SQL
query to restrict the rows we retrieve to those that contain the session
key:

```python
def store_like(db, key, like):
    """Store a new like in the database associated with this session key"""

    cursor = db.cursor()
    cursor.execute("INSERT INTO likes (thing, key) VALUES (?, ?)", (like, key))
    db.commit()

def get_likes(db, key):
   """Return a list of likes from the database for this key"""

   cursor = db.cursor()
   cursor.execute("SELECT thing FROM likes WHERE key=?", (key,))
   result = []
   for row in cursor:
       result.append(row[0])
   return result
  
```

Having written the helper procedures, we can now modify the application
code to make use of them. To generate the home page the code is the same
as in the earlier example but we add a call to `get_session` to get the
current (or new) session key. This is then passed to `get_likes` to
restrict the likes that we retrieve.

```python
@app.route('/')
def index():
    """Home page"""

    db = COMP249Db()

    key = get_session(db)

    info = dict()
    info['title'] = 'Welcome Home!'
    # get the list of likes from the database
    info['likes'] = get_likes(db, key)

    return template('dblikes.tpl', info)
  
```

The code to handle the form submission also has a minor change to add in
the call to `get_session`:

```python
@app.post('/likes')
def like():
    """Process like form post request"""

    # get the form field
    likes = request.forms.get('likes')

    key = get_session(db)

    if likes:
        store_like(db, key, likes)

    response.set_header('Location', '/')
    response.status = 303

    return 'Redirect to /'
  
```

This is then the complete application that makes use of a session table.
If you run this it should send you a cookie with a new key the first
time you access the site (check the request headers in your browser
developer tools). If you then submit some values via the form, they
should be stored in the database and listed in the resulting pages. To
check that the sessions are working, start up another web browser (or
delete cookies from the domain with your developer tools) and you should
see an empty list of likes again.

Make sure you understand how this application is working. This is a key
method of session management on the web and is the core of any
application that allows long-lived sessions with a user.

This example shows the use of a database to store user information under
a session key which identifies the user only by a random string. This
technique can be used to store any amount of information about the user
from the contents of a shopping cart to display preferences or a page
click history. A variation on this technique is implemented by most web
development frameworks in use today.

### Exercises

1.  The application doesn't provide any way to reset the list or end
    the session. You could implement this by removing the session key
    from the sessions table and any likes from the likes table.
    Implement an option "Forget Me" as a POST request to the URL
    `/forget` and include a button in your page template to
    trigger this.


Supporting Login
----------------

In the example above, the user session was initiated as soon as the user
first visited the site, and the session table was used to keep track of
anonymous user data. Another important use of a session table is to
track logged in users and the differences with the methods described
above are quite small.

To keep track of a login session, the session is not created until a
valid username/password pair has been submitted by the user. A user
table is needed in the database to store this and whatever other user
data is required by the application. The session key and cookie are
created in the same way as described above and the cookie is returned to
the user in the same way.

The main job of the session table is used to translate between the
session key and the user identity. The session table stores the username
as part of the session data so that when a valid cookie is received, the
application can identify the logged in user.

An important requirement for authenticated sessions is the ability to
close the session either when the user logs out or after a pre-defined
time period. Since the cookie value that identifies the user could be
exposed in some circumstances (eg. on a shared computer) it is important
that it doesn't have an indefinite life. The procedure to logout a user
involves invalidating the session by removing the row from the sessions
table. In this way, if an old session key does arrive in a cookie, the
application won't recognise it and the user will be forced to login once
again.

See [the chapter on authentication](../web/authentication.md) for
further discussion of user authentication issues in web applications.

<div class="section exercises">

### Exercises

1.  Extend the example above to support authenticated sessions by
    requiring a username and password to be submitted before generating
    the session.
2.  Implement the logout functionality that removes a session from the
    session table.

