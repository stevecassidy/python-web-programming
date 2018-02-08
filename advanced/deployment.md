

Deploying Web Applications
==========================

Once you've written your next-big-thing web application you need to
deploy it to the web so that the waiting hoards of users can get access
and start earning you money. This chapter looks at the things you'll
need to do to deploy a Python based web application and some of the
issues related to scaling to larger numbers of users when you get
successful.



Hosting Services
----------------

The first requirement for deploying a web application is a server
connected to the internet that can run the different components of your
application. Web hosting providers have developed a number of products
that can fulfil this need from fully dedicated rack-space hosting of
your own server to a shared allocation within an application hosting
environment.

The obvious thing to do to host an application is to buy a computer and
connect it to the internet. Most home ISP terms of service forbid
running servers from home and so the solution is to house your machine
with a service provider. Many of these will offer pre-packaged servers
in their shared machine room that you can buy or rent for your exclusive
use. The advantage of this is that you get to choose all the options for
how your server will run and manage the whole thing yourself; but these
can also be the disadvantages since this adds significant work to the
job of running a web application. This is also often the most expensive
options since it takes up physical space in the machine room that can't
be shared with anyone else. For some applications (and people) this is
still the right thing to do but increasingly the majority of web
applications are being hosted in some kind of shared hosting
environment.

A shared hosting environment offers to run your web application on a
server that might also be running applications for other people. You
will usually get an allocation of memory, disk space and CPU usage that
your application can use as well as for the network bandwidth that you
use per month. Hosting providers will support different environments, so
you need to find one that supports eg. Python and WSGI based
applications. The provider will often give you a number of databases as
part of a subscription and these can be used to support your
application. The major advantage of this arrangement is that it is low
cost and you don't need to do anything about configuring or maintaining
the hosting environment.

The third family of providers take a more fine-grained approach,
offering specific hosting for e.g. Python WSGI based applications. This
is often called Platform as a Service (PAAS). One example in this space
is [Google AppEngine](https://developers.google.com/appengine/) which
supports applications written in Python, Java or PHP or
[Gondor](https://gondor.io/) wihc supports Python only. These services
host your application directly and often provide services like data
storage via their own APIs; for example, Google AppEngine supports a
NoSQL database via its own Object Relational Mapping module. These
services provide no control whatsoever over the execution environment
but are highly tuned to running this kind of web application. They can
be an excellent choice for deploying small boutique web applications
since the overhead in setting them up can be very small. In some cases
they can also scale very well so that when your application becomes
popular, the resources are there to support the larger user based that
you have developed.





Web Servers
-----------

The main requirement for deploying an application is a web server that
will listen for HTTP requests and forward them to your WSGI based
application. During development we used the [Python
webserver](http://docs.python.org/2/library/wsgiref.html#module-wsgiref.simple_server)
provided by the `wsgiref` module. This server did the job of listening
for HTTP requests, building the WSGI `environ` dictionary and calling
our application, then returning the headers and content back to the
client when our application procedure returns. This simple web server
could be used in production, however it is not really suitable as it is
not designed to cope with large numbers of requests arriving in quick
succession.

A production web server must be able to serve a large number of requests
arriving at a very fast rate. Obviously the volume of traffic will
depend on the popularity of the site, but you should plan for when this
happens rather than assuming there won't be much traffic for a while.

To make our WSGI based web application available we need a web server
that can understand the WSGI protocol and call our application with the
right input. Many web servers are able to do this either natively or via
a plugin module. If this is not available, there are adaptors that can
run WSGI applications via other protocols such as CGI (Common Gateway
Interface), FastCGI or SCGI. The general configuration to enable this is
to associate a URL prefix with a particular WSGI application defined in
a Python module. Other configuration such as setting up Python paths and
modules might also be needed.

### Apache

The most common web server is [Apache](http://httpd.apache.org/), an
Open Source product that has been around since the very early days of
the web. It is popular because it is free and included as a standard
component in many server environemnts. It works and is reliable and
fast. As a web developer, you should get to know how to [configure
Apache](http://httpd.apache.org/docs/2.4/) because you will probably be
doing it a lot in the years to come.

To handle large amounts of traffic, Apache uses either multiple
*threads* or *processes* for handling each request. The basic idea is
that each request is sent to a thread or process so that it can run
independantly of any others that arrive. A main supervisor
process/thread listens for HTTP requests and then sends the work to a
subprocess/thread to generate the response.

Apache has a large number of [plugin
modules](http://httpd.apache.org/docs/2.4/mod/) that extend its
functionality. For example, there are modules for authentication,
caching, running PHP, Python and Perl applications etc. Many of these
are distributed as standard and many more are available from third
parties. The ubiquitous nature of Apache means that many new server side
web technologies are made available first as Apache modules.

To run WSGI applications via apache there are a number of options, the
most common would be the [mod\_wsgi](https://code.google.com/p/modwsgi/)
module which extends the server to understand the WSGI protocol.
mod\_wsgi can run Python scripts either as part of the Apache process
itself or by running the application as a separate process. Both options
have their strengths in different contexts.

The main criticism of Apache is that it is big and has too many
configuration and plugin options. These can certainly be confusing when
all you want is a simple fast web server. Building Apache from source is
confusing because you need to make sure you have the right options
turned on etc. Configuring Apache can be confusing because of all of the
different options available. The process/thread based model for dealing
with large amounts of traffic is also less efficient for some tasks than
a number of the newer web servers (below).

### Asynchronous Web Servers

[Nginx](http://nginx.org/) (prodounced 'engine X') is a lightweight web
server with fewer configuration options than Apache that is optimised
for handling large volumes of traffic. In particular it is used for
serving static content, as opposed to content generated by server side
scripts. Nginx is often used as a reverse proxy where it acts as the
front end accepting HTTP requests and the forwarding them on to another
server like Apache that deals with the request. This configuration
allows Nginx to be used for serving static content while Apache deals
with generated content from things like our Python WSGI script. The
disconnect between the network and the Apache processes turns out to
give a big performance win for high traffic sites.

The model used by Nginx to process many requests is an *event driven*
model rather than a process based model. This means that the server uses
operating system level event handling and asynchronous input/output
facilities to be able to handle requests quickly. The consequence of
this is that the memory use is much lower for Nginx than it would be for
Apache given a large number of requests per second. This is because for
each request, Apache must allocate a new thread or process which must
contain a copy of the execution context. Nginx can just handle the
request in an existing thread and move on. This model wouldn't work if
processing each request took a long time since one request would block
all of the others; hence slower page-generation code (like our Python
application) is usually done in another process (eg. via an Apache
server) leaving Nginx to do what it does best.

[Lighttpd](http://www.lighttpd.net/) (pronounced 'lighty') is another
lightweight, asynchronous web server very similar to Nginx in many ways.
Whereas nginx started life as a load balancing proxy and only later
became a full web server, lighttpd was designed as a web server from the
start. The performance of the two servers is similar. Lighttpd is
perhaps a little easier to configure and comes with support for FastCGI
based applications out of the box - this can be used to run our WSGI
based Python applications.

### FastCGI

As mentioned above, it is common to run slower web application scripts
in a separate process so as not to slow down the main HTTP server
process. One common way to do this is via the FastCGI protocol. This
protocol is just a way for a web server to forward requests to a server
side application, similar to the way that our Python server called our
WSGI application procedure. FastCGI is language neutral though, but
sends more or less the same information as is contained in the `environ`
dictionary passed to a WSGI procedure.

The FastCGI protocol requires that there is another process running on
the server that is able to respond to requests sent by the HTTP server.
This is like having another web server that listens only to the main
server, but the protocol used isn't HTTP, it's FastCGI (we don't need to
know the details). The FastCGI process would be written in Python using
a module such as [flup](https://pypi.python.org/pypi/flup) and might use
multiple threads or processes to cope with large numbers of requests per
second.

There is a useful guide to [deploying a WSGI application via
FastCGI](http://flask.pocoo.org/docs/deploying/fastcgi/) on the Flask
website (Flask is a Python web framework).

### WSGI Based Servers

There are a small number of [web servers that support WSGI
natively](http://wsgi.readthedocs.org/en/latest/servers.html) they are
designed specifically for running Python based web applications. The
server we use for development from the
[wsgiref](http://docs.python.org/py3k/library/wsgiref.html) module is
one example, but that is not suitable for a production deployment.
Perhaps the most well known production WSGI server is
[Gnuicorn](http://gunicorn.org/); while Gnuicorn could be used as a
sandalone web server, the documentation recommends that it is placed
behind a reverse proxy such as Nginx.





Databases
---------

SQLite is a fully featured implementation of an SQL database system that
is lightweight and runs without requiring installation of a large
software system. As such it is ideal for development of web applications
because we can work with it on a laptop in a development environment.
However, SQLite isn't designed as a production database engine, the most
common mode of use is as a single-user embedded database. In a
production environment, we need to be able to process many simultaneus
requests that might query and update the database at the same time. We
need guarantees of consistency of data and we need to be able to scale
the size of data stored to be very large if our application is
successful.

There are a number of production relational database systems and this is
a very old and well established market so their capabilities are well
known in the IT industry. This means that when looking for web hosting
providers, you will find standard database servers as part of the
offering and these can be expected to run efficiently and scale to
whatever size of data you are willing to pay for. The most common Open
Source choices are [MySQL](http://www.mysql.com/) (actually owned by
Oracle these days) and [PostgreSQL](http://www.postgresql.org/). In the
commercial space you will probably choose between
[Oracle](http://www.oracle.com/) and [Microsoft SQL
Server](http://www.microsoft.com/en-us/sqlserver/default.aspx). Each of
these has strengths and weaknesses but to a first approximation they
will all be capable of providing a reliable data store for a web
application.

When writing our WSGI application we used the `sqlite3` module as the
interface between our code and the relational database. If you were to
want to deploy your application on a MySQL or Oracle server, this code
wouldn't work. Fortunately, the SQLite interface provided by the
`sqlite3` module conforms to the Python
[DB-API](http://www.python.org/dev/peps/pep-0249/) standard which is
also implemented by other modules that interface to other database
systems. In most cases, the only change you need to make to your code is
when the database connection is created. So, for example, to connect to
a MySQL database using the
[mysql-python](http://mysql-python.sourceforge.net/) module you would
write:

```python
db=_mysql.connect(host="localhost",user="joebob",
                  passwd="moonpie",db="thangs")
    
```

Note that compared with creating a connection to an SQLite database we
need to provide a little more information. A MySQL database might run on
a different server (hence the host name) and will require a username and
password. Once this connection is made however, it can be used to create
cursors and execute queries in the same way as with SQLite. In some
cases, the variant of the SQL language understood by the database system
is different to that used by SQLite. This means that you might need to
manage two variants of a query - one for development with SQLite and one
for production with MySQL. Usually by the time you get queries as
complex as this you've moved to a higher level of abstraction using a
database Object Relational Model package such as SQLAlchemy. In this
case, the interface module will take care of the database differences
for you and you can go back to worrying about the right way to model
your data.

### Non-SQL Data Stores

A very recent development is a number of alternatives to the traditional
SQL relational database, often grouped together as
[NoSQL](http://nosql-database.org/) databases. These are special purpose
data stores that are optimised for particular tasks or kinds of data.
The general idea is that rather than the general purpose relational
model, these stores provide a simpler data model that is useful for a
particular task and can be implemented very efficiently. In some cases
these are being developed to serve parts of the data storage needs of
web applications.

Perhaps the simplest of these databases are the key-value stores that
provide a very large and fast version of the Python dictionary data
structure - associating unique *keys* with arbitary data items. One
example of this kind of product is [Redis](http://redis.io/) which
implements an in-memory key-value store that provides very fast access
to data via keys. If you are building something like a cache which
stores web page contents for a given URL then something like Redis will
provide a very fast store without the overhead of relational tables or
complex query processing.

Another family of databases are the document stores that store whole
documents again using a key to identify them, but also supporting query
via the *content* of the document. An example of this kind of store is
[CouchDB](http://couchdb.apache.org/) which presents itself as *"a
database for the web"* that *"uses JSON for documents, JavaScript for
MapReduce queries, and regular HTTP for an API"*. CouchDB stores JSON
documents but other products are tuned for storing larger traditional
PDF or Word documents and support queries over these via an API. These
products can be ideal if you have a document oriented web application,
eg. something like [Evernote](https://evernote.com/) that stores notes
written by users.

Other kinds of NoSQL database include those that are tuned to store
particular data structures. So, there are graph data stores that provide
optimised access to graph based data structures such as the network of
relations between people in the [Facebook Social
Graph](https://www.facebook.com/about/graphsearch). Another family is
the Object Store which stores object based data structures directly;
these are less widely used perhaps because the Object Relational Mapping
libraries available for various languages provide just the right
abstraction over traditional relational databases for these to offer any
advantage.

In summary there are now a number of competing data models in the kind
of data store that we might use for a web application. The default
position is still a traditional relational database but these other
options are starting to be attractive for some parts of an application
and are worth knowing about.





User Management
---------------

It is increasingly common to see the option to login to a web
application with your Facebook or Google account credentials either as
the only option or as an alternative to a login for that particular
site. This has the advantage for the user that they only need to
remember one username and password to access many services. For the
developer, the advantages can be much greater.

The primary advantage to using an authentication service like Facebook
or Google is that you may not need to manage user data yourself. This
then means that you can have as many users as you want without any more
overhead in storing user details and with no risk (to yourself) of
private information being leaked. The disadvantage here is that you
might not know as much about your users. A more common case is that you
allow people to *authenticate* via one of these services but still
create a local account for them so that you can store preferences etc.
This means that you will need to store information about users in your
database but that you don't need to manage usernames and passwords or
provide support to users who have lost their password (password resets
make up [20-30% of all help desk
calls](http://www.gartner.com/newsroom/id/1426813)).

Further advantages of using third party authentication come from being
able to leverage the services provided by the third party provide. This
might include embedding lists of friends in your pages from Facebook to
linking to other personalised services from Google or Facebook etc. Some
of these things can be done without using these services for
authentication but much more is possible if you know who the user is.





Content Delivery Networks
-------------------------

A significant problem for a large scale web appliation is that of
providing content to users spread around the globe as fast as possible.
If I choose to host my application in Australia, that might provide good
service to Australian users but is likely to be slower for US and
European users than it might be. If I host in the US then I risk
providing a slower service for Australian users. One solution to this
problem is the Content Delivery Network (CDN) which provides a
distributed delivery service with servers spread around the world
providing content to users nearby.

The CDN is basically a kind of distributed cache which sits between your
web application and users. It is typically configured to work with only
the static parts of your content but could also cache generated pages if
they changed infrequently. While a normal cache runs on a single server
machine, the CDN has a network of servers around the world which
duplicate your content at each site. A central server receives each
request and routes it to the server closest to the client for delivery.
This has two effects: your content is delivered by the CDN so it will
place no load on your server; and the content will be delivered from
somewhere close to the client giving them a faster page-load response.

There is a good discussion of the technical background to CDNs on [the
Wikipedia page](https://en.wikipedia.org/wiki/Content_delivery_network)
which includes links to some notable examples of this kind of service.





[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
