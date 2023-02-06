# Templating in Javascript with Handlebars

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
    let text = "";
    let result = JSON.parse(this.responseText);
    for(let i=0; i<result.likes.length; i++) {
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

## Handlebars

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

The placeholders reference values passed in to the template
from Javascript code as an _object_.  The placeholder names used in the template
are _properties_ of the object.  

A template is a string value in Javascript so a simple example of using a template
would just use a string constant in the code.  Since we often want to include newlines
in our template, it is easiest to use the backtick string delimiters.
 Assuming that the Handlebars library
has been loaded, the following code fragment will create an HTML string that could
then be inserted into the page:

```Javascript
const source = `<div class=entry>
  <h1>{{title}}</h1>
  <p>
    {{body}}
  </p>
</div>`

const template = Handlebars.compile(source)
const context = {
    title: 'Hello World',
    body: 'This is the text.'
}
const content = template(context)
```

The first step is to _compile_ the template source string.  This generates a
function that can be applied to a context (an object) containing values for
the different placeholders. The result in the `content` variable will be:

```HTML
<div class=entry>
  <h1>Hello World</h1>
  <p>
    This is the text.
  </p>
</div>
```

## Writing View Functions

The Model-View-Controller structure that we talked about in the context of
Python applications is equally relevant to Javascript front-end applications. It is
a useful way to think about the structure of an application and separate out
the application logic, data access and interface generation componenets. Handlebars
can be used to write the View component by encapsulating the code above into
a view function and associating this with a template.

For example, if we have a data object representing a person:

```Javascript
const bob = {
    first_name: 'Bob',
    last_name: 'Bobalooba',
    dob: '1994-03-10',
    city: 'Sydney'
};
```

we can write a view function to display objects of this type.  First we
define a template that will generate the HTML we want to display:

```Javascript
const personTemplate = Handlebars.compile(`
    <div class="person">
        <dl>
            <dt>Name</dt> <dd>{{first_name}} {{last_name}}</dd>
            <dt>Date of Birth</dt><dd>{{dob}}</dd>
            <dt>City</dt><dd>{{city}}</dd>
        </dl>
    </div>
    `)
```

Then we write a function to realise the view passing in a selector that will be
used to select the HTML element to insert the result into and the person object
to be displayed:

```Javascript
function personView(id, person) { 
    const content = personTemplate(person);
    document.getElementById(id).innerHTML = content;
}
```

This function can then be called from our Controller code to include the
display of a particular person's data in the page in the element with id `userinfo`:

```Javascript
    const user = get_person(id)  /* assume some kind of model function */
    personView('userinfo', user)
```

## More on Handlebars Templates

You can learn more about the capabilities of Handlebars from
[the documentation](https://handlebarsjs.com/)
but there are a few further features worth pointing out here.

### Looping

The first is a way to handle collections of things  - eg. a list of people.  In a Bottle
template we'd write a `for` loop to iterate over the list and create the right HTML
content for each element.   In Handlebars we can do the same but it doesn't quite
look like a for loop.  

As an example, consider an array of people objects:

```Javascript
const members = [
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
```

To present this data we could use a template for a single person and call it
multiple times but Handlebars gives us an iteration construct that we can use.  
The following template and view function illustrates this.

```Javascript

const peopleTemplate = Handlebars.compile(`
    <div class="people">
       {{#each array}}
        <div class="person">
            <dl>
                <dt>Name</dt> <dd>{{first_name}} {{last_name}}</dd>
                <dt>Date of Birth</dt><dd>{{dob}}</dd>
                <dt>City</dt><dd>{{city}}</dd>
            </dl>
        </div>
        {{/each}}
    </div>
    `)

function peopleView(id, peopleArray) { 
    const content = peopleTemplate({array: peopleArray});
    document.getElementById(id).innerHTML = content;
}
```

Note that since the argument to the `template` function needs to be an object I've
created an in-line object with one property `array` to contain the array of people.
The template uses the [`#each`](https://handlebarsjs.com/guide/builtin-helpers.html#each)
construct to iterate over the array.

I can then use this view function to insert content based on the `members` global
variable into the element with id `target` as follows:

```javascript
peopleView('target', members)
```

Note that here there is no _loop variable_, we just refer to the properties of the
current object each time.  You can refer to `{{this}}` to get the current object and
insert it as a whole - for example if the input was a list of strings or numbers.  

The each block also supports special variables `@index` - the current loop index and
`@first` and `@last` which are booleans that are true on the first and last
iterations respectively.  

### Conditionals

There are two conditional blocks in Handlebars templates.  
An [`#if`](https://handlebarsjs.com/guide/builtin-helpers.html#if) block can be
used to test a value but expressions are not allowed. Hence the main use is to
handle cases where data is missing:

```Javascript
const personTemplate = Handlebars.compile(`
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
</script>`)
```

If you wanted to include a comparison test you'd need to do the test in your
view function before passing it to the template.  This reinforces the idea that
templates are about presentation and all of the logic should go into the
Javascript code.  For example:

```Javascript
function personView(selector, person) { 
    /* set a property on person */
    person.sydneyResident = person.city === 'Sydney'

    const content = personTemplate(person);
    document.getElementById(id).innerHTML = content;
}
```

Another conditional operator provides the opposite test with
[`#unless`](https://handlebarsjs.com/guide/builtin-helpers.html#unless):

```Javascript
const licenceWarningTemplate = Handlebars.compile(`
<div class="entry">
  {{#unless license}}
  <h3 class="warning">WARNING: This entry does not have a license!</h3>
  {{/unless}}
</div>`)
```

This block will be rendered if there is no value for `licence` or if the value is
'falsy' (`[]`, `""`, `null` or `[]`).  

There are a [few other block helpers](https://handlebarsjs.com/builtin_helpers.html) in
Handlebars but these are the main ones you will use.

### Partials

A very useful feature is the ability to use one template inside another.  In our people
example we might want to write one template for a person and then
re-use it in the list of people.  This can be done with
[partials](https://handlebarsjs.com/guide/partials.html#basic-partials) in Handlebars.
Here's a simple example that defines a partial template for a person:

```Javascript
Handlebars.registerPartial('person', '<li>Name: {{name}}</li>')

const peopleTemplate = Handlebars.compile(`
    <ul class="people">
       {{#each people}}
        {{> person}}
       {{/each}}
    </ul>
    `)
```

The effect of this is as if the partial template is just pasted into the
containing template - the variables it can refer to are those in the
main template.
