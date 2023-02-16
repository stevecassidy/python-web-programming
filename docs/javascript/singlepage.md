# Single Page Web Applications

This chapter will discuss the things we need to know to develop the most common
pattern of web application these days which are _Single Page Web Applications_.  The
main characteristic of these applications is that the HTML page that is loaded is
very simple - often containing no content at all, but referencing Javascript code that
builds the page and implements the interaction with the user.

## Why SPA?

On a traditional website, each page in the site is the result of an HTTP request to
the server.   When the user clicks on a link, a new page is requested and displayed once
the response arrives from the server.  Users submit form data to the server
to carry out actions and again, see the results when a new page is returned via
an HTTP request.  Each of these requests takes some time, so interaction with the
website is slowed because it has to wait for requests to complete.

In contrast, a Single Page Application is loaded only once into the browser and the
page is updated via Javascript code as the user interacts with it.  Requests are sent
to the server by the Javascript code in response to user actions, the user is able to
keep using the application while the request is in progress.  

## The Technology Behind an SPA

An SPA is enabled by a combination of the core web technologies we have been
learning about used in a particular way.

### HTML and CSS

The basis for any web page is HTML and CSS but in an SPA, the initial HTML
page that is loaded can be very simple and might not have any content
at all.  Here's an example:

```HTML
<!doctype html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
  <meta name="Description" content="A single page web application.">
  <base href="/">
  <link rel="stylesheet" href="/static/style.css">
  <script type="module" src="/static/main.js" defer></script> 
  <title>My Own SPA</title>
</head>

<body>
  <div id="content"></div>
</body>

</html>
```

When this page loads it will contain only the empty placeholder `<div>`
element and show no content at all to the user.  The browser will
load the CSS stylesheet and the referenced Javascript module. When
the Javascript code is run, it will generate the page content that
will be shown to the user.

So in an SPA, HTML is used as the carrier for the other assets (CSS
and Javascript) that are needed to load the application.  The Javascript
code then generates more HTML content programmatically to show the
application content to the user.  HTML is still at the core of a
single page application.

### Javascript and the DOM

Javascript is fundamental to the way that an SPA works and the ability to update
the [Document Object Model](dom.md) of the current page means that
the Javascript code can respond to user input and present whatever
content or visual interface is appropriate at any point.

In the example above, the script `main.js` is loaded from the initial
HTML page.  Note that the script tag has the `defer` attribute set which
means that it won't be executed until after the page has loaded.  This
means we know that the `content` div will be in place in the DOM when the
script runs.  The first job of the script is to inject some content into
that element. A trivial example would be:

```javascript
const element = document.getElementById('content');
element.innerHTML = '<h1>Hello World</h1>' 
```

Now the page will display the Hello World message rather than being totally blank.
Since the execution of this code is generally very fast, the user won't notice
that there was an initial blank page.

In a more realistic example, the initial page would be the home page of the web
application and the code to build it would be more complex.  The application could
be structures so that everything that is needed for the web application is
bundled with the Javascript code.  In this case, no further requests are needed and
the user will be able to interact with the application in the browser - each click
will redraw the page with new content, forms will be processed locally (eg. doing
calculations in Javascript and presenting the results).

A more common scenario is one where the Javascript code makes further requests to
the main server or other API servers on the web for information to display to
the user.  An example might be showing the current weather forecast: the Javascript
code would request weather details from an API endpoint and then construct an HTML
fragment to display in the page.  User interactions can result in further requests
being sent to other APIs - for example, the user selects a new city and we fetch
the forecast for that city.

### Web APIs

This brings us to another important part of the SPA which is the use of [Web APIs](../data/webapi.md).  These are web servers that provide information and services,
generally delivering results as JSON documents in response to HTTP requests.

The server that delivered the initial HTML page for the single page application
may also offer an API to provide information to be included in the pages.  An
example might be a blogging service that has an API endpoint to allow the
application to get the most recent list of blog posts.

Alternately, the application can use APIs from anywhere else on the web that are
configured to allow cross-domain requests (so that an SPA served from <https://example.com/> is allowed to make API requests to <https://api.com/>). This means that the
front-end application can bring together information and services from
other places on the web and integrate them into an application.

## Tool-kits for SPAs

While it is possible to write single page applications using plain Javascript code,
it is very common to leverage a higher level tool that provides an abstraction
layer to help with generating the HTML fragments and managing user interaction.

Tools like [React](https://reactjs.org/), [Angular](https://angular.io/) and [Vue](https://vuejs.org) allow you to write higher level code defining _components_ that
implement different information displays and user interactions.  The code you write
is Javascript but uses these libraries to generate the HTML content in your pages.
However, your browser isn't generally able to run this higher level code directly.  
The code must be _transpiled_ into a simpler Javascript version that will run
in the browser (transpilation means to compile one version of Javascript code into
another version).   This build process will also do things like optimising the
size of your CSS files and bundling things together to make them as small as
possible.

