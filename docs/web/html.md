

A View of HTML
==============

Rather than being a chapter that will teach you the HTML language this
will be a chapter about the language, how it works, why it has the
structures it does and what you should and shouldn't do with it.

Most people will know some HTML by now (assuming you've been studying
computing for a while or have a general interest in the web). My task
here is not to teach you HTML or act as a reference for the language,
there are plenty of resources around that will do this. Some examples
are:

-   [w3schools HTML tutorial](http://www.w3schools.com/html/default.asp)
    w3schools is one of the most widely used tutorial and reference
    sites on the web for HTML and other web technologies.
-   [Learn HTML](https://developer.mozilla.org/en-US/learn/html) from
    the Mozilla Developer Network, the organisation that produces the
    Firefox browser. This page has pointers to a number of HTML
    tutorials and resources.



About HTML
----------

HTML is a *markup language*, which is a formal language used to add
encode structured documents, often by mixing formal elements and plain
text. Another example is the LaTeX language used to typeset scientific
and technical documents. Here's a fragment of LaTeX that shows the use
of commands preceded by a backslash character and curly braces to
enclose text:

```
\subsubsection*{Constraints on tiers: sequence and hierarchy}

Constraints are perhaps best illustrated in ELAN which has 
perhaps the most elaborate set of alternate sequential and 
hierarchical constraints within and between tiers called 
the \emph{Linguistic Type Stereotype} \cite{elan-manual}:

\begin{itemize}
   \item None - the 'parent' tier has no restrictions 
       except segments cannot overlap
   \item  Time subdivision - annotation in parent can be 
       subdivided in the child tier with segments linked 
       to time intervals, no time gaps allowed
\end{itemize}
```

These commands are interpreted by the LaTeX system which uses then to
produce nicely typeset PDF output. Markup can also be used to identify
regions of text for analysis. Here's an example from a language corpus
used to study human interaction:

```
 <$A> <#\><[>Oh no <#\>The diving</[></{> I'm sorry <#\>Yeah <#\>Diving
 <$B> <#\>PADI certificate
 <$A> <#\>What d'they call diving <#\>It's um<,,>
 <$B> <#\>Yeah <#\>There's a<,> P A D I PADI
 <$A> <#\>Oh is there
 <$B> <#\>And it's the Professional Aquatic Divers Institute and
you can either get<,> you know a certificate or a diploma or
 <$A> <#\>Different grades
 <$B> <#\>Yeah
```

In this example, special character sequences are used to mark things
like speaker turns, pauses, phrases and overlapping speech. This markup
can be used to help analyse the language and find examples of certain
linguistic phenomena (for example, find me examples of *'you know'* and
show me what the next person says in response).

HTML is the *Hypertext* Markup Language, meaning that it is designed to
encode hypertext documents - that is, documents containing links to
other documents on the World Wide Web. In fact, the hyperlink is just a
small part of HTML and much more interesting are all the other parts of
the language that allows us to produce useful documents for the web.

HTML is based on an earlier standard called SGML (Standard Generalised
Markup language) which had a successor called XML (eXtensible Markup
Language). SGML and XML are both languages for defining markup
languages, that is they define the syntax of a markup language but allow
you to develop your own language for a specific purpose. The syntax is
the angle brackets containing start and end tags &lt;p&gt; and
&lt;/p&gt; that you will be familiar with (and a number of other rules).
SGML and XML based languages all use this same syntax but allow the
language designer to make up their own tags and define how they should
be used together. HTML was designed originally by Tim Berners-Lee and
later by the W3C as a language to encode pages of content for the web.

Importantly, HTML is a *markup language* not a *programming language*.
The job of a markup language is to record the structure of a document;
that structure can then be interpreted by a program to generate some
output. A programming language contains instructions that will be
executed (or interpreted) to carry out some action or compute some
result.


Versions of HTML
----------------

The first version of HTML was developed by Tim Berners-Lee as part of
his World Wide Web project along with the HTTP protocol and the URL
syntax. At first it was a very simple language for encoding articles and
so had tags for headings, paragraphs, lists etc. Later, the language
evolved to encompas new features in the browser such as the ability to
display images, tables and modify the font that text was displayed in.
The evolution of HTML has been quite gradual and at times part of
intense competition between browser vendors (look up the [Browser
Wars](http://en.wikipedia.org/wiki/Browser_wars) to get the full story).
The Internet Engineering Task Force (IETF) and later the World Wide Web
Consortium (W3C) tried to standardise the language but it took some time
for industry practice to align with the W3C standards. Luckily now we
are in a period of relative stability where the standards process aligns
well with what the major browsers are able to understand.

A version of HTML is defined by a Document Type Definintion (DTD) - a
formal definition of the allowed tags and attributes and the allowed
structure of an HTML document. The DTD says that you can have a
&lt;p&gt; tag and that it can contain a &lt;strong&gt; tag but that a
&lt;li&gt; has to be inside a &lt;ul&gt; or &lt;ol&gt; tag and so on. If
a document conforms to the DTD (follows the rules) we say that it is
*valid*, if it contains errors such as having an unknown tag or a tag in
the wrong place it is invalid.

Early versions of HTML were subject to a lot of change and it wasn't
until HTML version 4.0.1, released in 1999 that there was a bit of
stability in the language and consensus about what should be included
and what should be left out. Before then, HTML had grown to contain a
lot of *visual* markup that had been developed by the browser vendors
(Netscape and Microsoft) to try to make their browser look better than
the competition. An example is the &lt;font&gt; tag introduced by
Microsoft (and copied by Netscape) which could change the font used to
render some text. By the time HTML 4.01 was published, Cascading Style
Sheets (CSS) were becoming more widely adopted and the use of markup
that explicitly referred to the visual appearance of the content was
discouraged.

HTML 4.0.1 is still the latest version of the official W3C standard
although there have been a large number of changes implemented by the
browser vendors since the time it was released.

In 1997 the XML standard was introduced. XML was intended to generalise
the use of markup on the web and allow developers to design thier own
markup languages for specific purposes. XML is an evolution of the
earlier SGML standard on which HTML had been based; it simplified the
syntax rules a lot and made it easier to write parsers for XML. One of
the early applications of XML was to develop XHTML - a version of HTML
converted to adhere to the XML standard. XHTML 1.0 retained almost all
of the tags in HTML 4.0.1 but introduced the constraints of XML. For
example in an XML document every opening tag must have a corresponding
close tag; in HTML, many close tags are optional (e.g. you can leave out
the closing &lt;p&gt; tag for a paragraph since it is implied by the
next opening &lt;p&gt; tag) and many tags never have a close tag because
they never contain any text (e.g. &lt;img&gt; or &lt;br&gt;). In XHTML
then, paragraphs always require a close tag and empty tags are written
with the new XML syntax: &lt;br /&gt;.

One of the motivations for introducing XHTML was to try to encourage web
developers to adhere more closely to the published standards. The web
had grown up with a culture of view-source where people would learn how
to encode web pages by looking at the source HTML of other web pages
rather than by reading the standard. They would then write their own
pages and if they looked ok in the browser, they would publish them. To
cope with the amount of badly formed HTML content on the web, the
browser vendors built thier HTML parsers to be very forgiving. If you
put a paragraph inside an image tag or a header inside a paragraph it
would have a go at rendering the content. As a consequence, very few web
publishers cared about generating proper HTML and anyone who wanted to
parse web content had to make very few assumptions about HTML structure.

Around this time there was a move towards having more automated clients
consuming web content. One group was the search engine developers who
were just interested in the textual content of pages but other groups
were trying to glean real data from the web. For example, price
comparison services were starting up which tried to extract pricing
information from store listings. Other services might try to find event
information from web pages. All of these services needed to parse the
HTML structure and had problems when the HTML was badly structured; this
became known as [Tag
Soup](http://essaysfromexodus.scripting.com/whatIsTagSoup) since one
could not rely on proper HTML structure it was just treated as an
unstructured collection of tagged text. Permissive parsers such as
[Beautiful Soup](http://www.crummy.com/software/BeautifulSoup/) (Python)
and [Tagsoup](http://home.ccil.org/~cowan/XML/tagsoup/) (Java) were
developed to cope with the messy markup and give the developer as much
detail as possible from the page.

HTML5
=====

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


