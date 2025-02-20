# A View of HTML

Rather than being a chapter that will teach you the HTML language this
will be a chapter about the language, how it works, why it has the
structures it does and what you should and shouldn't do with it.

Most people will know some HTML by now (assuming you've been studying
computing for a while or have a general interest in the web). My task
here is not to teach you HTML or act as a reference for the language,
there are plenty of resources around that will do this. Some examples
are:

- [w3schools HTML tutorial](http://www.w3schools.com/html/default.asp)
    w3schools is one of the most widely used tutorial and reference
    sites on the web for HTML and other web technologies.
- [Learn HTML](https://developer.mozilla.org/en-US/learn/html) from
    the Mozilla Developer Network, the organisation that produces the
    Firefox browser. This page has pointers to a number of HTML
    tutorials and resources.
- [Learn HTML](https://web.dev/learn/html/welcome) a similar resource
from the Chrome development team within Google.

## About HTML

HTML is a _markup language_, which is a formal language used to add
encode structured documents, often by mixing formal elements and plain
text.

HTML is the _Hypertext_ Markup Language, meaning that it is designed to
encode hypertext documents - that is, documents containing links to
other documents on the World Wide Web. In fact, the hyperlink is just a
small part of HTML and much more interesting are all the other parts of
the language that allows us to produce useful documents for the web.

Importantly, HTML is a _markup language_ not a _programming language_.
The job of a markup language is to record the structure of a document;
that structure can then be interpreted by a program to generate some
output. A programming language contains instructions that will be
executed (or interpreted) to carry out some action or compute some
result.

## Versions of HTML

The first version of HTML was developed by Tim Berners-Lee as part of
his World Wide Web project along with the HTTP protocol and the URL
syntax. At first it was a very simple language for encoding articles and
so had tags for headings, paragraphs, lists etc. Later, the language
evolved to encompass new features in the browser such as the ability to
display images, tables and modify the font that text was displayed in.
The evolution of HTML has been quite gradual and at times part of
intense competition between browser vendors (look up the [Browser
Wars](http://en.wikipedia.org/wiki/Browser_wars) to get the full story).
The Internet Engineering Task Force (IETF) and later the World Wide Web
Consortium (W3C) tried to standardise the language but it took some time
for industry practice to align with the W3C standards. Luckily now we
are in a period of relative stability where the standards process aligns
well with what the major browsers are able to understand.

A version of HTML is defined by a
formal definition of the allowed tags and attributes and the allowed
structure of an HTML document. This says that you can have a
`<p>` tag and that it can contain a `<strong>` tag but that a
`<li>` has to be inside a `<ul>` or `<ol>` tag and so on. If
a document follows the rules, we say that it is
_valid_, if it contains errors such as having an unknown tag or a tag in
the wrong place it is _invalid_.

Early versions of HTML were subject to a lot of change and it wasn't
until HTML version 4.0.1, released in 1999 that there was a bit of
stability in the language and consensus about what should be included
and what should be left out. Before then, HTML had grown to contain a
lot of _visual_ markup that had been developed by the browser vendors
(Netscape and Microsoft) to try to make their browser look better than
the competition. An example is the &lt;font&gt; tag introduced by
Microsoft (and copied by Netscape) which could change the font used to
render some text. By the time HTML 4.01 was published, Cascading Style
Sheets (CSS) were becoming more widely adopted and the use of markup
that explicitly referred to the visual appearance of the content was
discouraged.

### Elements or Tags

I will sometimes talk about the `<p>` tag or the `<p>` element when
talking about HTML.  Tag is the textual form of the HTML page with
angle brackets etc; there is an opening `<p>` tag and a closing `</p>`
tag.   The element is what is created when the HTML
is parsed by the browser for display in the page and includes
the open/close tags and the content.

Most elements require both an open and close tag but in some cases
the end tag can be left out.  Examples are `<meta>`, `<img>` and `<br>`.
These elements don't have any content and so the end tag can be assumed.
In some cases you will see the syntax `<br/>`; this is the so-called
XHTML syntax borrowed from XML.  Effectively, `<br>` and `<br/>` are
equivalent.

### HTML5

The most recent version of HTML is HTML5 - note the name with no spaces
which is quite different to earlier versions.  HTML5 was a big change in
the way that the standard was put together and followed a long break in
the development of standards for HTML: HTML 4.0.1 was last updated in 2000,
HTML5 was finally released in 2012. The goal of HTML5 was to standardise
current practice in browsers, rather than to define new structures or limit
what was possible.   The W3C worked with the browser developers to
agree on standards for new technologies that they had introduced. For example,
being able to include audio and video elements in HTML had been possible
in some browsers; HTML5 defined a standard for these that all browser
vendors could agree on and implement.

## The HTML Language

This section will briefly cover some of the HTML language but is not
intended to be a comprehensive guide.  The aim is to point out some
of the high level ideas that you need to know to get started with HTML.

### Document Structure

Here's a simple HTML page showing the overall structure of the document.

```HTML
<!DOCTYPE html>
<html lang='en'>
    <head>
        <title>Sample Page</title>
    </head>
    <body>
        <h1>Hello</h1>
        <p>World</p>
    </body>
</html>
```

The first thing to mention is the low level syntax of HTML where
we have start tags (`<body>`) and end tags (`</body>`) with content
between these.   The content might be more tags or just text but each
start tag generally has a matching end tag (there are exceptions, see later).

The first line `<!DOCTYPE html>` is a declaration that this file is
written according to the HTML5 standard.  This line is optional in the sense
that your page will probably work without it, but including it let's the browser
know that you know what you're doing and will stick to the HTML standard.  If you
leave it out, the browser will assume that this is an older HTML page and might
have to do more work to parse it properly.  Best practice is to put this in
every page.

The overall page consists of a `<head>` containing metadata about the page and
a `<body>` with the page content. Certain tags are allowed only in the head
section or the body.

### Head Tags

The content of the `<head>` tag is metadata about the page and is generally not
visible directly, apart from the `<title>` element that will define the title
appearing in the browser tab.  Two important tags that go here are the
`<link>` tag that allows us to define a relationship to another resource
such as a CSS stylesheet, and `<script>` that references Javascript code.  
`<script>` can also be used inside the document body as we will see.

Other tags in the head define metadata that describe aspects of the page. This
can be to help the browser, search engines or other web clients.  Here's 
some meta tags from [this MDN page](https://developer.mozilla.org/en-US/docs/Web/HTML) 
as an example:

```HTML
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1"/>
    <meta name="theme-color" content="#ffffff"/>
    <meta name="robots" content="index, follow">
    <meta name="description" content="HTML (HyperText Markup Language) is 
       the most basic building block of the Web."/>
```

The `viewport` property tells the browser how to handle the page on a mobile device.
The [theme-color](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta/name/theme-color)
property provides hints about the color that could be used to display the UI elements
surrounding the page.   The `robots` property is an instruction to an automated web
crawler about what it is allowed to do with links in the page and the
`description` is a summary of the page to help a search engine index the
content.  Most of these are
optional, the page will work for regular browser users without them, but they
go towards making the page more useable and findable.

### Body Tags

The body contains the content of the web page and there are many elements
that can appear here.   Most elements contain some text or other elements
and define how their contents will appear on the page by default. For example, the
`<p>` element denotes a paragraph and the content will be displayed as you
would expect as a block of text; `<strong>` denotes some text that should
be emphasised and will be shown in bold by default.

We can talk about two things for each element: the meaning and the default
visual appearance.   The meaning of an element is the intended use of the
element to denote a part of the page.  For example, 'this text is a paragraph',
'this is a table', 'here is a major heading'.  Each element then has a default
visual appearance that makes sense for that type of content. Headings are set
on their own in larger type. Paragraphs have space before and after them etc.  

The visual appearance of any element can be changed via a [CSS stylesheet](intro-css.md)
so what we get by default is only a default. You can make headings be small and
green if you wish.

#### Semantic Markup

You will see references to [Semantic HTML](https://web.dev/learn/html/semantic-html)
where 'semantic' means the meaning of each element.  The idea here is
that there are many elements that have the same default visual appearance
but we should chose the element that describes the meaning of the part of
the document we're marking up.  So, use `<h1>` for the main heading
in the page rather than using `<p>` and applying your own stylesheet.  Using
the right elements makes your page more accessible. The browser will know where
the headings are and a search engine will be able to understand the structure
of your page more easily.   Blind users rely on well structured semantic
HTML to help them to navigate your page using a screen-reader.  So, learn
as much as you can about the different elements available to you and use
one with the right meaning in your page.

#### Inline or Block

Some elements are intended to mark up 
[blocks of content](https://developer.mozilla.org/en-US/docs/Glossary/Block-level_content)
and by default will
be displayed as rectangles with space around them in the page.  The obvious
block is `<p>` which displays a block of text but there are many others
such as `<header>`, `<footer>` which define larger sections of the page.
One important example is `<div>` which is a block with no semantics. It is often
used with an id or class attribute as a way of identifying part of the page
to apply styles to. Eg. `<div id='main'>...</div>`.

Another class of elements are those that are used inline in the content of
a block.  Examples are `<strong>text</strong>` and `<a href="link.html">a link</a>`
both of which could occur inside a paragraph for example and would affect how
the enclosed text is displayed or behaves.  There is also a generic inline
element `<span>` which can be used in a similar way to the `<div>` block tag
to apply styles.

## HTML Forms

An important group of HTML tags are those that describe forms. Forms
allow user interaction with the page - entering text, selecting from
drop-down menus, clicking buttons.   The original design of forms
was as a way of gathering user input to be sent back to the server
for processing.  They are still used this way but in many cases these
days, the form data may be processed in the page using Javascript 
rather than being sent to the server.  Here we'll look at how forms
are built and their default semantics.

Here is an example form:

```HTML
<form method="POST" action="/process">
   <div>
       <label for="name">Name</label>
       <input name="name">
    </div>
    <div>
        <label for="age">Age</label>
        <input name="age" type="number" min=0 max=110>
    </div>
    <div>
        <label for="message">Message Text</label>
        <textarea name="message"></textarea>
    </div>
    <div>
        <input type="submit" value="Submit Message">
    </div>
</form>
```

The [`<form>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/form)
encloses the entire form and the two attributes on
that element define what should happen when the form is submitted. In
this case we will use a `POST` request (see [HTTP](http.md)) to the
URL `/process` to submit the form.  It would also be possible to use
a `GET` request and for the action to be a full URL.

The action of a form is carried out when the form is submitted. By default
this is when the submit button is clicked; the submit button is a special
case of an `<input>` element with `type="submit"` or it can be a `<button>`
element inside the form.

```HTML
<form>
    <input type="text" name="name">
    <input type="submit" value="This button will submit the form">
    <button>So will this button</button>
</form>
```

Inside the form, the first thing to note is that we can include structural
tags like `<div>` to help lay out the form nicely.  In this case I would use
CSS rules to make the form display appropriately.  The form specific
tags are `<label>`, which defines a label for a given form input, and
`<input>` or `<textarea>` which define input controls.

The [`<input>` tag](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Input)
is very general and can be used for different kinds of user input. The simplest,
 as in my _name_ input, is a text box where the user can enter text.  The next
 example shows the use of the _type_ attribute, in this case to define the input
 as a numeric entry.  As you'll see from the 
 [MDN reference](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Input#input_types)
 there are many possible values for
 the _type_ attribute from _button_ to _date_ to create different kinds of
 input control. The `<textarea>` element defines a multi-line text entry.

 Each of the input control elements has a _name_ attribute that defines
 a name for the input.  These names will be sent to the server and can be
 accessed from Javascript code running in the browser.  Input controls
 can also have a _value_ attribute to define an initial value for the
 input and a _placeholder_ attribute that defines some placeholder text
 to show in the input if no value is present.




## Some Newer HTML Features

These examples are intended to show some more recent features of the HTML
standard that you might not have seen before.  They are not the only
recent additions and illustrate the value of keeping up to date
with the standard as it evolves.  If you have some experience with
using higher level toolkits, you might have used implementations of
some of these features.  It's good to know that you can achieve the same
outcome with simpler HTML.

### Modals with the `<dialog>` Element

A common feature of web applications is a dialog box that pops up to
ask the user to confirm an action or to enter some data.  In the past
this has required Javascript code to be written to control the behaviour
of the dialog box.  The HTML5 specification introduced a new element
called `<dialog>` that can be used for this purpose.  It is a block
level element that can be used to create modal (takes over the page until closed)
and non-modal (just appears in the page).

To implement a modal dialog, we still need some Javascript but the code is
very simple and uses methods on the dialog element to manipulate it's state.
Here's a very simple example:

```HTML
<dialog id="sample-dialog">
 <button onclick="closeDialog>Close</button>
  <p>This is the content of the dialog.</p>
</dialog>
<button onclick="openDialog">Show the Dialog</button>

<script>
const openDialog = () => {
    const dialog = document.querySelector("#sample-dialog");
    dialog.showModal();
};

const closeDialog = () => {
    const dialog = document.querySelector("#sample-dialog");
    dialog.close();
};
</script>
```

Since this is just a regular HTML element, you can apply whatever style
you choose with CSS.  This can include bluring out the background when
the dialog is open, rounding the corners of the dialog etc.  The
[MDN page](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/dialog) 
has some examples.

### Show/hide content with `<details>`

Another common UI construct that has developed on the web is to show a
small bit of content with a button to display more detail.  Again, in the past
this has required Javascript to implement but with HTML5 there is now
the [`<detail>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details)
that can be used in plain HTML:

```HTML
<details>
    <summary>This is the summary</summary>
    <p>And here is some more detail on this topic.</p>
</details>
```

### Input Completion with `<datalist>`

Having a form input element that shows suggestions as you type is very
common and often uses Javascript to generate the options.  HTML now
has a native way to encode options if they are known in advance.

```HTML
<label for="ice-cream-choice">Choose a flavor:</label>
<input list="ice-cream-flavors" id="ice-cream-choice" name="ice-cream-choice" />

<datalist id="ice-cream-flavors">
  <option value="Chocolate"></option>
  <option value="Coconut"></option>
  <option value="Mint"></option>
  <option value="Strawberry"></option>
  <option value="Vanilla"></option>
</datalist>
```

In this example ([from MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/datalist))
we provide a list of options via the `<datalist>` element
to provide completions for an input form control.  
