# Forms and Javascript

This chapter discusses handling user interaction via forms in Javascript.  Forms
are the basis for a lot of interaction in web applications as they provide the
input elements that users can interact with: text input, buttons, checkboxes,
drop-down selections.  

The original intention of the HTML form was to gather user input so that it
could be submitted via an HTTP request back to the server.  This is still the
default action in an HTML form, however, in a modern web application,
we typically want to interrupt this default behaviour and handle the form
data in the front-end.  Handling form data may result in a request being
sent back to a server but it could also just result in some action on the front
end.  We want to know how to write Javascript code to take control of forms in
our web application.

## Forms Recap

An HTML form consists of a `<form>` element that contains one or more input
elements. For example:

```HTML
<form id="sample-form"> 
  <input type="text" name="username" placeholder="User Name">
  <input type="password" name="password">
  <input type="checkbox" name="agree" value="yes" checked>
  <select name="colour">
    <option value="red">Red</option>
    <option value="green">Green</option>
    <option value="blue">Blue</option>
  </select>
  <input type="submit" value="Submit">
</form>
```

Each of the input elements is presented in a different way to the user and supports
a different kind of interaction, from mouse clicks to text entry.  

Once the user has carried out the interaction, the form fields contain data.
Each input element has a `value` attribute that holds the value entered into
the field or selected by the user.

The default action when the form is submitted (usually by clicking the `Submit`
button) is to generate an HTTP request.  Since this form has no `method`
attribute, this will be a `GET` request and since it has no `action` attribute,
the request will go to the same URL that this page was delivered from.  
The `GET` request would encode all
of the form data in the URL, e.g. `https://example.com/page?usernam=Steve&password=chicken...`.
The server can then process this request as it sees fit and return a new page to
the browser.

## Javascript Takes Over

In a single page web application, the interaction with the user is managed by Javascript
code running in the browser.   Such an application might use a form to interact with
the user but then carry out a local operation in response to the form rather than
sending off a request to a server.  For example, imagine a form that can be used
to set the background colour of the page (or more realistically, switch between dark
and light stylesheets, but we'll simplify the example here).

```HTML
<form id="colour-change-form">
  <input name="colour" type="text">
  <input type="submit" value="Change Colour">
</form>
```

We now want to attach a Javascript event handler to this form that will be called
when the user clicks on the submit button.

```Javascript
let form = document.getElementById('colour-change-form');
form.onsubmit = (event) => {
    ...
}
```

If the user enters a colour name in the form and clicks "Change Colour" then the
default action would be to send a new `GET` request. The first thing the 
submit handler needs to do is prevent this default action by calling
`event.preventDefault()` (where `event` is the event object passed in
to the event handler).

The next step is to find the form and the colour value entered by the user.
The form element will be the `target` attribute of the event since this event
originated by interaction with the form.   To get the colour value, we
find the input element within the form and get it's `value` property. In
this example I've used `querySelector` to find the input but you could
also use `getElementById` if it had an id.

```Javascript
form.onsubmit = (event) => {
    event.preventDefault();
    const form = event.target; 
    const colour = form.querySelector('[name="colour"]').value; 
    
}
```

The final step is to carry out the desired action which in this case is
to change the background colour of the page.  I can do this by finding
the base HTML element and setting it's style attribute:

```Javascript
    const body = document.getElementsByTagName('html')[0];
    body.style = 'background-color:' + colour;
```

## Other Useful Events

The `submit` event is triggered when the user clicks on the submit
button or otherwise submits the form (eg. by hitting the return key in
a text field). Other events are also useful in capturing user interaction
with a form.

### Change

The `change` event is triggered for a select input when a new selection
is made. For a text input, it is triggered when that input loses focus - when
the user clicks elsewhere in the page or tabs into another input field.
You can use the change event to run code when
an individual field in the form changes its value.

### Keys

The `keyup` or `keydown` events are triggered as the user types into 
a text field; either before or after the keystroke is registered.  A common
practice is to bind a handler to the `keyup` event to trigger auto-completion
of a form field.  Here's a very simple auto-complete example for colours:

```Javascript
const colours = ['red', 'blue', 'green', 'pink', 'lightgreen', 'lightcyan', 'gray', 'purple'];

let form = document.getElementById('colour-change-form');
form.querySelector('[name="colour"]').onkeyup = (event) => {
    const value = event.target.value;
    const options = colours.filter(c => {
        if (c.startsWith(value)) {
            return c;
        }
    });
    if (options.length === 1) {
        event.target.value = options[0];
    }
}
```

The handler gets the current value and then filters the list of colours to find
those that start with this value. If the resulting list of options has just
one member, then it sets the value of the field to that colour.  This implementation
is very simplistic - in particular if you delete one letter of the completed
colour it will just add it again which is rather annoying!  In a real implementation
you would usually offer the list of options to the user as a drop-down list.

As a little extension to this example, I might want to have the colour change
as soon as there is a successful completion of what the user is typing. So, as well
as filling in the complete colour name, I would then trigger the submit handler
for the form.  You might think that you could do this with:

```Javascript
form.submit();
```

However, this will submit the form *bypassing* the submit handler and send a
new GET request.  This is because the `submit` method is meant for programmatic
submission of forms once you have validated the data and might even be called
from a submit handler.  To get the desired outcome, we can just find the 
submit button in the form and fire it's `click` handler:

```Javascript
form.querySelector('[type="submit"]').click();
```

This will call the registered onsubmit handler for the form and have the desired 
effect.

### Focus and Blur

The `focus` event triggers when a user clicks on a field to enter some
data.  The `blur` event triggers when they leave.  You can bind to these
events to keep track of where the user is in the form and to perform
validation (for `blur`) of values once completed.

## Submitting Form Data

Sometimes you do want to send a request in response to a form but you
want to be in control and handle the response in your application
rather than just letting the server send out a new page.   In this case
you want to gather the input data from the form and use `fetch` to
send a request to the backend server.  An example might be one where
you want to carry out a transaction via an online commerce API. Our
form allows the user to select a product and when they click submit,
the order is placed.

```HTML
<form id="order-form">
    <select name="product">
        <option name="x1000">Panoptic X1000</option>
        <option name="pretank">Pre-tank Caltigulator</option>
        <option name="frobulator">Cryostatic Frobulator</option>
    </select>
    <input type="number" name="quantity" value="1">

    <input type="submit" value="Place Order">
</form>
```

The form asks for two values - a product and a quantity. The handler
will first get these values from the form and then construct a POST
request to the server with a JSON request body.

```Javascript
const orderForm = document.getElementById('order-form');
orderForm.onsubmit = (event) => {
    event.preventDefault();
    const form = event.target;
    const data = {
        product: form.querySelector('[name="product"]').value,
        quantity: form.querySelector('[name="quantity"]').value
    };

    fetch('https://example.com/order', 
           {
            method: 'POST',
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(data)
        })
    .then(response => response.json())
    .then(data => {
        // here we would update the page to confirm the purchase
        console.log(data)
    });
}
```

The fetch request body is a JSON version of the form data.  The request
body will look like this:

```JSON
{"product":"Panoptic X1000","quantity":"1"}
```

In many cases, the remote API will want you to send data like this as JSON,
in other cases
it will accept other formats such as the older `"multipart/form-data"` or
`"application/x-www-form-urlencoded"` which is what is sent with a
regular form submission.

This example doesn't do much with the response from the request but this would
typically be a confirmation of the order (or otherwise) and we would update the
current page to reflect the result of the transaction. Perhaps adding to a list
of products ordered for this user.

This example shows how form data can be gathered and used as part of a `fetch`
call to a server API. Your Javascript code is in control here and the request
submission doesn't result in page redraw as it normally would.
