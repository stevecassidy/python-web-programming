# Web Security

In the modern web environment, we must assume that any service or
resource that is made available on the web will be subject to attack by
malicious people. Any web server will be tested for weaknesses, any web
application will have a range of attempts at getting past security and
any data that we store will be the target of someone trying to find
interesting or valuable information. 

What is more, the people doing the
attacking are clever and well funded - often cleverer and better funded
than the people writing and maintaining the web applications. 

As web
developers we need to be aware of the vulnerabilities that make our
applications and servers susceptible to attack. We need to use tools and
learn coding techniques to help prevent at least those exploits that are
well understood. We need to understand how vulnerabilities come about so
that we have a chance of seeing what the next wave of attacks might
target.

A web server is a computer connected to the Internet that is running
software to interpret HTTP requests and generate responses. Any computer
connected to the Internet is a target for attack since it might hold
interesting or valuable information or it might provide a gateway to
other computers that hold interesting or valuable information. If you
are running a web server, you need to be aware of how your system might
be attacked and what the appropriate responses are.

In a sense, all vulnerabilities for web applications come under this
banner of Server Security. However it is useful to discuss problems with
web applications separately since this is what affects the code that you
write. The problems discussed here are in system and server software
that you will probably install from third parties - or which might be
run for you by your service provider.

## Attack Vectors - Open Channels

Any attack on a server must happen over some kind of communication
channel. The easiest way to secure a server would be to disconnect it
from the network, however this makes it a lot less useful. A web server
will have at least one open Internet port - usually port 80 - and will
have software listening for requests on that port. Quite often, the same
server has other open ports for other services; for example, ftp for
file upload, smtp for mail transfer, ssh for secure communication. Each
of these open ports presents a possible security risk, a means by which
an attacker could try to gain access to the server.

Each open port that provides a service has a piece of software running
on the server listening for requests and handling communications. For
the web server this is HTTP traffic on port 80, for mail, there might be
an SMTP server running on port 25 and so on. Each of these pieces of
software accepts requests and processes them in some way and they all
have some kind of access to the local machine, for example to read and
write files, access a database or run jobs that take up CPU time. It is
these programs that provide the way in for an attacker.

Since running software listening to open ports on our server makes it
vulnerable it makes sense that we should run as few of these as is
necessary. This means that if we don't need a mail service we shouldn't
run the SMTP server etc. This might sound obvious but until recently,
computers would come configured with many services running by default
making them very vulnerable. Common practice now is that the default
installation of an operating system has only the minimum services
exposed and the system administrator needs to explicitly install and
enable any further services. Note that this goes for desktop computers
too if they are directly connected to the Internet.

## Vulnerabilities

Once there is an open channel of communication with the server, we still
need something to go wrong before an attacker can gain some kind of
access to the system. In the normal course of events, the SMTP server
does its job, transferring mail to clients elsewhere on the Internet. To
gain access to the system, an attacker must take advantage of a bug in
this software that allows them to do something outside of its design
parameters.

All server software receives input from the internet and processes it in
some way. This leads to the source of all vulnerabilities which must
stem from some property of that input that is outside of the
expectations of the programmer.

### Denial of Service

A very simple kind of attack is a Denial of Service (DOS) attack where
the aim is to overload the server so that legitimate clients can't make
use of it. There are many ways to achieve this but a common approach is
to flood the server with input so that it either blocks the network due
to too much traffic or keeps the server so busy processing requests that
it can't keep up with the flow. For example, we could send thousands of
large email messages to an SMTP server in very quick succession, this
might fill up the available temporary storage on the server or force the
server to spend lots of time parsing and processing each message.
Another kind of DOS attack is to try to crash the server software, for
example by sending input that is badly formed. It could be, for example,
that if the SMTP server gets binary data when it is expecting text, it
will crash rendering the server unusable.

### Buffer Overflow

Another common kind of attack is a Buffer Overflow attack. In this case,
the server software has been written to use a fixed size buffer to
process input; for example, it has set aside an array of 100 characters
to receive the email address of a message recipient. In a language like
C or C++, it has been common to allocate such fixed-size arrays in code
directly and the result is that the storage for the email address sits
next to the storage used for the program code. Another way to allocate
space, which can be used in C/C++ and is always used in Java and C\#, is
to make space in a different area of memory (called the *heap*), away
from program code. The problem arises when the software reads in data
from the input and stores it in this buffer. If the size of the input
isn't checked it is possible for the input to *overflow* the size of the
buffer that was allocated. If the buffer is located in the same place as
program code, the overflow bytes are written on top of the program code.
In this way, the attacker is able to send input containing program code
(which has to be machine code for the computer the software is running
on) which is written into the running program and which may then be
executed. Once the attacker can get their own code executed, they can
start to take advantage of the server and find a way to get themselves
in or get data out of the system.

An early example of a buffer overflow attack was the [Morris
Worm](http://www.snowplow.org/tom/worm/worm.html) which was perhaps the
first major Internet security breach back in 1988. The Worm was a piece
of self-replicating code which would send a copy of itself to any
computer it could gain access to. One of the ways that it [propogated
itself](http://www.snowplow.org/tom/worm/finger.html) was via a network
service called *fingerd* which was used to find out information about
users on other systems. The fingerd server was a simple application that
listened for requests and processed them but it was written with a fixed
size buffer of 512 bytes and the program used the `gets` system call to
read input without checking the size. The worm would send 536
characters, the last 24 of which would be instructions for the remote
computer that allowed it to run an arbitrary script. Once it had this
access it would upload a copy of itself to the remote machine and the
cycle was repeated. The Morris Worm quickly brought the Internet to a
crawl because it kept re-infecting the same machines and overloading the
processor. It was therefore a kind of *Denial of Service* attack that
was perpetrated via a *Buffer Overflow* vulnerability.

The buffer overflow attack allows code to be executed on the target
machine but there are other ways to achieve this. For example, if the
attacker can get an application installed on the server that seems to do
something useful but in fact serves to provide access for them (a Trojan
Horse). Once the attacker can run code on the server, they can start to
look for something to do. One target might be the passwords of
legitimate users, another might be to launch an attack on another
system.

## Application Security

Of course, the most obvious channel is the one we use to serve
web applications. All web servers must listen for requests and it is
via this route that most attacks are sent these days.  These
are attacks either on the HTTP server itself or, more commonly, on web
applications that are processing the requests.  

Web applications are written in many languages, Python, Java, Javascript,
and accept input from HTTP requests, generating HTML, JSON or other
content in response.  These applications are subject to attack and can
prove to be vulnerable.

### Injection Attacks

An injection attack is one where the attacker tries to insert executable
content into the input of a web application such that it will be
run on a target system.   The two main examples are **SQL Injection** 
and **Cross Site Scripting**.  The latter is covered in the chapter
on [Front-end Security](frontend.md).

An SQL injection attack will work on a web application that uses an
SQL database for data storage and creates queries for that database
based on user input.  For example, to find the details of a person
given their last name we might have a query like:

```SQL
select * from people where last='Cassidy'    
```

The application might substitute input from the user in the last part
of the query (instead of `'Cassidy'`).  Depending on how this is done,
 it could lead to problems.

In the above
example all is well but if the last name of the person was `"D'Arcy"` then
the query we would construct would be:

```SQL
select * from people where last='D'Arcy'
```

which is badly formed because of the extra single quote. This might cause
the application to crash.  

Even worse, if a malicious user senta last name of 
`"x'; delete from people where 'a'='a"` the query would be:

```SQL
select * from people where last='x'; delete from people where 'a'='a'
```

which would delete every row from your database. This is the basis of
the so-called SQL Injection attack that is a very common exploit on the
web.

To resolve this, the programmer needs to make sure that any value
that is inserted into a query does not contain special characters
like `'`.  Most programming interfaces to databases provide very easy
ways to manage this and so there should never be a reason to write
an application vulnerable to this kind of attack. For example, in
a Node server application using the SQLite database via the
[sqlite3](https://www.npmjs.com/package/sqlite3/) package, we would write the following:

```Javascript
  const result = await db.get(
    'SELECT * FROM people WHERE last=?',
    lastname);
```

Here, the question mark is a placeholder in the query and the database
interface will insert the value of `lastname` in an appropriate way
to make sure that the query is safe.   As long as this pattern is
followed, the application is protected from SQL injection.
