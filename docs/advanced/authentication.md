# Authentication for Web Applications


Authentication is a common requirement for web applications, we want to
know who is making requests and so that we can manage multi-stage
transactions and protect confidential or private information. The HTTP
protocol includes some provision for authentication but in modern
applications this is not often used; it is more common to use
application level authentication combined with HTTP cookies to identify
users. More recently, we've seen the rise of federated identity
management with services like Facebook and Google offering to manage
user identities for web appliciations. This chapter will review the
different methods that are available for authentication in web
applications.

## HTTP Authentication

The HTTP protocol provides two mechanisms for authentication: Basic and
Digest authentication. To trigger authentication, the server returns a
response code `401 Unauthorized` along with a `WWW-Authenticate` header
that provides details of the kind of authentication that is required.
The two options here are to ask for
[Basic](http://en.wikipedia.org/wiki/Basic_access_authentication) or
[Digest](http://en.wikipedia.org/wiki/Digest_access_authentication)
authentication. The browser will respond in either case by prompting the
user for a username and password which are then encoded in the header
and returned to the server in a new request for the same resource.

### Basic Authentication

Basic authentication is the simplest and least secure of the two
methods. The username and password are encoded with the Base64 algorithm
and sent back in an `Authorization` header with the new request. Base64
makes the username and password unreadable but it can be trivially
decoded, so the password is really being sent un-encrypted over the HTTP
connection. Anyone able to listen in on the request (eg. a proxy server
between the client and server) will be able to see the username and
password and could make use of it themselves. For this reason, Basic
authentication should really only be used over a secure (HTTPS)
connection. In practice it is often used to provide a low level of
protection for resources because it is easy to configure to password
protect a directory of files in a web server like Apache.

Here's an example HTTP conversation:

```HTTP
GET / HTTP/1.1
Host: example.org
```

The server responds with a 401 code and requests authentication, the
*realm* is used to indicate to the user what they are providing a
password for.

```HTTP
HTTP/1.1 401 Authorization Required
WWW-Authenticate: Basic realm="Secure Area"
Content-Type: text/html
Content-Length: 311
```

The user is prompted for a username and password and the browser then
re-sends the original request with a new *Authorization* header
containing the Base64 encoded username and password:

```HTTP
GET / HTTP/1.1
Host: example.org
Authorization: Basic c3RldmU6c2VjcmV0
```

The server will now respond with the resource as with a normal HTTP
request. Note that from now on (until the browser session closes) the
Authorization header will be sent back to the server with every request,
so the user only needs to provide a username and password once. There is
no provision for logging out using this mechanism.

Basic authentication can also be used without


### Digest Authentication

Basic authentication is not secure unless we are able to use an
encrypted (HTTPS) channel to send HTTP requests. HTTP provides a more
secure authentication mechanism that is safe to use over plain HTTP
channels since it never sends the plaintext password. This is *Digest
Authentication*.

This form of authentication is initiated in the same way (with a 401
response) but this time, the browser is asked to use digest
authentication and is given a *nonce* value - a unique string that will
be used as part of the conversation with the server. Instead of sending
back the username and password, the client browser generates a one-way
hash (using the md5 algorithm) based on the username, password, nonce
value and the request being sent. This is sent as part of the next
request along with the username. Since the browser has the same
information as the client, it can compute the same one-way hash and
compare the value it receives. If they are the same, then the user
checks out and the response can be returned.

The details of the algorithm used to generate the hash that is returned
is detailed in the Wikipedia page on 
[Digest Authentication](https://en.wikipedia.org/wiki/Digest_access_authentication). 
The
take-home message is that the hash value encodes information known only
to the client (username, password, request URL) and server (nonce) and
that this information is sent in encrypted form. Because it contains
information about the requested URL, the value can't be used by an
attacker in a different request.

Like Basic Authentication, Digest does not provide a mechanism for
logout so the session lasts until the browser is closed. The browser
uses the same nonce value for every request - the nonce is only sent in
the first 401 response.

### Implementation

The most common implementation of both Basic and Digest authentication
is that is managed by the server. The server is configured to require a
password for a given resource or collection of resources and intercepts
any requests, requiring authentication before allowing access. The
server takes charge of managing usernames and passwords on behalf of the
application. While this is the most common approach, it is of course
possible to manage HTTP based authentication within an application;
there are a number of WSGI middleware packages that will provide this
implementation.

## Application Based Authentication

The most common approach to authentication in a web application is to
manage it at the application level. This means that the application
manages usernames and passwords in a database and decides when it needs
to prompt for a login.

In this approach to authentication, the application must take care of
managing all information about users, checking their passwords and
maintaining session information. The main problem to solve is to
maintain the session state between different HTTP requests. Since HTTP
is a *stateless protocol*, every request is independent of the last and
no identifying information is included in the request by default. The
methods described above provide one mechanism for sending authentication
information with each request, but as mentioned above, they don't
provide a mechanism for logout and are generally managed by the server
rather than the application. The method we describe here makes use of
[cookies](../security/cookies.md) to maintain state between requests.

It is common for a web application to present a login form that asks for
a username and password from the user. This form is submitted to the
application as a POST request to a URL like `/login` where user
authentication is handled. To respond to this request, the application
must first check that the username and password correspond to the stored
details of a real user.

To verify the password of a user it should be a simple matter of
comparing the password that is sent in the POST form submission with the
password that is stored in the database for the username sent in the
form. The naive implementation of this method would just store the
password in the database; however, this is a significant security
vulnerability. If an attacker were able to gain access to the database
of the application, they would have easy access to all passwords for all
users. Since many people use the same password on multiple accounts, the
attacker might now be able to access Facebook or even the bank account
of a user. Foro this reason, it is best practice not to store the raw
password of a user but to store a one-way hash derived from the
password. A one-way hash is a transformation of the input string that
generates a seemingly random string of characters; the algorithm used to
do this ensures that while it is easy to compute the hash from the
password, going the other way is close to impossible. Instead of
comparing the password with the stored password, we compare the hash of
the password with the stored hash. Should an attacker gain access to the
database, they will only have a list of hashes, not the raw passwords.

If an attacker gets access to the list of password hashes they can try
to discover the original passwords using a *brute force* attack if they
know the hash function that was used. Using a list of common words, they
generate the hash value and compare to each database entry. If a user
has used a common word (or combination) as their password then it will
be exposed. Since compute power is now readily available, attackers can
try not only common words but variations - pairs of words, words with
numbers added to the end etc. In order to make this harder, modern
systems use deliberately slow password hashing algorithms and run them a
number of times over the input string. The idea is to make sure that any
brute force attack takes a very long time to run. In Python you can use
the [hashlib](https://docs.python.org/3/library/hashlib.html) module
which has an implementation of the [PKCS\#5 password-based key
derivation function 2](https://docs.python.org/3/library/hashlib.html).
At the time of writing this is the recommended method of generating a
secure password hash.

Having compared the submitted and stored passwords, the application is
now sure that the login request is good and the user should be
authenticated. In order to keep track of future requests from the same
user, the application will return a *cookie* that will be used to
identify this user. The cookie value needs to be hard to guess and
assocate with a user - if we just used the username, anyone could
pretend to be that user. A common option is to use a [UUID (Universally
Unique Identifier)](https://docs.python.org/3.6/library/uuid.html) which
is a random string of characters; this is known as the *session key*. In
order to keep track of who this session key was sent to, the application
makes an entry in a session table as described in the [earlier
chapter](/bottle/sessions.md). Once the entry is recorded in the
session table, the cookie is returned to the user in the response.

Each time the user now re-visits the site, the cookie can be used to
look up the session key in the database and find out the username of the
authenticated user. The application can control how long a login session
is valid for by setting the expiration date on the cookie or by removing
the session table entry after a given amount of time. In this way a
highly sensitive site like a bank, can force login to last only a few
minutes while a less sensitive site (Facebook) can allow login to last
for months.

Logout is supported in this scenario by removing the entry from the
sesion table. Once the entry is removed, even if a valid cookie is
received, the session key will not be found in the database and so the
user will not be identified.

## Third Party Authentication

A recent development in web applications has been the provision of
authentication services by third parties. The idea here is that a new
web application would not manage its own user credentials, instead it
would defer to another web application which will check the username and
password and tell the client application about the user. There are
advantages for both the web application developer and the user in this
arrangement. The developer doesn't need to be concerned about managing
user details, in particular they don't need to worry about the security
of passwords since they don't store them. The user doesn't need to
remember yet another password, instead they have one central identity
that they can manage more easily.

There are two main standards for third party authentication.
[OpenID](http://openid.net/) is a widely used standard that allows for a
range of identity providers. [Shibboleth](http://shibboleth.net/) is
another standard that is mainly used in academic networks and
concentrates more on a trust network between identity providers.

### OpenID

With OpenID, the identity of a user is a web address (URL) that can be
used by a web application to validate the user's identity. The three
parties involved in the transaction are the user, the OpenID provider
and the relying party (the web application that will rely on the result
of the authorisation). The sequence of operations is (roughly) as
follows:

* The user provides a URL to the relying party as their identity, eg. 
  <http://openid.example.org/johnsmith>
* The relying party retrieves this URL to discover the OpenID
    providers URL. This will either be in a &lt;link&gt; tag in the HTML
    page or in a special XML document, depending on the version of the
    standard being used.
* The relying party makes a request to the OpenID provider and is
    given a *shared secret* that can be used later as part of the
    authentication process. This allows the relying party to know that
    later messages really do come from the OpenID provider.
* The relying party returns an HTTP redirect response to the user's
    browser so that they are redirected to the OpenID provider. The
    redirect includes some information about the relying party.
* The user is authenticated by the OpenID provider, usually this means
    they enter their password but there could be other methods. The
    OpenID provider then asks the user if they trust the relying party
    and want their details sent back to it.
* If the user agrees, they are redirected back to the relying party,
    the redirect includes information about the user and the shared
    secret that was established earlier so that the relying party knows
    that this is genuine.
* The relying party accepts the authentication of the user and allows
    them to view restricted content.

There are further options and complexities that I've glossed over here,
some more details are given in the Wikipedia [OpenID
page](http://en.wikipedia.org/wiki/OpenID) and in the [OpenID 2.0
Specification](http://openid.net/specs/openid-authentication-2_0.html).

The design of this protocol means that the end user is able to manage a
single identity and gets a more uniform experience when authenticating
with different web applications. The web application developer gets the
benefit of a large number of potential users who already have OpenID
identities and doesn't need to manage their credentials. OpenID is
implemented in a number of open source libraries for most of the common
web development languages and toolkits. The [Python
OpenID](http://pypi.python.org/pypi/python-openid/) module provides
support for running an OpenID identity provider and for consuming
OpenIDs as a relying party.

While you may not realise it, you probably already have an OpenID
identity by virtue of one of the major web applications that you have an
account on. The [Get an OpenID](http://openid.net/get-an-openid/) page
lists the major providers such as Google and Yahoo that provide an
OpenID endpoint. You can also establish an OpenID identity at a
dedicated provider such as [MyOpenID](https://www.myopenid.com/) or if
you have access to a server, run your own OpenID provider using
something like the Python OpenID module.

You might ask whether OpenID is in any way secure if anyone can set up
an OpenID provider and use it to log in to your site. The thing to
realise is that what you are getting with an OpenID identity is an
assurance only that you are talking to the person who owns that
identity. If that identity asserts that I am Britney Spears, you have no
way of knowing whether I'm the real Britney or not, in fact you should
assume that I'm not. All that OpenID does is remove the need for me to
store passwords and allow the user to have the same identity on
different websites.

There are a number of potential and actual security issues with OpenID
which come from the way that messages are exchanged between the relying
party and the identity provider. If these messages can be intercepted
there is a danger of someone assuming the identity of the user and doing
things on their behalf. New features have been added to version 2.0 of
the standard to counter some of these problems.

OpenID is a good way to provide an identity service for a web
application where all you need to know is the identity of the user,
rather than any authoritative information about them. The only thing you
can trust from OpenID is that this person is the same person you saw
last time with this identity. For many applications, that is enough and
so OpenID has distinct advantages. When you want to be able to trust the
identity more, or when you want to know more about the person, other
standards provide a better choice.

### OAuth - access to third party services

<http://softwareas.com/oauth-openid-youre-barking-up-the-wrong-tree-if-you-think-theyre-the-same-thing>

<https://developers.facebook.com/docs/guides/web/>

<https://developers.google.com/accounts/> OAuth - access to third party
services on behalf of a user (as well as authentication)
