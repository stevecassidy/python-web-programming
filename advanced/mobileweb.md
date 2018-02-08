

Mobile Web Development
======================

The boom in smart phones equipped with constant internet access and
capable web browsers has opened up a new delivery platform for the web.
In contrast to desktop browsers, mobile phone and tablet based browsers
have less screen space but add new capabilities like geo-location and
touch based input. Mobile web users may also have different tasks in
mind, whether it is finding search results near their location or
getting quick answers to quiz questions. All of this together means that
mobile web development presents us with a new set of problems in web
design and development.

There's an interesting comment in the [W3C Mobile Web Best Practices
Guidelines](http://www.w3.org/TR/mobile-bp/) which emphasises the idea
that a mobile site should not just be a more restricted version of the
full site. It calls this *One Web*:

> One Web means making, as far as is reasonable, the same information
> and services available to users irrespective of the device they are
> using. [W3C](http://www.w3.org/TR/mobile-bp/#OneWeb)

This idea suggests that the way that we design a mobile website should
be to work out the appropriate representation of a resource on the
mobile device, and then find out how to deliver that when appropriate.
Of course, there will always be web applications that are built mainly
to serve the mobile audience, and there will be resources such as high
bandwidth video or large image collections that are difficult to display
properly on small devices. But the One Web idea is a good guiding
principle to consider when designing the mobile version of a website or
web application.



Approaches to Mobile Web Design
-------------------------------

There are a number of ways to think about the design of a mobile website
- or rather the design of a website that is expected to be used from
mobile devices. To some extent, the approach to mobile web design is
evolving as the proliferation of mobile devices progresses. When mobile
devices first started to appear there was no specific attempt to design
for them; instead, browser vendors tried to adapt browsers to the small
screen size so that users could zoom in to sections of the page or
provide [proxy services to compress and
adjust](http://times.usefulinc.com/2004/06/15-opera) pages for mobile
delivery. Since that time, as mobile browsers have become more capable
and widespread, designers first looked at how best to adapt desktop
pages for mobile delivery and more recently, have started to design
first for the mobile platform with the desktop as a secondary target.

This section will discuss a number of different approaches to mobile
design, following roughly a chronological path. We must remember here
that the mobile web is really only a few years old (as I write in 2013)
and so the consensus on the best way to approach the design problem is
likely to evolve further in coming years. The ideas presented here are
not necessarily mutually exclusive; any one design project might make
use of ideas from all of them.

The different approaches relate to the relationship between mobile and
desktop versions of websites, rather than how design elements are used
in mobile design.

### Separate Mobile Website

Perhaps the easiest solution to design for mobile is to build an
entirely separate website for mobile browsers to the desktop site. We'll
see below how the server might be able to tell the difference between
the two, but the assumption is that a mobile browser will be served
different pages to a desktop browser. Given this, the designer has
complete flexibility in how to design the mobile experience without
having to use any common content or code between the two sites. The
designer can assume a small screen size and touch interaction in the
mobile site and work out how to best present an application in that
format.

There is a temptation in this approach to violate the *One Web* mantra
referenced above and develop a mobile site that provides only what the
designers consider suitable material for the mobile web user - for
example, things you might want to do on the go. While this can be quite
attractive in being able to provide customised mobile content, it does
turn the mobile user into a restricted user of the site. If they know
that your site has a piece of information but you didn't think mobile
users would be interested, then they are cut out. They would need to
revert to the desktop version of your site (assuming that you allow that
as an option for mobile users).

### Graceful Degradation

Graceful Degradation is a general approach to web design that says that
a design should still be useable if some of the browser features that it
relies on are not present. Before the mobile web became an issue, the
same principle was applied to desktop web design when talking about
support for older browsers that had less support for CSS and HTML
standards. The idea is to design for the newer browsers and more
advanced features but ensure that the page is still usable in less
capable browsers. In the mobile context, we'd ensure that whatever
desktop features were used in the application, it would still work on
the mobile platform even if it didn't look so good.

An example of what might be done might be an application that makes use
of mouse hover events to show help text when a user is filling out a
form. Since the mobile platform doesn't have a mouse, the hover event
isn't supported and this would not work. In order to degrade gracefully,
the design should at least make the help text available in some form to
the mobile user - maybe placing it below the form field. In this way,
the mobile user is not disadvantaged but the page is not designed to
optimise their user experience. To achieve this outcome, the help text
could be inserted by Javascript when a mobile browser is detected. The
main point is that the site design is approached from a desktop
perspective and testing on mobile browsers is done at a late stage with
fixes being added where necessary to make it work.

Clearly this approach treats the mobile browser as a second class
citizen. However, it does try to ensure that the same information and
services are available to the mobile user as to the desktop user (One
Web).

### Progressive Enhancement

Almost the opposite approach to Graceful Degradation is Progressive
Enhancement. Whereas GD designs for the most capable browser and ensures
things will work elsewhere, PE designs for the lowest common denominator
and adds features based the browser's ability to support them. In the
mobile context, the core design would be made to work for both mobile
and desktop browsers while being optimised for neither one. Additional
features are then added using more advanced features that may be
available on the platform.

To continue the example from the previous section, the PE approach would
be to design a form that will work on any browser, mobile or desktop,
and then add enhanced support for either mouse based or touch based
interfaces. This approach immediately levels the playing field between
the different platforms because the designer is forced to think about
the lowest common workable design as a real entity and then plan
enhancements. The provision of help for the form in a better way is now
a design problem that can be addressed for each platform; the fact that
it needs to be considered as a separate problem encourages the two
platforms to be dealt with more equally. Even if the mobile platform is
ignored for enhancement, it still inherits the solid core design.

The core design in a PE project is likely to be based on good, semantic
HTML that provides suitable hooks for CSS and Javascript to work with.
Using semantic HTML is appropriate because it uses the right markup for
the document structures being encoded. If this is done then enhancements
can be applied semantically too - for example, lists with a certain
class can be made to expand and contract via the mouse or touch input.
This encourages a more consistent design style where design decisions
are made based on the semantics of the content rather than as ad-hoc
elements in a specific page.

One of the keys to progressive enhancement is the detection of browser
features. We'll see below how we can detect whether a request is coming
from a mobile or desktop browser, and this might be the primary cue for
particular customisations in the mobile space. However there are many
other browser features that are implemented to varying degrees on
different platforms. One common approach is to use Javacript to detect
browser features. This is more reliable than guessing based on the
platform type because Javascript code can run in the browser to test for
the presence of a certain feature. This will then continue to work when
a particular vendor adds functionality to their browser. Compare this
with the old-style browser detection which tries to block access to
older browsers but ends up blocking Chrome and Safari as well because
they weren't around when the code was written. Since feature detection
is a common task, there are libraries to help. One of the most useful is
[Modernizr](http://www.modernizr.com/) which is an HTML5 feature
detection library. This can be used to detect individual features that
you might want to use in an interface, for example, geolocation:

```javascript
if (Modernizr.geolocation) {
  // let's find out where you are!
} else {
  // no native geolocation support available :(
  // try geoPosition.js or another third-party solution
}
    
```

(example from [Dive Into HTML5 | Detecting Browser
Features](http://diveintohtml5.info/detect.html))

Note that this is a client side technique which fits with the
progressive enhancement idea that the core content page is served up the
same to all devices and client side code runs to customise it for
different browsers or platforms.

Here are a couple of references for further reading: [Understanding
Progressive
Enhancement](http://alistapart.com/article/understandingprogressiveenhancement)
on ALA; [Graceful Degradation versus Progressive
Enhancement](http://docs.webplatform.org/wiki/tutorials/graceful_degradation_versus_progressive_enhancement)
on Web Platform Docs.

### Responsive Design

The approaches described so far have provided different features or
design elements based on whether the platform was desktop or mobile - a
binary distinction. Another approach called Responsive Design removes
this binary divide and instead concentrates on adapting the design to
the size of the browser window. The main technique that enables this is
the [CSS3 media query](http://www.w3.org/TR/css3-mediaqueries/) which
allows the designer to select different stylesheets based on various
properties of the display such as width, height and resolution.

In some ways, responsive design is an example of progressive enhancement
since it starts with solid semantic HTML markup and then adds a
stylesheet appropriate to the display size. It avoids the distinction
between mobile and desktop and so means that designs will work on
whatever new platform might emerge between these two extremes. A
responsive design enables a user to view the mobile version of a site on
the desktop just by shrinking the browser down to a mobile-like size.

As an example of a media query the following code loads a default
stylesheet for all 'screen' displays and a second stylesheet for those
screens with a width of less than 480px.

```HTML
 <link rel="stylesheet" type="text/css" media="screen" href="default.css">
 <link rel="stylesheet" type="text/css"
  media="screen and (max-device-width: 480px)"
  href="smaller.css" />
    
```

Using this technique we can have a base level stylesheet (eg. to define
default colours and fonts) and then a specific stylesheet for browser
windows of different sizes. As a designer, I can then work on these
different browser sizes explicitly to design for each of them.

The responsive design approach was perhaps first described in
[Marcotte's ALA
article](http://alistapart.com/article/responsive-web-design).





Browser Detection
-----------------

One of the first design decisions when adapting an existing site for use
by mobile browsers is whether to split the site into mobile and desktop
versions. In one approach, the mobile version of the site is given its
own URL space to differentiate it from the main site. So, for example,
`http://example.com/` might present its mobile site at
`http://mobile.example.com/`. The alternative approach is to use the
same URLs for both sites but configure the web server to return
different content to mobile or desktop browsers. There are advantages in
each of these approaches which we will discuss later. This section is
concerned with how they might be implemented.

The first part of the solution for both approaches is to know whether a
request has come from a mobile or desktop browser. The information
required to make this decision is contained in the HTTP\_USER\_AGENT
field in the WSGI environment which is derived from the User-Agent HTTP
header. The format of this field is simple, it states the browser
product name and version and the browser rendering engine. For example,
"Mozilla/5.0 AppleWebKit/536.5". However, the story is a little more
complicated since websites have historically used the user agent string
to deliver more advanced features and during the 'browser wars' in the
1990s it was common for Internet Explorer to claim to be Mozilla in its
user agent string so that IE users would see advanced content. This
continues today so that the user agent string for Internet Explorer 8
is:

-   Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)

Note the word 'compatible', the information in brackets after the
product name is a comment which is used to add more information on the
product. Here it is the only place that the actual product name appears.

Back to the problem of identifying mobile browsers, here are the user
agent strings for some common mobile browsers:

-   **iPhone 4**: *Mozilla/5.0 (iPhone; U; CPU iPhone OS 4\_3\_2 like
    Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko)
    Version/5.0.2 Mobile/8H7 Safari/6533.18.5*
-   **iPad**: *Mozilla/5.0 (iPad; U; CPU OS 3\_2 like Mac OS X; en-us)
    AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4
    Mobile/7B334b Safari/531.21.10*
-   **Android Phone**: (Samsung Galaxy): *Mozilla/5.0 (Linux; U; Android
    2.3.3; en-au; GT-I9000 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML,
    like Gecko) Version/4.0 Mobile Safari/533.1*
-   **Android Tablet**: (Acer A501): *Mozilla/5.0 (Linux; U; Android
    3.2.1; en-us; A501 Build/HTK55D) AppleWebKit/534.13 (KHTML,
    like Gecko) Version/4.0 Safari/534.13*
-   **Android Tablet, Firefox browser**: *Mozilla/5.0 (Android;
    Tablet; rv:10.0.4) Gecko/10.0.4 Firefox/10.0.4 Fennec/10.0.4*

Note that the platform is clearly indicated in the user agent string but
that there is no easy way to tell the difference between an Android
phone and tablet when using the built in browser, unless you know the
model names of each. Interestingly, the Firefox browser on the tablet
indicates that it is a tablet.

Based on this, it is relatively simple to write Python code to look at
the user agent string and determine what kind of browser is making a
request. Here's a simple example that just accounts for the three common
mobile platforms:

```
def browser_type(environ):
    """Determine the browser type based on the USER_AGENT
    setting in the environment. Return a tuple
    (mobile, type) where mobile is True if this is a mobile
    (phone, tablet) browser and False otherwise and type
    is a descriptive string: iphone, ipad, android, desktop
    """
    
    user_agent = environ['HTTP_USER_AGENT']
    
    patterns = {'ipad': 'iPad',
                'iphone': 'iPhone',
                'android': 'Android',
                }
    
    # scan for known mobile browsers
    for id in patterns.keys():
        if user_agent.find(patterns[id]) >= 0:
            return (True, id)
            
    # no mobile browser found
    return (False, 'desktop')  
  
```

This is a very basic solution that doesn't account for many mobile
browsers. Although iPhone/iPad and Android account for a large part of
the mobile market share, there are other platforms and even other
browsers on these platforms. In general, a more comprehensive solution
is needed and this is provided by a number of third party packages such
as [detectmoblebrowsers](http://detectmobilebrowsers.com/) and
[mobile.sniffer](http://pypi.python.org/pypi/mobile.sniffer). The first
of these just includes a big regular expression pattern that will match
most mobile browser user agent strings; code is available in many
languages to use this regular expression. The mobile.sniffer module is a
little different as it makes use of a number of different browser
detection modules. One of these, [WURFL](http://www.scientiamobile.com/)
provides a device database that no only detects the appropriate browser
type but returns a set of descriptive fields such as screen resolution
and other browser capabilities. A similar service is provided by
[DeviceAtlas](http://deviceatlas.com/) on a commercial basis. A major
advantage of these alternatives is that the device database is updated
regularly so that new platforms are sure to be included as they are
introduced.

### Redirecting to Mobile Site

If we are serving the mobile website via a different URL then there is a
question of how a mobile user gets access to the appropriate version. A
simple solution would be to include a link to the mobile site from every
page so that a mobile user could select it and perhaps add it as a
bookmark. However, this requires action on the part of the user and a
better alternative is to redirect the user to the mobile version of the
site when the first request from a mobile browser is received. Once this
redirect has taken place, the user will be browsing the mobile URL space
and will stay within the mobile site.

Using the browser detection code shown above, this example WSGI
application will redirect the user to an alternate URL if the request
comes from a mobile browser. If the request is not from a mobile
browser, it is handled by another WSGI procedure `desktop`.

```
def mobile_redirect(environ, start_response):
    """WSGI application to detect what kind of browser
    is being used for a request"""
    
    user_agent = browser_type(environ)
    mobile_url = "http://m.example.org/"
    
    if user_agent[0]:
        headers = [('content-type', 'text/plain'), 
                    ('location', mobile_url)]
        start_response("303 See Other", headers)
        return ["See Other: ", mobile_url]
    else:
        return desktop(environ, start_response) 
  
```

If we are serving the mobile website using the same URL space as the
desktop site then the server software must determine the appropriate
browser type for every request that is received. Within a WSGI
application, this can be handled by using the `browser_test` procedure
to identify the browser whenever a decision needs to be made. This might
be, for example, when the page template is chosen for any given page.

If we are using browser sniffing to determine which version of the site
to serve there is the possibility that we've got it wrong. In either of
these approaches it should be possible for the user to select to use the
desktop version of the site. This can be done by providing a link to a
specific URL that will force the use of either the mobile or desktop
versions of the site. To ensure that the user's choice is remembered,
the application can return a cookie to the browser that will persist
until the end of the browser session.





Viewing the Mobile Web
----------------------

Since web applications will use the User Agent header to decide what
kind of browser they are talking to, it follows that we can fool a site
into thinking that we are a mobile browser by changing this header. In
Apple's Safari browser there is an option in the default Develop menu
that allows you to select between some User Agent settings -
particularly between various Apple products like iPhone and iPad. In
Chrome, there are a number of User Agent switching extensions, for
example the [Ultimate User Agent
Switcher](https://chrome.google.com/webstore/detail/ljfpjnehmoiabkefmnjegmpdddgcdnpo).
Using the Safari option, I can view the mobile version of the
[SMH](http://www.smh.com.au/) website which shows the page below:

<div class="figure">

![Screenshot of Safari browser showing the mobile version of
smh.com.au](safari-mobile-smh.png)



If you are developing web content for mobile devices this is an
excellent first testing tool to see what a page will look like in a
mobile browser. You can resize the window to approximate the screen size
of a phone and test your site with all of the tools available on the
desktop. However, it is not a substitute for thorough testing on the
mobile platform itself. Remember that the browser will be different on
the mobile device, so real testing on devices should be a core part of
any development cycle.





Mobile Browser Capabilities
---------------------------

Early web browsers on mobile devices were very limited due to the
limited processing power, screen resolution and network bandwidth of the
devices. More recently, phones and tablets are becoming more powerful
and have constant, high bandwidth network connectivity. This has led to
the development of mobile browsers that are almost as capable as their
desktop counterparts. The primary difference is the screen size and
input modalities on mobile devices.

It's worthwhile being aware of the mobile browser landscape. There is a
good graph shown at
[statcounter.com](http://gs.statcounter.com/#mobile_browser-ww-quarterly-200804-201202)
(as of May 2012) which shows that the current dominant browsers with
around 20% market share each are the built in browsers on iPhone and
Android and the independent Opera Mobile/Mini browser which has versions
for iPhone, Android, Blackberry and Nokia S60 platforms. Lower down on
the graph come the built in Nokia browser and the third party UC
Browser, both at around 10%. The once dominant Blackberry browser sits
at 5% with the remainder going to the iPod Touch and the Netfront
browser. Interestingly, the bulk of these browsers are based on the
WebKit rendering engine (which also forms the core of the Chrome and
Safari desktop browsers).

When designing mobile-specific web applications, we should aim to be
compatible with the majority of mobile devices while not hurting
accessibility from the less widely used browsers. This means that we can
design for the three main platforms (iPhone/iPod Touch, Android and
Opera) while being aware of how our application behaves on UC Browser,
Nokia and Blackberry.

### HTML, CSS and Javascript

All of the major mobile browsers are based on WebKit which means they
have very good support for the latest HTML, CSS and Javascript
standards. Apple, on their developer website, suggest that you use [W3C
standard web technologies rather than
plugins](https://developer.apple.com/library/safari/#technotes/tn2010/tn2262/_index.html),
since the iPad and other mobile platforms do not support the same
plugins as desktop browsers. The main plugin you might want to use is
Adobe Flash, which is not supported on the IOS platform and is starting
to dissapear from the Android platform. This lack of universal support
means that it is generally better to use alternative HTML/CSS/JS
technologies rather than Flash where possible in mobile designs. In
particular, the major browsers will support many of the new HTML5
features such as the audio and video tags and offline storage.

### Touch Based Interface

An important feature of most mobile devices is the use of touch screens
rather than a mouse to select links and scroll the page. This has an
effect on how the user interacts with the page, but also changes the
meaning of some CSS and Javascript events will change. Some browsers
also introduce new events specific to the touch based interface.

The CSS selector `:hover` can be used on a desktop browser to change the
style of an element if the mouse is hovering over it. You can use this
to style buttons or menu items to give feedback in your interface. In a
touch based interface there is no mouse so the hover event will not
trigger this CSS rule. Hence your interface should not rely on
information that is only revealed via the hover event.

Similarly, the Javascript events `mousemove`, `mouseover` and `mouseout`
will generally not work on a mobile browser. This can be significant as
they are often used to present help text in a pop-up 'ballon'. In a
mobile web application, this will never trigger and the user will not be
able to access the help text.

While these events are not available, the iPhone and Android browsers
add new events that trigger on various touch based actions. These are
`touchstart`, `touchmove`, `touchend`, and `touchcancel`. Support for
these is not broad ( [see this report](http://caniuse.com/touch)) but
might be useful when targeting specific user communities.

### Geo-Location

[Geolocation](http://buildmobile.com/geolocation-in-the-browser/) is a
W3C standard interface to location data via Javascript. If the user
agrees, Javascript running in the page has access to location data
derived from whatever sources are available to the device. This can
include GPS, cellular location, wi-fi based location or just an
approximate location based on the machine's IP address. The page linked
above gives examples of how to use this interface from Javascript and
embeds some examples. Since I'm on my desktop machine writing this, it
shows that I'm in Sydney, Australia but doesn't know where in Sydney I
am.

Geolocation offers the possibility of new kinds of application on mobile
devices, not just adaptations of the desktop web. Authors are exploiting
this to provide location aware services such as local search and social
applications.





Mobile Web Usability
--------------------

A related issue is the use of text input on mobile devices. Touch
devices usually have a soft keyboard that pops up whenever text input is
required. However, typing is often slow on a small device and your
interface shouldn't rely on long or complex text input if possible. Web
applications designed for mobile devices should emphasise choosing from
lists rather than typing where appropriate.







Mobile Website vs. Native Application
-------------------------------------

look at the things a web appliciation can't do on a phone native app
that's just a wrapper around HTML+CSS+JS true native app that presents
web derived content



[![Creative Commons
License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)\
<span dct="http://purl.org/dc/terms/"
href="http://purl.org/dc/dcmitype/Text" property="dct:title"
rel="dct:type">Python Web Programming</span> by <span
cc="http://creativecommons.org/ns#" property="cc:attributionName">Steve
Cassidy</span> is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/).
