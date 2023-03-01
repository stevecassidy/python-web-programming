# The HTTP Protocol

![comic about web servers](http://imgs.xkcd.com/comics/server_attention_span.png)

[Server Attention Span by xkcd](http://xkcd.com/869/)

- Requires: a connection between client and server
- Stateless: no login process, each request is independent
- Simple format: request header, blank line, possible payload
- Symmetrical: allows data to be sent and received
- Very easy to implement but scales very well

## Example HTTP Request

```HTTP
GET /~cassidy/ HTTP/1.1
Host: www.ics.mq.edu.au
User-Agent: Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.7.12)
      Gecko/20050922 Firefox/1.0.7 (Ubuntu package 1.0.7)
Accept: text/xml,application/xml,application/xhtml+xml,
      text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Cookie: UserTrack=63B08C38-1234-0000-0000-00000000000000; 
     
```

Note lines folded for display.

What do each of these headers mean? Which are required? Many are defined
in the [HTTP standard](ftp://ftp.isi.edu/in-notes/rfc2616.txt) but
others can be defined via the HTTP extension framework.

## Example HTTP Response

```HTTP
HTTP/1.x 200 OK
Date: Mon, 20 Mar 2006 05:33:32 GMT
Server: Apache/2.0
Accept-Ranges: bytes
Content-Length: 4111
Keep-Alive: timeout=15, max=499
Connection: Keep-Alive
Content-Type: text/html
Content-Language: en
     
```

## Example HTTP POST Request

```HTTP
POST /~steve/form.html HTTP/1.1
Host: localhost
User-Agent: Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.7.12)
      Gecko/20050922 Firefox/1.0.7 (Ubuntu package 1.0.7)
Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,
      text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Referer: http://localhost/~steve/form.html
Content-Type: application/x-www-form-urlencoded
Content-Length: 106

name=Steve+Cassidy&interests=This+is+a+field+with%0D%0Aquite+a+bit+
    of+text%0D%0Athat+has+linebreaks.%0D%0A
     
```

Note lines folded for display.

This is a POST request, note how the data is encoded in the request
body.

## Example HTTP GET Request

```HTTP
GET /~steve/form.html?name=Steve+Cassidy&interests=This+is+a+field+
     with%0D%0Aquite+a+bit+of+text%0D%0Athat+has+linebreaks.%0D%0A HTTP/1.1
Host: localhost
User-Agent: Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.7.12)
     Gecko/20050922 Firefox/1.0.7 (Ubuntu package 1.0.7)
Accept: text/xml,application/xml,application/xhtml+xml,
     text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Accept-Language: en-us,en;q=0.5
Accept-Encoding: gzip,deflate
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7
Keep-Alive: 300
Connection: keep-alive
Referer: http://localhost/~steve/form.html
If-Modified-Since: Mon, 20 Mar 2006 06:22:29 GMT
If-None-Match: "4f42a9-fd-40f672edb1340"
     
```

Note lines folded for display.

This is the same form submitted via a GET request, here the data is
encoded in request URL. Note also the If-Modified-Since header in this
request, sent because my browser has just asked for the same resource.

## HTTP Redirect


```HTTP
GET /~steve/ HTTP/1.1
Host: www.shlrc.mq.edu.au

HTTP/1.x 301 Moved Permanently
Date: Mon, 20 Mar 2006 06:32:36 GMT
Server: Apache/2.0.46 (Red Hat)
Location: http://www.ics.mq.edu.au/~cassidy/
Content-Length: 242
Connection: close
Content-Type: text/html; charset=iso-8859-1
     
```

Alternately

```HTML
<meta http-equiv="refresh" 
      content="URL=http://my.new.site.com/">
     
```

The HTTP redirect is a server response that can be used to indicate that
a resource has moved to a new location. An alternate is to include the
above meta tag in a page header to force a redirect from the current
page.


## HTTP Verbs

- GET - get a resource, *Idempotent*
- POST - send some data to a resource
- HEAD - get headers for a resource
- PUT - create a new resource
- DELETE - delete a resource

## Common HTTP Response Status Codes

Some notable response codes:

- [200 OK](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes#2xx_Success) -
    Request succeeded and everything went well
- [301 Moved Permanently](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes#3xx_Redirection) -
    Requested resource has moved and all future requests should be made
    to new location
- [403 Forbidden](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes#4xx_Client_Error) -
    Response refused by server (even if request is valid)
- [404 Not Found](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes#4xx_Client_Error) -
    Server could not find requested resource (though it may be available
    in the future)
- [500 Internal Server Error](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes#5xx_Server_Error) -
    Generic error message response when server encountered an error

See also: [full list of HTTP status codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
