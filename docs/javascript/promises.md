# Promises and Asynchronous Code

Javascript runs in a _single threaded_ process, meaning that only one line of
code is executing at one time.  This is typical of most programming langauges
but since Javascript code is often _event driven_, developers might assume that
many things happen at once in response to different events.

Javascript code is executed using an _event loop_.  This is a high-level loop
that waits for a task, executes it and then sleeps until the next task is
available.   In the browser, a task might be loading a Javascript file via a
`<script></script>` tag or running the event handler when the user clicks on a
button.  If a task is scheduled when the Javascript engine is already busy
running another task, it is added to a queue (called the _macro-task queue_).
The event loop will pull the next task from the queue when it completes what it
is doing.

While the Javascript engine is busy executing code, nothing else happens in the
browser.  If the code changes the DOM, the updates don't get rendered to the
screen until the task has finished.  Since it can only run one task at a time,
the browser can't respond to new input until that task has finished.  This means
that tasks in Javscript code should be short and fast so that the browser can
remain responsive to the user.

If you have a task that would normally take some time, it is useful to split
it up into smaller tasks so that other things can be done.  This can be done
with the `setTimeout` function which schedules a function to be run at a later
time (if no time delay is given, it will be scheduled as the next task).  Here's
an example where we want to run an expensive function 1000 times but split it up
into batches of 100 to allow for other tasks to be run and the page to be
updated as we go.

```javascript

const process = (start) => {

    if (start > 1000) {
        return
    }

    for(let i=start; i<(start+100); i++) {
        processThatTakesTime(i);
    }
    // schedule the next batch
    setTimeout(() => process(100))
}
```

`setTimeout` is an example of _asynchronous code_.  This is code that doesn't
execute one line after another (_synchronous_) but code that we know will run
_at some future time_.

## Promises

A very common case that arises in Javascript programming is having to wait for
a result from an external process such as a web request, database update or
file system read. In other languages, the program would just wait for the
external request to complete and then carry on execution with the result.
Because we want to maximise responsiveness in Javascript execution, it is
common for these tasks to run asynchronously.  

Javascript introduces a pattern for dealing with asynchronous code called
_Promises_ which handle the common case of scheduling some code to run at a
later time when a result is available from a time-consuming operation.

A very common example in a front-end, browser based application is the use of
the `fetch` function to retrieve a resource from a URL.  Since the server will
take some time in responding to the request, we don't want to freeze the browser
until it returns. Hence, we want to schedule the code that will handle the
response to run only when that response is available.  This allows any other
tasks to run in the interim.  We can achieve this with the `.then` clause:

```javascript
console.log('sending request');
fetch('http://example.com/')
    .then((response) => {
        console.log('got the response!');
        doSomething(response)
    });
console.log('request sent');
```

Here we have called `fetch` to send a GET request to this URL.  The `.then`
clause schedules a function to be called when that request returns, the response
will be passed to this function.   That function can then handle the response
(eg. by updating the DOM for the current page).  

The output from the above code will be:

```text
sending request
request sent
got the response
```

The first line should be obvious.  We see the second line (`request sent`)
because the fetch call just sends off the HTTP request and schedules the then
clause to run at a later time.   This means that the final line of code gets t
run before the then clause.   Finally, we see `got the response` output by the
then clause only when the response comes back from the remote server.

### Handling Errors

If something goes wrong in the task that is being waited on in a promise, then
instead of being _resolved_, the promise is _rejected_.   A rejected promise is
one that wasn't kept, for example, the HTTP request returned an error status.
We usually want to handle any case like this and we can use a `.catch` clause
to provide some code that will run if the promise is rejected.

```javascript 
fetch('http://example.com/')
    .then((response) => {
        console.log('got the response!');
        doSomething(response)
    })
    .catch((error) => {
        console.log("Error in fetch: ", error);
        tellTheUserAboutTheError();
    });
```

The function in the `.catch` clause will be called only if the promise returned
by `fetch` is rejected.

### A Note on Syntax

The format of the code above might look a bit confusing.  I've written the
`.then` and `.catch` clauses on separate lines but the dot before 
them indicates that they are really part of the previous line of code:

```javascript
fetch('http://example.com').then(/*...*/).catch(/*...*/);
```

To understand this we need to realise that the `fetch` function returns a promise
object.  We then call the `then` method of that object, passing in a function
that will be called if the promise resolves.  The `then` method also returns
the same promise, and we then call the `catch` method on that.  So, what you see
here is a _chain_ of method calls on a promise object returned by `fetch`.  

Note that `fetch` and the `then` and `catch` methods return immediately, they
don't cause the application to pause at all. They register code to run at a
future time. This is why any code after the `fetch` call runs before the
`then` or `catch` clauses are executed.

Since these functions return _promises_ rather than values, it is not usually 
useful to store the result in a variable.  You might be tempted to write:

```javascript
const response = fetch('http://example.com');
const body = response.body;
```

Here, `response` is not the HTTP response, it's a promise that there will be a
response in the future (or an error).  So `response` doesn't have a body
property like a real HTTP response object would.   Any work you do on the
response has to be within the `then` clause that will be called later, when the
request returns and the promise is resolved.

### Scheduling Promises

Functions like the one in the `.then` clause above are called _micro tasks_
rather than the _macro tasks_ mentioned above.  Micro tasks have a separate
queue that will be run before DOM rendering takes place.  So, the order of
execution in the event loop is:

1. Select the next Macro task and execute
2. Run any tasks from the micro-task queue until it's empty
3. Render the DOM

Tasks will be put on the micro-task queue when they are ready, so our fetch task
above would not be put on the queue until the response returned.  If the server
was particularly slow, that might not be until after later Macro tasks had run.
So, we might send of the fetch request, the user could click a button to do a
calculation, the page could be updated, and only then our request returns and
our handler micro-task is called to process it.

### Chains of Promises

The promise object returned by `fetch` will usually resolve when the request
returns to give an object representing the HTTP response.  If we attach a `then`
clause, it will be called with the response value once it is available.  A very
common thing to do is to then call the '.json()` method on the response to parse
the response body as JSON

```javascript 
fetch('http://example.com/')
    .then((response) => response.json())
```

Here we write a shorthand arrow function containing just one statement, the
effect of this is that the function returns whatever that statement returns. An
explicit return is not needed.  `response.json()` parses the body as JSON and
returns the resulting Javascript data structure, it too returns a promise which
means that to handle the parsed data we need another `then` clause:

```javascript 
fetch('http://example.com/')
    .then((response) => response.json())
    .then((data) => {
        const username = data.username;
        const password = data.password;
        performLogin(username, password);
    })
    .catch(error => {
        notifyError(error);
    });
```

Here I have a _chain_ of promises that perform steps of the process in an
asynchronous manner.  This example is a very common idiom for handling a fetch
request in a Javascript application. 

Another example of chaining is shown below. Here I define my own promise that
resolves itself after a delay of 300 ms by scheduling a macro task that will
call the resolve function.

```javascript
const myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("promises");
    }, 300);
});
myPromise.then(value => `${value} are`)
         .then(value => `${value} confusing`)
         .then(value => console.log(value));
```

After 300 ms, the promise `myPromise` will resolve to the string value
`"promises"`, the first `then` clause will be called with this value and it
returns a new string `"promises are"`. Because this is a promise chain, the
second `then` clause is now called with this new value and returns `"promises
are confusing"`.  Finally the last `then` clause is called and outputs this
value to the console. Only one delay of 300ms is invoked here, before the first
promise is resolved. The other then clauses are fired as soon as the previous
one returns a value.

## Async and Await

Sometimes, you want to wait for something to happen rather than write promise
based code.  This might be in a server side application when you are processing
an HTTP request and need to query the database before returning a result.  In
this case you don't want to fire of a promise, you want to wait for the database
result and then build the response from it.   In this case we can use the
`async`/`await` pair of keywords.

We'll use `fetch` again as an example but this time we want to wait for the
result to come back and process it on the next line.  We can write an async
function as follows:

```javascript
const process = async (url) => {
    const response = await fetch(url);
    const body = response.body;
    console.log(body);
    return('done');
}
```

The first thing to note is that you can only use the `await` keyword in a
function that is marked as `async`.  You can't use `await` outside of a
function.   The effect of `await` is to force the execution of the call to be
synchronous - instead of returning a promise, the call will block execution of
the script until the response is available and then return that.  This means
that the next line of code can process the response.  

The returned value of an async function is always _a promise_ that will resolve
to the explicitly returned value.  In the above example, the function will
return a promise that will resolve to `'done'`.  

Here's another example of an async/await pair:

```javascript
const myPromise = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve("promises");
    }, 300);
});

const myFunction = async () => {
    const msg = await myPromise
    return `${msg} are confusing`;
}

myFunction().then(v => console.log(v));
```

The function waits for the promise to resolve, then returns a string that
includes the value of the promise.   When the function is called, it returns a
promise and we attach a `then` clause to that to output the final value. The
result is again that `"promises are confusing`" is output. 

You will see examples of the use of promises and await/async.  The best way to
learn and understand them is to study these examples and ensure that you
understand what they are doing.  Try to keep the idea of future execution of
code clear in your mind as you write. 

## Further Reading

* [MDN on
  Promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
* [DigitalOcean on
  Promises](https://www.digitalocean.com/community/tutorials/understanding-javascript-promises)






