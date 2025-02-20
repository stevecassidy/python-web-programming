# Express Server Side Applications

[Express](http://expressjs.com) is a server-side Javascript library that
helps in writing web server applications.   This chapter will introduce the
very basics of using Express to write a server application that implements
a JSON API.

## Running Javascript with Node.js

On the client-side we operate in a web browser environment that provides
a built-in Javascript engine.  On the server side we need to find a suitable
Javascript run-time environment; this is provided by [Node.js](https://nodejs.org).
Node.js runs almost the same variety of Javascript as a modern browser and has
additional libraries that implement things like file-system access etc. - things
that aren't allowed in the browser for security reasons.  Once you install
Node.js, you can run a Javascript source file with the command:

```bash
node index.js
```

## NPM: the Node Package Manager

NPM is a package manager installed with Node.js that handles downloading
and installing third-party packages for your projects.  When you install
a package using the `npm` command it is installed by default in the project
directory into a folder called `node_modules`.   This means that the packages
that you have installed can be different for different projects.  There is a way
to install things globally, but that is much less common in the Javascript world.

We'll see some examples of installing packages later in this chapter.

### Initialising a Node Project

When you first start a project with Node.js you will run the `npm init` command
to create a file called `package.json`.  This will contain the configuration
of your project including a list of the third-party packages that it relies on.
Having answered the questions, it will create a new `package.json` file something
like this:

```JSON
{
  "name": "server-example",
  "version": "1.0.0",
  "description": "An example json web api",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "Steve Cassidy",
  "license": "ISC",
}
```

This file describes your project and can be used to hold any configuration
for various tools you might use in development.

In this project, we'll make use of the [express](https://expressjs.com) module
to write our web server application.  This is a third-party module and
we can install it into our project with the `npm` command:

```bash
npm install express
```

This does two things: it downloads both `express` and any modules that it depends
and installs them into the `node_modules` directory in your project, and, it
updates your `package.json` file to record the dependency on this package.
It will add something like the following to your `package.json`:

```JSON
  "dependencies": {
    "express": "^4.18.2"
  }
```

This records the name and version number of the module it has installed.
This means that someone else using your code can reproduce the exact
dependencies for your project, just by running `npm install`.  

Installation also creates a file `package-lock.json` which has much
more detail about the packages installed and any dependent packages. Both
of these files should be kept as part of your project and added to your
git repository.

The `node_modules` directory should not be checked in to your git project
as it is often very large and can be reproduced exactly from the `package-lock.json`
file.  To prevent this being added to the project accidentally, we create
a file `.gitignore` which lists files and directories that should be ignored
by Git:

```text
# ignore the node_modules folder
node_modules/
```

At this point, you might want to initialise your git repository for the
project and commit these files.

## A Simple Server

We'll now move on to writing a simple application server using Express.  The
application will implement a simple collection of strings (things I like) 
and have endpoint URLs to get the collection (GET) and create a new
entry (POST).  This won't use a database, just an in-memory array
of strings for storage.

We'll write our Express application in the file `index.js` and to
being with, it will look like this:

```Javascript
const express = require('express');

const app = express();

// more code will go here

const PORT = 3123;
console.log(`Application is listening on http://localhost:${PORT}/`);
app.listen(PORT);
```

This code first imports the `express` module using a different syntax to
the one used in earlier front-end code.   This is an older module standard
implemented by the Node.js system before there was any such thing in the
standard.  It is possible to use modern `import express from 'express'`
syntax in Node but it takes a little bit of configuration.   We use this
syntax here because it is much more widespread in examples of server-side
programming that you'll see on the web.

The next line of code creates a new `express` application that can
accept requests and generate responses.  By default, it doesn't
know how to respond to any requests but we'll get to that.  THe last
three lines start the server running - printing out a message and
then calling `app.listen` to start monitoring the given port for
requests.  

You can run this from the command line by typing:

```bash
node index.js
```

You should see the message and then it will sit there waiting for
requests.  Go to your browser and enter <http://localhost:3123> and
you should see something like `Can't GET /`.  This means that the
server is working, but that we have not yet told it what to do
when a request arrives.  

We'll write a request handler as follows:

```Javascript
app.get('/', (req, res) => {
    res.json({hello: 'world'});
});
```

(this goes into the `index.js` file where the 'more code' comment is above).
This code defines a handler for `GET` requests to the URL `'/'` by associating
a function (the second argument) with a URL pattern.  The handler function
will be called if there is a request matching this URL and will be passed
two objects: `req` is the request object, `res` is the response.  The function
can get information from the request and update the response that it wants
to return.

In this example, the handler just gives the response a JSON payload.  This will
have the effect of setting the `Content-Type` for the response to `application/json`
and adding the encoded JSON string to the response body.

You'll need to stop and re-start your server for the new code to be seen.  Use
Ctrl-C to stop it running.

If you go back to your browser and refresh the page you should now see the JSON
response in the page.  Look at the request in your browser tools and you'll see the
headers that have been set by the server, something like this:

```HTTP
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 17
ETag: W/"11-IkjuL6CqqtmReFMfkkvwC0sKj04"
Date: Fri, 05 May 2023 06:18:57 GMT
Connection: keep-alive
Keep-Alive: timeout=5
```

We didn't need to write much code to get this functionality. The Express module
is doing the work for us of creating the right HTTP response headers.

## Server Restarts - `nodemon`

Restarting the server every time we make a change is a pain. Luckily other people
think the same and there are options for automatically re-starting if you edit a
file in the project.  The most common option is a package called
[`nodemon`](https://nodemon.io/) which behaves just like `node` but will
monitor for changes in your code and restart if it sees any.  We'll install 
`nodemon` but we'll save it as a development dependancy only:

```bash
npm install --save-dev nodemon
```

This will install the package in `node_modules` and update the `package.json` with
something like:

```json
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
```

## Adding Data

This application doesn't do much yet so let's add the list of likes as described
and write the handlers for the `/likes` URL.  As mentioned, our data store
is a global variable and a GET request to `/likes` retrieves the contents of
the data store.

```Javascript
const data = {
    likes: [],
};

app.get('/likes', (req, res) => {
    res.json(data.likes);
});
```

Once this code is in place, we can send a request to <http://localhost:3123/likes> 
and get a response of `[]` - the empty array, since there is nothing stored in the
global variable yet.  So, let's now implement the handler for a POST request to
the same URL that will accept a JSON body containing something we like and add
it to the array.  

The POST request will accept a JSON body like this:

```JSON
{
    "thing": "cheese"
}
```

To support parsing JSON in a request we first need to add some _middleware_ to
our application.   Middleware in Express is a function that runs before or after
a request handler that can modify the request in some way. In this case, the
middleware will parse the JSON payload (if the `Content-Type` header is `application/json`)
and make it available via the request object.  The following line of code should
go just after the app object is created:

```Javascript
app.use(express.json());
```

With this in place, we can now write the POST handler:

```Javascript
app.post('/likes', (req, res) => {
    if( 'thing' in req.body) {
        data.likes.push(req.body.thing);
        res.json({status: 'success'});
    }  else {
        res.json({status: 'error', message: 'missing thing'});
    }
});
```

This handler function is created using `app.post` (rather than `app.get`) so it will
handle POST requests.   It will match any request for `/likes`.  Inside
the handler function, `req` is the request object and `req.body` is the result of
parsing the JSON payload of the request if there was one. We check for a
property `thing` in the body and if it is there, we push it into the
global data array, `data.likes`.  

The response is a JSON object with a `status` field that could be used by the
sender of the request to find out if everything went well.

We can now send a POST request to the server to add something to our list of
likes.  Of course, we can't do this directly with the browser, we'd need to
write some front-end code to make use of this simple API.  Alternately,
you can use a tool like RESTED [for Chrome](https://chrome.google.com/webstore/detail/rested/eelcnbccaccipfolokglfhhmapdchbfg?hl=en-GB) or
[for Firefox](https://addons.mozilla.org/en-US/firefox/addon/rested/) to create
test requests in your browser (RESTED is just one of these, there are others
to choose from).

## Summary

This has been a very simple example of a server-side application using Express
that implements a JSON API.  It uses an in-memory data store to keep a list
of things and returns the current list in response to a GET request.

There is obviously much more to a real web application, the first big thing
being persistent storage.  This would be in a database of some kind - either
a traditional SQL database or a NoSQL database like MongoDB or CouchDB
that stores JSON data directly.
