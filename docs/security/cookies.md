# Cookies and User Tracking

HTTP is a *stateless protocol*, meaning that each request is separate and the
server does not need to keep track of users in order to respond to requests.
However, on the modern web, we often *want* to keep track of users and
associate a sequence of requests with a single transaction.  To achieve this,
the cookie mechanism is layered on top of HTTP to allow some state to be
maintained between requests.

However, since the early days of the introduction of cookies, the idea of tracking
users has become an industry in itself.  Knowledge of user's browsing habits
is a saleable commodity and companies like Facebook and Google make their money
by being able to customise advertising to the interests of users based on
knowledge of their browsing habits.  Tracking browsing habits is done using
cookies (and other mechanisms) and so there is concern that using them violates
user privacy.   Based on this, there are now limits on what can be done with
cookies.

This chapter will try to explain how cookies are used in general and then at the
specific case of user tracking across different sites.  We'll then look at how
modern web standards and browsers are getting in the way of simplistic tracking
and forcing companies to work harder to acquire user data. 

## Cookie Basics

Cookies are a mechanism for
maintaining state in an HTTP transaction. They allow a server side
application to store some data with the client which is returned each
time the client makes a request to the same server. 

Cookies are created when a server response includes a `Set-Cookie` header. When
this is received, the browser stores the cookie for future use, associating it
with the URL that the response came from.  Depending on the settings in the cookie,
it can be kept for the current browser session, for a period of time or
indefinitely.  

When a cookie has been stored for a given site URL, all subsequent requests to 
that site (subject to some controls) will contain a `Cookie` header that sends
the cookie back to the server.  In this way, the server can identify the user
based on the cookie contents or use those contents in some way as state information
in a transaction with that user.

Let's look at an example of both kinds of header. Here's a response from
a server that sets a cookie:

```HTTP
HTTP/1.0 200 OK
Date: Wed, 21 Mar 2012 03:18:25 GMT
Server: WSGIServer/0.1 Python/2.7.2+
content-type: text/html
Set-Cookie: likes=cheese
```

The last header like contains a cookie called 'likes' with a value
'cheese', the browser will by default store this locally and send it
back with any request to the same URL. Here is a request that includes
the same cookie:

```HTTP
GET / HTTP/1.1
Host: localhost:8000
Connection: keep-alive
User-Agent: Mozilla/5.0 (X11; Linux i686) AppleWebKit/535.11 (KHTML, like Gecko) Ubuntu/11.10 Chromium/17.0.963.56 Chrome/17.0.963.56 Safari/535.11
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Referer: http://localhost:8000/?like=cheese
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-GB,en-US;q=0.8,en;q=0.6
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
Cookie: likes=cheese
```

The cookie has two main parts, the name and the value.  The name should be 
alpha-numeric with no whitespace or special characters, it can include dash `-`
and underscore `_`.  The value should also be only alpha-numeric characters
without spaces, double quotes, commas, semi-colons or backslashes.   The value
can be up to 4096 bytes but much smaller values are most common.

## Cookie Parameters

While the name and value are the main parts of the cookie, there are also a number
of parameter settings that can be sent along with it in the `Set-Cookie` header. 

Here's an example of a cookie header with some additional parameters:

```HTTP
Set-Cookie: sessionID=2c014545; Secure; SameSite=None; Expires=Wed, 09 Jun 2021 10:18:14 GMT; Path=/;
```

Each parameter comes after the `name=value` part, separated by semicolons.  

### Domain and Path

By default, a cookie is sent back to the URL it came from and any 
URLs where that is a prefix.  So, if a cookie comes from `http://example.org/fruit/`
it would be sent back to `http://example.org/fruit/` and 
`http://example.org/fruit/apples/` but not to `http://example.org/vegetables/` or
to `http://www.example.org/fruit/`.  
The `Domain` parameter allows the server to dictate where the cookie will be
sent back to. So, `Domain=example.org` would mean that it would be sent to 
both `example.com` and any sub-domains such as `www.example.com`.   
The `Path` parameter allows the server to say which URL paths the cookie
should be sent back to; `Path=/` means that it will be sent to all paths
in this domain even if it originated at `/fruit/'.

However, a server is not allowed to include a different domain in a cookie
header.  If the server at `example.org` returned a cookie with `Domain=evil.org` 
then that will not result in the cookie being sent in future requests to `evil.org.
The cookie would be deemed invalid and ignored.

### Expires and Max Age

Cookies can be kept in the browser indefinitely or for a fixed period.  Two
properties define how long. `Expires=<date>` says that the cookie should be
kept until the given date (in UTC format
`<day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT`).
`Max-Age=<seconds>` says that it should be kept for the given number of seconds.

If neither of these headers is present, the cookie will be kept until the
end of the current browsing session.   This can be a long time if users don't shut
down their browser or if the 'session' is restarted by the browser when they
restart, which is common.

Different uses of cookies will make different choices here. For a secure banking
application, a very short-lived cookie would be used to maintain a login session
so that re-login will be required after a short period.  For a social media
application, a longer expiry would be set to make it more convenient to the
user and not require frequent logins.

### Secure and SameSite

If the `Secure` parameter is present, the cookie will only be returned in a request
if it goes over a secure `https` channel.

The `SameSite` parameter controls whether a cookie is sent when the request is
for a resource embedded in another page.  For example, a page at
`http://example.com/`  contains an image that is hosted at
`http://advertising.com/`; the request for the image returns a`Set-Cookie`
header so that the browser now holds a cookie for that site.   If the
page is requested again, the browser will look at the `SameSite` parameter
on the cookie to decide whether to return it with the request.

If `SameSite=Strict`, then the cookie will only be sent back for same-site
requests - that is if the user is visiting a page on `advertising.com`.  If
the request is for an image embedded in `example.com` the cookie will not be sent.
Even if the user clicks on a link in the page that sends them to `advertising.com`,
the cookie will not be sent with the request. 

If `SameSite=Lax` (which is the default if `SameSite` is not mentioned)
the only difference is the last case where
a user clicks on a link to navigate to another site.  In this case, the cookie
for the other site will be sent.

The final option is `SameSite=None` which means that the cookie will be sent
with any cross-site requests. However, this will only work if `Secure` is also
set, so this will only work over an `https` connection.  This option is needed
if you want to keep track of users across multiple sites (see below).

Some browsers (e.g. Firefox), block cookies with `SameSite=None` by default
(part of their [Advanced Tracking Protection](https://support.mozilla.org/en-US/kb/enhanced-tracking-protection-firefox-desktop)).

### HttpOnly

A cookie marked as `HttpOnly` is not accessible from Javascript code running
in the browser page.  Any other cookie can be read and modified by Javascript
code.

## User Tracking with Cookies

A very common use-case for cookies is tracking user browsing habits for
the purposes of building a profile.   This is done, for example, by advertising
companies like Google who's business is to serve advertising to any site on
the web.  Let's look at how this tracking takes place.

A website `https://example.com/` agrees to host advertising from `https://ad.com/`
in return for a fee per page view. To do so, an image is embedded in the
pages of `example.com` with the url `https://ad.com/banner.png`. 

```HTML
<img src='https://ad.com/banner.png' alt='advertising'>
```

When a user visits the `example.com` home page, the browser will send a request
to `ad.com` for the image.  The response contains a `Set-Cookie` header:

```HTTP
Set-Cookie: sessionid=k91j30d81ked; Path=/; Secure; SameSite=None; Expires=Wed, 09 Jun 2024 10:18:14 GMT;
```

As the user views the page on `example.com` they will see the persuasive advertising
image.  The `ad.com` server creates a database entry for user `k91j30d81ked` and
adds `https://example.com` to their browsing history.

The user browses to a new page `https://example.com/bears/` which also contains
an embedded advertising image from `ad.com`.  Since the `SameSite` parameter
is set to `None`, the browser will send the cookie along with the request and
so the server at `ad.com` will know that this is the same user as before and
can update the browsing history.

The server at `ad.com` can also keep track of how much it needs to pay `example.com`
by counting the number of requests it gets with a `Referrer` header of
`https://example.com`.  (Note that by default, the referrer header only shows
the top level address of the referring site, not the sub-page within it.)

Now, `ad.com` has also hosts advertising at another site, `http://bobalooba.com/`
which again embeds advertising images in its pages.   When a user who has
previously visited `example.com` visits a page on `bobalooba.com`, their browser
will request the advertising image and send along the cookie.   The `ad.com` server
again adds to the user's browsing history and no knows that this user,
anonymously identified by their session id, is interested in the content on
both of these sites.  

If `ad.com` can sell advertising services to many sites, they can build up a
profile of each user's interests and start to serve custom advertising to
them.   If user `k91j30d81ked` tends to browse sites about cycling, they can
be served ads from cycling suppliers.  This is how the business of modern
web advertising is built.

Of course, this same pattern can serve more than advertising.  Being able
to learn about the profile of a user is valuable to many groups and there
have been many instances of abuse of this information for various reasons.
For this reason, cookie tracking is viewed suspiciously.  Regulations in the
EU mean that any website serving European users must ask for permission
to use cookies (even first-party cookies) - which is why we often see the
cookie permission pop-up when first visiting a site.  

Some web browsers, notably Firefox, have a default setting that blocks third
party cookies like these.  This prevents advertisers tracking the user's browsing
behaviour and disrupts the advertising model.  To get around this, advertising
companies can use alternate methods of tracking users.

## User Tracking without Cookies

Since user-tracking data is so valuable, the companies that collect it have found
alternate ways to track users that don't use cookies which can be easily disabled.
This is a bit of an arms race so enumerating all of the ways that it can happen
is never going to be exhaustive. Here are some alternate methods that have been used.

### ETag Header

The [ETag Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag)
is part of the HTTP specification used for cache validation.
The value supplied in an ETag header is a unique identifier for a particular
version of a resource.  If that resource changes (a page is updated), then
the generated ETag value would be different.  If a browser has a version of a
resource in its local cache, it will send the ETag of that version along with
an HTTP request (as the `If-None-Match` header).  If the version
is unchanged, the server will respond with
a 304 Not Modified response, meaning that the browser should use the version
it already has.

Since the ETag will be sent back to the server with subsequent requests, it can
be used to track users.   The tracking server simply sends a unique ETag per
user with a given resource (maybe a javascript file or stylesheet).  When the
user sends a subsequent request for that resource, it sends the ETag which
allows the site to track the user.

A user can clear any ETag trackers by clearing the browser cache.

### Browser Cache

The browser will store copies of recently accessed resources in a cache to make
future requests for the same pages faster.  A server can send a version
of a Javascript file containing a unique identifier for a user:

```Javascript
...
sessionid='k91j30d81ked';
...
```

this file will be cached and re-used whenever it is referenced again in another
page.   The tracker can then send this value along with requests for
resources like advertising images, eg. by appending the value to the
end of the image URL.  In this way, the user can be tracked without
the use of a cookie.

Again, these trackers could be removed by clearing the browser cache.

### Browser Fingerprinting

A final example is the use of 
[browser fingerprinting](https://en.wikipedia.org/wiki/Device_fingerprint).
Here, the tracker
uses Javascript code to probe for features in the user's browser. For example,
the operating system, browser version, collection of plugins installed.  If 
enough features can be collected, there is a very low probability of it being
exactly the same as another user. Hence, the user can be tracked by reference
to this browser signature.

It is very difficult to protect against browser fingerprinting as a tracking 
measure.
