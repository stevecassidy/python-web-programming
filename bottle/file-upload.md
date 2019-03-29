

Uploading Files
===============

Handling file uploads is a special case of form handling that needs a
bit more work This chapter covers the basic ideas that are involved in
handling a file upload form in Bottle.



File Upload Forms
-----------------

An HTML form can include a special type of field that is designed to
handle file uploads:

```html
<input type='file' name='newfile'>
       
```

This field can appear slightly differently on different browsers but
generally shows as a button next to a text value or possibly a text
entry box. Clicking the button pops up a platform specific file
selection dialogue and allows the user to choose a file to be uploaded.
In some cases the user can optionally enter the name of a file in the
text box. Here's one embedded in this page:

When the form is submitted, the contents of the file will be sent along
with the HTTP request. Since file upload will generally be adding new
resources to a website, a POST request is appropriate (it is possible to
send a file payload along with a GET request but there aren't really any
cases where this is appropriate given the meaning of GET). One issue to
consider is the way that the form data is encoded with the request.

By default, HTML forms are sent along with the HTTP request in a format
called URL Encoding where values are encoded as they would be to be part
of the URL in a GET request. This means that some characters in values
are replaced by encoded versions, eg. spaces become %20 etc. This is
used even if you send the form with a POST request, the data is sent in
the request body in that case but the same encoding is used. This is
fine for simple form values but for file upload is not appropriate. To
enable upload of arbitrary forms,
[RFC1867](http://www.faqs.org/rfcs/rfc1867.html) defines an encoding
called `multipart/form-data`. This encoding not only allows more
efficient encoding of file contents but also allows multiple files to be
sent along with the same request. It uses the same encoding as is used
for attachments on email messages. To use this encoding we must set the
`enctype` attribute on the form containing the file upload field. Here's
an example of a complete form.

```html
<form method='post' action='/upload' enctype='multipart/form-data'>
    <input type='file' name='newfile'>
    Username: <input type='text' name='user'>
    <input type='submit' value='Submit'>
</form>
          
```


File Upload HTTP Requests
-------------------------

When the form containing a file upload is submitted, the file contents
are sent as part of the body of the HTTP request. Here's an example HTTP
request containing a form submission (with some irrelevant headers
removed):

```
POST /upload HTTP/1.1
Host: localhost:8000
Content-Length: 150825
Origin: http://localhost:8000
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary0fXryUtxQJP8XIm7
Referer: http://localhost:8000/my
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-US,en;q=0.8,de;q=0.6
Cookie: Set-Cookie: session=1f932996-151d-4292-a9b2-c3181eb2f421

------WebKitFormBoundary0fXryUtxQJP8XIm7
Content-Disposition: form-data; name="newfile"; filename="flower.jpg"
Content-Type: image/jpeg

...encoded image data...
------WebKitFormBoundary0fXryUtxQJP8XIm7
Content-Disposition: form-data; name="user"

bob@here.com
------WebKitFormBoundary0fXryUtxQJP8XIm7--
    
```

As seen in the example, the `Content-Type` header contains a boundary
string value which is used in the body of the request to separate the
various values being sent. In this case the form contains two fields, an
uploaded file with the name `newfile` and a text field with the name
`user`.


File Upload in Bottle
---------------------

Bottle makes it particularly easy to handle file uploads as described in
the [Bottle
documentation](http://bottlepy.org/docs/dev/tutorial.html#file-uploads).
Where we would normally use `request.forms.get` to get the value of
submitted form fields we can use `request.files.get` to get uploaded
files. The value of returned by this function is a `FileUpload` object
instance which makes handling the result quite easy.

The `FileUpload` object has properties that record the form field name,
the filename (from the client), the content type and the content length
of the uploaded file. These can be used to decide how to handle the
uploaded file - eg. to check that it is of the expected type or isn't
too large.

To handle the file there are two options. The easiest is just to save
the file somewhere on the server. To do this you would use the `save`
method on the `FileUpload` object. Here's an example handler that will
use this method:

```python
@app.post('/upload')
def upload():
    """Handle file upload form"""

    # get the 'newfile' field from the form
    newfile = request.files.get('newfile')

    # only allow upload of text files
    if newfile.content_type != 'text/plain':
        return "Only text files allowed"

    save_path = os.path.join(UPLOAD_DIR, newfile.filename)
    newfile.save(save_path)

    # redirect to home page if it all works ok
    return redirect('/')
        
```

This example assumes the upload form from earlier in this chapter with a
single file field with the name `newfile`. It first checks that this
file is allowed by looking at the `content_type` property on the
uploaded file object; in this case it will only allow text files to be
uploaded and saved. It then saves the file on the local system using the
global variable `UPLOAD_DIR` to determine where files should be stored.

In the case of the file not being a text file, the uploaded file
contents are just discarded. Up to this point they only exist in memory
in the application (or possibly in a disk cache if the file is large).
Python takes care of reclaiming this space once it is discarded so it
doesn't clog up your server.

The second option for processing a file is useful when what you want to
do is extract some content from the file or process it in some way. In
this case we can use the `file` attribute of the uploaded file as a file
handle and read data from that as we would a regular open file in
Python.

As an example, here is a form handler that checks the uploaded file for
the presence of the word "Bobalooba". It first checks that the file is
plain text, then reads one line at a time checking for the string.

```python
@app.post('/bobcheck')
def bobcheck():
    """Check to see if an uploaded file contains
    a target string 'Bobalooba'"""

    upload = request.files.get('upload')

    # only allow upload of text files
    if upload.content_type != 'text/plain':
        return "Only text files allowed"

    for line in upload.file.readlines():
        if "Bobalooba" in line.decode():
            return "We got a Bobalooba :-)"

    return "No Bobalooba in here :-("
        
```

Note that when reading lines from the file we need to use
`line.decode()` to turn them into strings (they are read as bytes). We
just use the `in` operator to check if the target string is in the line.
In this example we just return a simple text response rather than a full
page.

In this case the uploaded file is again stored in memory (or in a
temporary file if it's large) and so our Python code doesn't need to
worry about cleaning up after itself. This is a big advantage over the
low-level methods that are needed for file handling in some other
frameworks.

