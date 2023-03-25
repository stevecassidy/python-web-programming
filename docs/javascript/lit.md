# Web Components with Lit

[Lit](https://lit.dev/) is a small Javascript library that makes writing web components
easier than using the core web standards.  This chapter describes some of the main
parts of Lit; it is not a comprehensive tutorial.

## Using Lit

Lit is a third-party Javascript library, so the first problem we have to solve is how
to include it in our web application.  The standard way is to use the `npm` package
manager to install it in your project and use a bundler like [webkit](https://webkit.org/)
to combine the
Lit code with your own for delivery to the browser.  In this text, we will avoid that
complexity for now and take a more direct approach of loading a version of the Lit
code hosted on the web. 

According to the [Lit documentation](https://lit.dev/docs/getting-started/#use-bundles) we
can import Lit into our code with the following:

```Javascript
import {LitElement, html, css} from 'https://cdn.jsdelivr.net/gh/lit/dist@2/core/lit-core.min.js';
```

Lit is distributed as a [Javascript module](javascript.md#modules) and this line imports
three functions from that module via a URL that refers to a hosted version of the code.
Loading Lit in this way means that we don't need to use a bundler like Webpack and the code
we write can run directly in the browser.

## Simple Example

To mirror the example in the [Web Components](web-components.md#custom-elements) chapter 
here is a simple example of a Lit element:

```Javascript
import {LitElement, html, css} from 'https://cdn.jsdelivr.net/gh/lit/dist@2/core/lit-core.min.js';

class DemoComponent extends LitElement {

    static styles = css`           
        :host {
            display: block;
            background-color: red;
            width: 200px;
            height: 200px;
        }`

    render () {
        return html`
        <h2>DEMO</h2>
        <p class="demo">I am a demonstration of custom elements!</p>`;
    }
}; 

customElements.define('demo-component', DemoComponent);
```

The first difference is that our new class extends `LitElement` rather than `HTMLElement`.
In the plain custom element example, the HTML content of the element was generated in
the `connectedCallback` method of the class.  Here, the work is done in a special `render`
method which returns the required HTML content.  

The other subtle difference is that this function uses a tagged template string `html\`xxx\``
to create the HTML.  [Tagged templates](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#tagged_templates)
are a Javascript construct that allows you to
pass the template string through a function (in this case `html`) to generate
the result. In this
case, the result of the html string is a parsed HTML fragment - a set of
elements ready to be inserted into the page.  This may seem a minor feature but it makes
custom elements made with Lit a lot more efficient than the style introduced in 
the previous chapter.

The style information is also a little different. It is added by setting up a static
variable called `styles` and the value is a full CSS stylesheet. In this example,
I have
used the selector [`:host`](https://developer.mozilla.org/en-US/docs/Web/CSS/:host) 
which refers to the custom element itself.

A hidden difference with the Lit element is that it will use the 
[Shadow DOM](web-components.md#shadow-dom) to insert the element content
without any additional effort on our part.  Since we're using the shadow DOM, the 
stylesheet will only apply to the contents of this element and won't 'leak' to the
rest of the page.

## Attributes

Lit handles attributes for the new custom element in a very convenient way. To define
an attribute, I declare a static variable `properties` in the class containing a
definition of the attributes that are allowed.

```Javascript
class BookInfo extends LitElement {
    static properties = {
        title: {},
        author: {},
        image: {}
    }

    render() {
        return html`
        <h2>${this.title}</h2>
        <p>By ${this.author}</p>
        <img src="${this.image}" alt="book cover">
        `;
    }
}

customElements.define('book-info', BookInfo);
```

This can be used for example as:

```HTML
<book-info title="The Grapes of Wrath" 
           author="John Steinbeck" 
           image="https://example.com/image.jpg">
</book-info>
```

The attribute values are automatically copied into the class properties and can
be referenced in the render function.

## State Variables

The class properties are actually a lot more powerful than the previous example shows.
Any change to the value of a property will trigger a re-render of the element - the
`render()` method will be called and the element will be updated in the page.

It is possible to define properties that are not reflected into attributes
for the element.   These define [internal reactive state](https://lit.dev/docs/components/properties/#internal-reactive-state)
and provide a way to have information stored internally to the element
that can affect the display.

To illustrate these ideas, we'll develop a counter component that shows a numerical
value and increments it every time it is clicked.  Here's the basic
class:

```Javascript

class CounterBlock extends LitElement {

    static properties = {
        start: {type: Number},
        _count: {state: true}
    }

    static styles = css`
    :host {
        display: block;
        width: 100px;
        height: 100px;
        background-color: red;
    }
    `

    render() {
        return html`<p>Counter: ${this._count}</p>`
    }
}
customElements.define('counter-block', CounterBlock);
```

This element has one external attribute (`start`) and one internal property (`_count`).
The attribute `start` is declared as being numbers which instructs Lit to try to
parse a number from the attribute value.   The `_count` property is declared as
a state property which means it will not be reflected as an attribute of the
element - it is an internal reactive state variable.

The `render()` method outputs content based on the value of `_count`.  The
first thing we need to do is to initialise `_count` to the value of `start`
if it was provided or zero if not.  We can do this in the `connectedCallback`
method which is run just before the element is inserted into the DOM.

```Javascript
connectedCallback() {
    super.connectedCallback();
    this._count = this.start || 0;
}
```

Note that we must call the connectedCallback method of the super class (`LitElement`)
at the start of this method.  If you miss that out, you won't see an error but your
element won't work.  

You might think to do this in the constructor for the class, however, when the constructor
is called, the attributes have not yet been parsed so we can't get the value
of `start`.

The next step is to add an event listener for a click event on the element and increment
the counter when it is called.  The listener itself is a method on the class.
We can then add an event listener in the connectedCallback:

```Javascript
    _increment(e) {
        this._count ++;
    }

    connectedCallback() {
        super.connectedCallback();
        this._count = this.start || 0; 
        this.addEventListener('click', this._increment);
    }
```

Since the event listener modifies the state variable `_count`, a render of the element
will be triggered and we'll see the updated count shown the page.  No additional
code is needed to trigger a redraw as it would be for a regular custom element.

This shows how we can maintain internal state that is reflected in the HTML that
is generated.   The same is also true of external attributes.  If some other code
was to modify the value of the `start` attribute for this element, a render would
be triggered (in this case it would not change since `start` is not used in the HTML).

## Event Handlers on Child Elements

Adding a listener to the custom element is one way to capture user input but often
we want to have more kinds of interaction with the child elements.  Lit provides
a shorthand way to add an event listener for part of the HTML that is generated. 

If we wanted to add a button to the counter element that incremented by 10 we could
do it this way:

```Javascript
    _plus10(e) {
        this._count += 10;
        e.stopPropagation();
    }
    render() {
        return html`
          <p>Counter: ${this._count}</p>
          <button @click=${this._plus10}>+10</button>
          `;
    }
```

In the render method, the `@click` attribute is used to assign the event handler to
the click event on the button element.  The same shorthand can be used for any other
event (`@keyup`, `@mouseenter`, etc).

The `_plus10` method just adds 10 to the counter but note the use of `e.StopPropagation()`
to prevent the event listener on the parent from being called as well.

