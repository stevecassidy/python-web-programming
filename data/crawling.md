

Crawling the HTML Web
=====================



The Web for Machines
--------------------

The web was invented as a way of publishing documents for people to
read. The HTTP protocol was defined as a lightweight way of
communicating between a browser and a server to request documents and
later to submit form data to servers. However, fairly soon after the web
broke out of the CERN labs, people started writing programs to access
web documents. Some of the first programs were web crawlers that could
download whole chunks of the web so that you could read them offline
(remember this was when we didn't have smart phones or even widespread
home Internet). Later the search engines started to crawl the web to
index it and help people find information. Before too long people
started to *scrape* web pages for some of the data they contained -
events, inventory, contact lists - so they could load it into a regular
database and query it. Programmers were treating the web as a source of
data and using HTTP to access it.

To act as a web client, a program needs to be able to make HTTP
requests. So far we've seen how to write Python code to *accept*
requests using the Bottle framework. Python is also quite good at making
requests and has the
[urllib](https://docs.python.org/3/library/urllib.html) module to
support quite complex interactions with a web server. It can be very
simple to read the contents of a web page; we use the `urlopen` function
which behaves just like opening a file but takes a URL instead of a
filename as an argument. Here's an example of reading a web page from a
given URL and returning the content as a Python string:

```python
from urllib.request import urlopen

def get_page(url):
    """Get the text of the web page at the given URL
    return a string containing the content"""
    
    fd = urlopen(url)
    content = fd.read()
    fd.close()

    return content.decode('utf8')
     
```

Note the last line in this function that converts from the binary data
that is returned from the call to read into a regular Python string
using the UTF-8 encoding. This is necessary if we want to do any string
processing on the data that is returned.

This function could be used to 'download' a copy of a page for offline
viewing, but it could also be the basis of a simple 'web crawler'. A web
crawler is an application that follows links in web pages, and by doing
so gets access to a large number of web pages. It can be used as the
basis of a search engine or for downloading large chunks of web pages
for reading or analysis. The core idea is to first get the web page at a
URL, then scan the HTML page for links to other pages which you then add
to a growing list of URLs. The first job then is to write a function to
find the URLs in an HTML page. We'll look at a more sophisticated way to
do this shortly but a simple approach is to use a regular expression.
Here's some code that uses a regular expression to find URLS after first
getting the text of the page:

```python
def get_links(url):
    """Scan the text for http URLs and return a set
    of URLs found, without duplicates"""
    
    text = get_page(url)
    
    # look for any http URL in the page
    links = set()
    urlpattern = r"(https?\://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/[^<'\";]*)?)"
    
    matches = re.findall(urlpattern, text)
    
    for match in matches:
        links.add(match[0])
                
    return links
     
```

This function uses a Python `set` rather than a list as we only want to
have one copy of each URL in the list we collect. The URL pattern is a
reasonably good one but probably doesn't catch all URLs in a page. In
particular it won't get any *relative* URLs that don't start with
`http`. We use the `re.findall` function to find all matches for the
pattern in the page and then add them one by one to the result set.

The next step in writing a web crawler is just to call `get_links`
repeatedly to retrieve the links from a page, then choose a new URL and
repeat. If we did this without limit, the program would keep going for a
long time since we are never going to run out of links. So, as a
demonstration, here's a function that will keep collecting links until
it has more than a pre-determined number.

```python
def crawl(url, maxurls=100):
    """Starting from this URL, crawl the web until
    you have collected maxurls URLS, then return them
    as a set"""
    
    urls = set([url])
    while(len(urls) < maxurls):
        # remove a URL at random
        url = urls.pop()
        print("URL: ", url)
        links = get_links(url)
        urls.update(links)
        # add the url back to the set
        urls.add(url)
    
    return urls
     
```

Note that we use the `pop()` method on the set to remove a random URL
which we then add back to the set later. We print out a progress message
each time around the loop just so we can see which pages are being
requested. To tie this all together we can call the `crawl` function on
a starting URL and print out the resulting set of links:

```python
if __name__=='__main__':
    
    url = 'http://www.python.org/'
    links = crawl(url, 100)
    print("Collected ", len(links), " links:")
    for link in links:
        print(link)
    
```

When I run this it retrieves four or five URLs before reaching the limit
of 100 and returning. If you try this please take care that you don't
set the limit too high. You are generating automated traffic on the web
which can cause a heavy load on a server if left unchecked - your script
may be able to make many hundreds of requests a second, many more than
you would make from a browser. For this reason, your script could be
seen as an attempted attack on a site if it makes a large number of
requests. Please use care when running web crawling scripts.

This crawler isn't really doing anything very useful but it is able to
find as many web pages as you want as long as they are linked to the
starting page. To do something useful, we need to do a bit more work to
understand the pages that we are retrieving - rather than just scanning
for URLs. Understanding the pages might also help with finding those
relative URLs that we ignored in this version; so let's look at parsing
HTML to extract information.





Parsing HTML
------------

HTML is a formal language, we know that there are
[standards](http://w3.org/) that define how HTML pages should be
structured, the names of the elements that can be used and how they can
be nested within each other. This means that we should be able to
*parse* the page into an internal data structure to build an internal
representation of the page. This is exactly what your web browser must
do to render the page on the screen - parse the HTML to find the title,
headings, paragraphs and lists and then apply the CSS stylesheet to
determine the layout. Our requirement here is to be able to understand
the page structure to make extracting data from it more reliable.

An HTML page can be seen as a kind of *tree strucure*. It has one top
level element `<html>` that contains other elements (`<head>` and
`<body>`) which in turn contain other elements. The start and end tags
for these elements are supposed to be properly nested. Following this,
it is common for an HTML parser to scan the text of the page and build a
tree structure in memory. In many systems this is implemented as a
nested collection of objects and the representation is called the
Document Object Model or DOM. Once the page has been parsed into the
DOM, the programmer can find things within it. For example, find all of
the headings, find the first paragraph after the main heading or find
all of the anchor (`<a>`) tags in the document. The DOM parser takes
care of all of the details of the HTML tags in the document and allows
the programmer to work on a more logical structure.

There are DOM based HTML parsers in many languages. Most notably perhaps
is Javascript where the DOM is used to expose the internal structure of
the current HTML page to the in-page Javascript code. So a script that
wanted to change the text in the main heading could write:

```python
 headings = document.find_element_by_tag_name('H1');
 headings[0].innerHTML = "Hello World";
     
```

In Python, there are DOM based parsers available but the best interface
for HTML parsing is in a module called [Beautiful
Soup](http://www.crummy.com/software/BeautifulSoup/bs4/doc/). The name
of this module comes from the characterisation of HTML as found on the
web as *Tag Soup* rather than well structured, standards compliant
documents. Since anyone can publish on the web and since the quality of
software used to generate pages varies so much, we can't rely on HTML
pages sticking to the rules. Beautiful Soup is an HTML parser written to
be able to do a reasonable job on even poorly formatted HMTL text. The
interface provided by Beautiful Soup is similar to the common DOM
interface but has some more convenience methods.

### A Better Crawler

Let's look at an version of the `get_links` method above to make the web
crawler a bit smarter. This version will use Beautiful Soup to find all
of the anchor elements in the page and return the `href` attribute.

```python
from bs4 import BeautifulSoup

         
def get_links(text):
    """Scan the text for http URLs and return a set
    of URLs found, without duplicates"""
    
    # look for any http URL in the page
    links = set()

    soup = BeautifulSoup(text)
    
    for link in soup.find_all('a'):
        if 'href' in link.attrs:
            links.add(link.attrs['href'])
                
    return links
    
```

Here we use the `find_all` method on the soup object to find all of the
anchor elements in the document. This returns a list of element objects
that we then iterate over. If the anchor element has an `href` attribute
then we add it to the link set. This is a much neater solution than the
regular expression code and it will be much more reliable; all of the
complexity of the HTML is dealt with by Beautiful Soup.

The results from this code are a little different to before; since we
are harvesting all anchor links, we get relative as well as absolute
URLs. Here's a sample of the results from crawling
`http://www.python.org/`:

```
    /events/python-events/past/
    /downloads/
    http://trac.edgewall.org/
    http://blog.python.org
    /accounts/signup/
    https://wiki.python.org/moin/
    http://www.pygtk.org
    #content
    /events/python-user-group/past/
    #top
```

In addition to the http URLs we have relative URLs starting with `/` and
page-internal links starting with `#`. We can't just add these to the
list of links, we need to resolve them to full URLs first. Page-internal
links just refer to parts of the same page so there is no value in
adding them to the list of links. URLs starting with `/` are on the same
site as the original page so we can turn them into full URLs by adding
the domain part of the original URL. So `/downloads/` here becomes
`http://www.python.org/downloads/`. There is a function in `urllib` to
do this for us; `urllib.parse.urljoin` takes an absolute URL and a
relative one and returns the combined URL. So, we can modify `get_links`
to make use of this as follows:

```python
from urllib.parse import urljoin
         
def get_links(url):
    """Scan the text for http URLs and return a set
    of URLs found, without duplicates"""
    
    # look for any http URL in the page
    links = set()

    text = get_page(url)
    soup = BeautifulSoup(text)
    
    for link in soup.find_all('a'):
        if 'href' in link.attrs:
            newurl = link.attrs['href']
            # resolve relative URLs
            if newurl.startswith('/'):
                newurl = urljoin(url, newurl)
            # ignore any URL that doesn't now start with http
            if newurl.startswith('http'):
                links.add(newurl)
                
    return links
     
```

The code rejects any link that hasn't been resolved to an http URL, this
deals with special cases such as Javascript URLs and the page-internal
`#` URL.

### Extracting Information from a Page

Now that we can parse the page structure there are more options open to
us in extracting information from web pages. A very common requirement
is to find useful information in a page that could be stored in a
relational database for later query. This is known as *screen scraping*
since we are scraping structured data from the HTML designed to be
displayed on screen.

As an example, let's try to extract information about assignments from
the [COMP249 Unit
Guide](http://unitguides.mq.edu.au/unit_offerings/49056/unit_guide). The
unit guide is generated by an application that uses a standard template
for generating pages, this means that every unit guide has the same
structure and we can rely on this structure to find the information we
want. Looking at the HTML source for the appropriate section we have:

```HTML
<section id="assessment-tasks-section" class="section">
     <h2>Assessment Tasks</h2>

     <table class="table table-striped">
         <thead>
         <tr>
           <th>Name</th>
           <th>Weighting</th>
           <th>Due</th>
         </tr>
         </thead>
         <tbody>
           <tr class="assessment-task-row">
             <td class="title">
               <a href="#assessment_task_77482">Web Application Design</a>
             </td>
             <td class="weighting">
               5%
             </td>
             <td class="due">
               Week 4
             </td>
           </tr>
           ...
         </tbody>
       </table>
       ...
     
```

The HTML is very well structured using the HTML-5 `section` tag to
define sections and with a unique id `assessment-tasks-section` marking
the section we're interested in. We want to find this section and then
find the first table within the section. Then for each row in the body
of the table, we can get the three columns that correspond to the
assignment name, weighting and due date. Here is some code that will do
this using Beautiful Soup:

```python
def find_assignments(text):
    """Given the text of an HTML unit guide from 
    Macquarie University, return a list of the assignments for
    that unit as (name, weighting, due)"""
    
    soup = BeautifulSoup(text)
    
    # find the section that has the assignment table
    section = soup.find(id='assessment-tasks-section')
    
    # we want the first table in this section, then the tbody inside that
    # and we want all rows in the body
    tablerows = section.table.tbody.find_all('tr', 'assessment-task-row')
    
    result = []
    
    for row in tablerows:
        name = row.find('td','title').a.string.strip()
        weight = row.find('td','weighting').string.strip()
        due = row.find('td','due').string.strip()
        result.append((name, weight, due))
        
    return result
     
```

This example shows how to navigate the HTML document using the object
attributes provided by Beautiful Soup. The `find` and `find_all` methods
allow us to search the document tree for matching elements. To notation
`section.table` refers to the first table inside the section. Finally we
extract the content of the table cells using
`row.find('td', 'due').string` which finds the `td` element with class
`due` inside the row and returns the content of the element as a string.
Note that for the name, we need to look one level deeper inside the
anchor element to get the string content. Running this code over the
[unit guide linked
above](http://unitguides.mq.edu.au/unit_offerings/49056/unit_guide#assessment-tasks-section)
gives us:

```
    [('Web Application Design', '5%', 'Week 4'),
    ('Workshop exams', '16%', 'Week 3, 6, 9, 12'),
    ('Web Application', '20%', 'Weeks 7 and 10'),
    ('Report', '14%', 'Week 12'),
    ('Exam', '45%', 'TBA')]         
```      

Screen scraping is a very useful technique for extracting information
from web pages but it relies heavily on the structure of the web page
being stable. If the University were to redesign the layout of the unit
guide, the code may fail to find the relevant information and would need
to be re-written. If you also wanted to get information from unit guides
at other Universities, you would need to write a special extraction
function for each one and maintain them all separately. This can clearly
be done but is a fragile and labour-intensive process, especially when
we realise that the original source of this data was a relational
database. This brings us to thinking that there should be a better way
to make data available for machine consumption over the web. We'll look
at some solutions to that problem in the next chapter.



Controlling The Robots
----------------------

We've seen in this chapter how to write scripts to automate access to
web resources. As mentioned earlier, this is potentially quite annoying
and can in fact be dangerous as we can make many hundreds of requests
per second to a server that could become overloaded. Recall that the
server may just be serving static pages but these days it is quite
likely that it is generating content from a database. This means that
the server needs to do some work for each request and thousands of
requests may slow down a server. In some cases, generating a page can
take a lot of resources - imagine a page that displayed up to the second
weather readings that needs to query multiple remote sources to generate
each page. For this reason, we need some way to tell remote users that
it is not ok to automatically retrieve pages from a site with a script.
The
[`robots.txt`](http://en.wikipedia.org/wiki/Robots_exclusion_standard)
file is the mechanism that is used to do this.

The `robots.txt` file is placed in the document root of a web server so
that it is available at the URL e.g. `http://example.com/robots.txt`. It
contains a set of statements that define which URLs on a site should or
should not be accessed by one or more crawlers (robots). An example
`robots.txt` file (retrieved from http://www.mq.edu.au/robots.txt) is:

```
User-agent: SiteCheck-sitecrawl by Siteimprove.com
Allow: /images/

User-agent: *
Disallow: /archive/
Disallow: /cgi-bin/
Disallow: /Finance_Handbook/
Disallow: /images/
    
```

This example first has a rule for the robot that identifies itself as
*"SiteCheck-sitecrawl by Siteimprove.com"* saying that it is ok for it
to access any URL starting with `/images/`. There is then a rule for all
user agents that lists a number of URL prefixes that should not be
touched. This would include SiteCheck, so the effect of this is that
SiteCheck is given special permission to look in `/images` but no other
robot can.

An important point to note is that the rules in the `robots.txt` file
are entirely voluntary. In the scripts we wrote earlier in the chapter,
we did not refer to the robots file on the Python website. A well
behaved crawler will first access the `robots.txt` file on a site. If
there is no response to the request (for example,
http://unitguides.mq.edu.au/robots.txt) then we assume that any crawling
is ok. If there is a response then we should read the file and check
whether the URL we want to access is disallowed. Of course, if I'm an
Evil Web Crawler, I can just ignore this file all together.

Since the `robots.txt` file does not need to be followed, a website that
finds it is being inundated with requests from a particular crawler
needs to take other steps to block it. If the crawler uses a particular
User-Agent string then the server could be configured to disallow that.
Alternately if all of the requests come from a particular IP address
then that could be blocked. Ultimately if the source of the requests is
an attacker, it may be hard to block the traffic, but for scripts
written by people who just didn't know that they were supposed to follow
some rules, things can be done.

Understanding the `robots.txt` file would take some work, luckily as
Python developers the work has been done for us and we can use the
[`urllib.robotparser`](https://docs.python.org/3/library/urllib.robotparser.html#module-urllib.robotparser)
module to do it for us. This module will read the `robots.txt` file for
a site and then tell you whether or not you are allowed to retrieve a
given URL. We can use it to modify our implementation of `get_page` from
earlier in the chapter. First we write a function to check that the URL
we want to access is allowed:

```python
from urllib.parse import urljoin, urlparse
from urllib.robotparser import RobotFileParser

# Dictionary to save parsed robots.txt files
ROBOTS = dict()

def robot_check(url):
    """Check whether we're allowed to fetch this URL from this site"""
    
    netloc = urlparse(url).netloc
    
    if netloc not in ROBOTS:
        robotsurl = urljoin(url, '/robots.txt')
        ROBOTS[netloc] = RobotFileParser(robotsurl)
        ROBOTS[netloc].read()

    return ROBOTS[netloc].can_fetch('*', url)
```

This implementation takes care not to request the same robots file more
than once. We define a global dictionary `ROBOTS` and store the parsed
robots file in this using the network location (domain name plus port,
eg. www.mq.edu.au or localhost:8080) as a key. Before reading the robots
URL we check whether we have already stored one. If not, then we read
the robots file and store the result in the `ROBOTS` dictionary. This is
an example of *cacheing* of results to avoid having to do the same task
more than once; it also avoids sending repeated requests to the server
for the same URL.

The next step is to modify `get_page` to run the check before retrieving
the URL:

```python
def get_page(url):
    """Get the text of the web page at the given URL
    return a string containing the content"""
    
    if robot_check(url):
        fd = urlopen(url)
        content = fd.read()
        fd.close()

        return content.decode('utf8')
    else:
        return ''
    
```

After implementing this, we now have a well behaved robot crawler.

One final note. You will notice that the `robots.txt` file identifies
robots based on their `User-Agent` header. This is one of the standard
HTTP headers that every request should contain. Your browser uses this
to identify itself and a server can be configured to deliver different
content to different user agents. By default, the Python `urllib` module
identifies itself as `Python-urllib/3.4` (for Python 3.4), but it is
good practice to set the user agent to a unique value for your script.
To do this we can't use the simple `urlopen` function, but it's not too
much more complicated. We need to use a custom URL opener that is
configured to send a different user agent header. Here's a final version
of `get_page` that identifies our robot as "PWPBot":

```python
def get_page(url):
    """Get the text of the web page at the given URL
    return a string containing the content"""
    
    if robot_check(url):
        
        # open the URL with a custom User-agent header
        opener = urllib.request.build_opener()
        opener.addheaders = [('User-agent', 'PWPBot/1.0')]
        fd = opener.open(url)
        content = fd.read()
        fd.close()

        return content.decode('utf8')
    else:
        print("Disallow: ", url)
        return ''
```
