# JSON for Data Exchange

JSON is the Javascript Object Notation, a format for the exchange of data over
the internet that uses the structure of a Javscript object.  JSON originates
as Javascript code but is now used widely in different programming languages
and database as a storage and transmission format.

## The Need for JSON

The web is a _distributed system_ with applications running on different computers
communicating with each other via HTTP to coordinate their activities.  A regular
web page is intended for human viewing but behind the scenes, Javscript code
is running in the browser and needs to exchange data with server applications.  A
_machine readable_ format is needed for this exchange - one where the code can
easily convert the message into data.

In the early days of web based systems, a language called XML (Extensible Markup
Language) was developed for data
interchange.  XML looks very similar to HTML with tags in angle brackets.  XML could
be used to encode data, for example:

```xml
<books>
    <book>
      <title>A Tale of Two Cities</title>
      <author>Charles Dickens</author>
    </book>
    <book>
      <title>Wuthering Heights</title>
      <author>Emily Brontë</author>
    </book>
</books>
```

This data format might be sent from a server in response to an HTTP request for
a book
list.  The Javascript code would then have to parse the XML to extract the
data.  This turned out to be rather complex and the time taken 
to extract the data was has been called the
[angle bracket tax](http://blog.codinghorror.com/xml-the-angle-bracket-tax/) 
(from 2008, and see
[here for a follow-up](http://blog.codinghorror.com/revisiting-the-xml-angle-bracket-tax/)).
Over time this has led to many people looking for alternatives to XML
that would be easier to process and perhaps easier to read. The format
that is now dominant on the web is [JSON](http://www.json.org/).

## What is JSON

As the name suggests, JSON is based on the way that literal [objects](objects.md)
are written in Javscript.  Here's a reminder:

```javascript
const myCar = {
    make: 'Holden',
    model: 'Astra',
    year: 2009,
} 
```

An object is a collection of properties and values, the values can be any Javascript
basic data type: numbers, strings, arrays, objects.  To turn the above fragment of
Javascript code into JSON we just take the part after the assignment operator and
make sure that all of the property names are surrounded by double quotes.  Also we're
not allowed to have a comma at the end of the last line of properties (which is allowed
in modern Javascript).

```json
{
    "make": 'Holden',
    "model": 'Astra',
    "year": 2009
} 
```

If you know how to write literal Javascript data then you know how to write JSON
with the caveats above.  Here's another example that includes arrays and embedded
objects:

```json
{
    "roles":["admin", "moderator", "team", "user"],
    "users":[
        {
            "name":"Admin User",
            "username":"admin",
            "roles":[
                {"name":"admin", "value":false},
                {"name":"moderator", "value":false},
                {"name":"team", "value":false},
                {"name":"user", "value":false}
            ]
        }
    ]
}
```

## JSON On the Web

JSON is widely used as an exchange format on the web where a web server wants to
return data that can be read by an application.  In the above example, the data
being returned is information about the users of a system.  The front-end web
application would use this to manage access to a service or present to the user
in some way.  When a server returns JSON content it uses the `Content-Type`
of `application/json` so that the application knows that it is getting JSON
data.

A web client can send JSON data too. Many servers accept JSON data in a POST
request.  For example, you might send a username and password to an authorisation
endpoint like this:

```json
{
    "username": "boballoba",
    "password": "bob"
}
```

This would be the body of the POST request and you would send it with the
the `Content-Type` header of `application/json`.

To save space, most JSON is not sent nicely indented like this, all of the
whitespace is removed so we send:

```json
{"username":"boballoba","password": "bob"}
```

If you are looking at this in your browser it can be hard to read for a large
JSON result.  Look for browser extensions like 
[JSON Viewer (Chrome)](https://chrome.google.com/webstore/detail/json-formatter/bcjindcccaagfpapjjmafapmmgkkhgoa)
or
[JSONView (Firefox)](https://addons.mozilla.org/en-US/firefox/addon/jsonview/) to
make it easier to browse JSON data.

## JSON in Javascript

You might think that since JSON is basically Javscript code, it would be trivial
to load some JSON data into a Javascript application.  In the early days of JSON
the common practice would just be to evaluate the JSON data as code and then use
the resulting object in the application.   This quickly turned out to be a bad
idea since the JSON could contain not only data but also code that could be
malicious.   As a result, it is now best practice to use a separate JSON parsing
process for JSON data and the language now has the `JSON.parse` and `JSON.stringify`
functions to translate between JSON and native Javascript data structures.

`JSON.parse` will convert a well-formed JSON string into a Javascript data 
structure:

```Javascript
const jsonText = '{"username":"boballoba","password": "bob"}'

const data = JSON.parse(jsonText);
console.log(data.username, data.password);
```

`JSON.stringify` will generate well-formed JSON from most data structures:

```Javascript
const data = {
    name: 'Bobalooba',
    cities: ['Rome', 'Paris', 'Eastwood'],
};
const jsonText = JSON.stringify(data);
console.log(jsonText);
```

The result of `stringify` is suitable for sending off as the payload of an HTTP
request.  An example might be the authentication API mentioned above.  If we
assume that this API also returns a JSON response we might use code like this
to access it:

```Javascript
const data = {
    username: 'bobalooba',
    password: 'bob',
};
fetch('https://example.org/auth', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(data),
})
.then(response => response.json())
.then(data => {
    console.log('response data is:', data);
})
.catch(error => {
    console.log('error in API', error);
});
```

In the POST request we set the content type header and then insert the JSON
payload into the request body.   The first then clause calls the `.json()` method
on the response to parse the response body as JSON and return the resulting
data.   The second then clause accepts the parsed data and makes use of it.
