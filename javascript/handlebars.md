Templating in Javascript with Handlebars
==

When building a web application with Python on the server side we used the Bottle
template system to generate HTML pages.   This formed the **View** part of the MVC
architecture and meant that we could separate out the design of the page from 
the logic of the application and the database access layer.   The template
is HTML code with bits of Python used only to insert data into the page. 
This provides a good alternative to generating HTML code as part of the 
Python application; this can lead to messy code and makes it hard to see where
each part of the page comes from.

As we move towards front-end based applications that construct HTML pages in the 
browser, we started by reverting to the model of generating HTML as part of
the output of our code. For example in this code from [an earlier chapter](ajaxexample.md):

```javascript
    var text = "";
    var result = JSON.parse(this.responseText);
    for(var i=0; i<result.likes.length; i++) {
        text += "<li>" + result.likes[i] + "</li>";
    }
    document.getElementById('things').innerHTML = text;
```

The code is again messy and makes it harder to see how the final HTML 
fragment comes together. It is clearly desirable to use some kind of templating
engine again from Javascript.  However, the requirements now are different; when
we are constructing pages on the server side we construct the entire HTML 
page before delivering it to the client.  In Javascript we are usually 
updating a part of the page with new data to display in response to 
interactions.   So, rather than needing a templating system for whole
pages we want something we can use to create fragments of pages.  

Handlebars
---

[Handlebars](https://handlebarsjs.com/) is a templating system for Javascript. It is
an extended implementation of the [Moustache](https://mustache.github.io/) family of
templating systems which are available in many langauges (there is an official Javascript
implementation of Moustache but Handlebars has
[a few advantages](http://nimbupani.com/mustache.html)). The name comes from
the use of curly braces `{{   }}` to delimit variables to be inserted into 
the template. This will be familiar from our use of the Bottle templating engine, however
whereas Bottle templates allowed you to include Python code in the template, Handlebars
is deliberately more limited in what templates are able to do.  We are limited
to basic conditionals (if statements) and loops over collections.

Here is an example Handlebars template:

```HTML
<div class=entry>
  <h1>{{title}}</h1>
  <p>
    {{body}}
  </p>
</div>
```

As with a Bottle template, the placeholders reference values passed in to the template
from Javascript code.  Where in Python we passed a _dictionary_ into the template, 
in Javascript we pass an _object_.  The placeholder names used in the template
are _properties_ of the object.  

A template is a string value in Javascript so a simple example of using a template
would just use a string constant in the code.  Assuming that the Handlebars library
has been loaded, the following code fragment will create an HTML string that could
then be inserted into the page:

```Javascript
var source = "<div class=entry><h1>{{title}}</h1><p>{{body}}</p></div>"

var template = Handlebars.compile(source)
var context = {
    title: 'Hello World',
    body: 'This is the text.'
}
var content = template(context)
```
Note that the template source string has been written in one line here
because Javascript doesn't allow newlines in strings.

The first step is to _compile_ the template source string.  This generates a
function that can be applied to a context (an object) containing values for 
the different placeholders. The result in the `content` variable will be:

```HTML
<div class=entry><h1>Hello World</h1><p>This is the text.</p></div>
```

Working with Templates
--

Handlebars provides the basic mechanism for using templates in Javascript
but we need to develop a way of working with this as part of an application. 
Recall that the goal was to keep the Javascript code separate from the 
HTML templates.  Keeping templates in strings does not achieve this but if we
could store the template in the HTML file this would go some way to achieve
this goal.  

The key to storing templates in the HTML file is using the `<script>` tag to
contain the template in an HTML page. The contents of a script tag
are not parsed by the HTML parser in the browser, instead they are treated
as a string but remain accessible from the DOM.   So, we can include the 
following fragment in the HTML page:

```HTML
<script id=entry-template type=text/x-handlebars-template>
    <div class=entry>
      <h1>{{title}}</h1>
      <p>
        {{body}}
      </p>
    </div>
</script>
```

Note that the type attribute here (`text/x-handlebars-template`) is not
meaningful to the HTML parser or the browser. It's recommended by the 
Handlebars developers but is effectively just a made-up name.  The main
thing is that it is not `application/javascript` which would instruct
the browser to try to execute the block as Javascript code.

The Javascript code can now retrieve this from the page and compile it
as a Handlebars template.  We'll use jQuery here to access the template
in the page:

```Javascript
var source = $('#entry-template').text()
var template = Handlebars.compile(source)
var context = {
    title: 'Hello World',
    body: 'This is the text.'
}
var content = template(context)
```

The final step would be to insert the generated HTML into the page. We can use
jQuery to do this as well:

```Javascript
$('#target').html(content)
```

Writing View Functions
--

The Model-View-Controller structure that we talked about in the context of
Python applications is equally relevant to Javascript front-end applications. It is
a useful way to think about the structure of an application and separate out
the application logic, data access and interface generation componenets. Handlebars
can be used to write the View component by encapsulating the code above into
a view function and associating this with a template. 

For example, if we have a data object representing a person:

```Javascript
var bob = {
    first_name: 'Bob',
    last_name: 'Bobalooba',
    dob: '1994-03-10',
    city: 'Sydney'
}
```

we can write a view function to display objects of this type.  First, a template
is included in the HTML page:

```HTML
<script id="person-template" type="text/x-handlebars-template">
    <div class="person">
        <dl>
            <dt>Name</dt> <dd>{{first_name}} {{last_name}}</dd>
            <dt>Date of Birth</dt><dd>{{dob}}</dd>
            <dt>City</dt><dd>{{city}}</dd>
        </dl>
    </div>
</script>
```

Then we write a function to realise the view passing in a selector that will be
used to select the HTML element to insert the result into and the person object
to be displayed:

```Javascript
function personView(selector, person) {
    var template = Handlebars.compile($('#person-template').text())
    var content = template(person)
    $(selector).html(content)
}
```

This function can then be called from our Controller code to include the
display of a particular person's data in the page in the element with id `userinfo`:

```Javascript
    var user = get_person(id)  /* assume some kind of model function */
    personView('#userinfo', user)
```

More on Handlebars Templates
--

You can learn more about the capabilities of Handlebars from [the documentation](https://handlebarsjs.com/)
but there are a few further features worth pointing out here. 

### Looping 

The first is a way to handle collections of things  - eg. a list of people.  In a Bottle
template we'd write a `for` loop to iterate over the list and create the right HTML
content for each element.   In Handlebars we can do the same but it doesn't quite
look like a for loop.  

As an example, consider a list of people objects and a view function:

```Javascript
var members = [
    {
        first_name: 'Bob',
        last_name: 'Bobalooba',
        dob: '1994-03-10',
        city: 'Sydney'
    },
    {
        first_name: 'Mary',
        last_name: 'Contrary',
        dob: '1994-02-10',
        city: 'Sydney'
    },
    {
        first_name: 'Jim',
        last_name: 'James',
        dob: '1983-12-11',
        city: 'Melbourne'
    }
]

function peopleView(selector, people) {
    var template = Handlebars.compile($('#people-template').text())
    $(selector).html(template({people: people})
}
```

Note that since the argument to the `template` function needs to be an object I've 
created an in-line object with one property `people` to contain the list of people.
The template must now present all of the entries in the list. This can be done
in Handlebars using the `#each` block helper. For example:

```HTML
<script id="people-template" type="text/x-handlebars-template">
    <div class="people">
       {{#each people}}
        <div class="person">
            <dl>
                <dt>Name</dt> <dd>{{first_name}} {{last_name}}</dd>
                <dt>Date of Birth</dt><dd>{{dob}}</dd>
                <dt>City</dt><dd>{{city}}</dd>
            </dl>
        </div>
        {{/each}}
    </div>
</script>
```

Note that here there is no _loop variable_, we just refer to the properties of the
current object each time.  You can refer to `{{this}}` to get the current object and
insert it as a whole - for example if the input was a list of strings or numbers.  

The each block also supports special variables `@index` - the current loop index and 
`@first` and `@last` which are booleans that are true on the first and last
iterations respectively.  

### Conditionals

There are two conditional blocks in Handlebars templates.  An `if` block can be
used to test a value but expressions are not allowed. Hence the main use is to 
handle cases where data is missing:


```HTML
<div class="person">
<script id="person-template" type="text/x-handlebars-template">
    <div class="person">
        <dl>
            <dt>Name</dt> <dd>{{first_name}} {{last_name}}</dd>
            <dt>Date of Birth</dt><dd>{{dob}}</dd>
            {{#if city}}
            <dt>City</dt><dd>{{city}}</dd>
            {{#else}}
            <dt>City</dt><dd>No City Recorded</dd>
            {{/if}}
        </dl>
    </div>
</script>
</div>
```

If you wanted to include a comparison test you'd need to do the test in your 
view function before passing it to the template.  This reinforces the idea that
templates are about presentation and all of the logic should go into the 
Javascript code.  For example:

```Javascript
function personView(selector, person) {
    var template = Handlebars.compile($('#person-template').text())
    /* set a property on person */
    person.sydneyResident = person.city === 'Sydney'
    $(selector).html(template(person))
}
```

Another conditional operator provides the opposite test with `#unless`:

```HTML
<div class="entry">
  {{#unless license}}
  <h3 class="warning">WARNING: This entry does not have a license!</h3>
  {{/unless}}
</div>
```
This block will be rendered if there is no value for `licence` or if the value is
'falsy' (`[]`, `""`, `null` or `[]`).  

There are a [few other block helpers](https://handlebarsjs.com/builtin_helpers.html) in
Handlebars but these are the main ones you will use. 

It's also possible to [extend Handlebars](https://handlebarsjs.com/)
with your own helpers in a few different ways. You can define helper functions
to generate particular display elements that can be re-used and also define new
block helpers to achieve different effects.  


