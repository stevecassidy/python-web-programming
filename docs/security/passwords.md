# Password Security

[Authentication](../advanced/authentication.md) is an important part of
many web applications that need to know who the user is to provide
customised services or allow transactions.  Since knowing the
password of a user would allow an attacker to impersonate them on
your application, keeping them secret is very important.  This chapter
looks at how passwords should be stored and used in web applications.

## Don't Store Passwords

The easiest way to avoid passwords being leaked is not to store them at
all and rely on a third-party to do authentication for you.  This is
possible with services like [Auth0](https://auth0.com/) or
[Firebase Authentication](https://firebase.google.com/docs/auth/)
which use the OAuth2 protocol to manage authentication for you.  This
can be a very good option as it allows the use of services like Google
and Facebook login which can be convenient for the user.

In doing this, you are basically buying in your password and user data
security.  Your site is now as vulnerable as your authentication provider
is. Should they be breached, you are breached.  These companies are
likely to be very serious about security and spend more money and time
on making sure their systems are safe.  So, it's probably a good choice,
but one that you should be aware that you are making.

## Local Passwords

Even when you use a third-party authentication service, it can be useful
to be able to back-off to local passwords.  You might want to do this just
for the core administrative accounts or as a backup option for some users.

To use passwords in a web application we will need to be able to answer the
question of whether the submitted password is the same as the one that
we have stored for this username.  We want to be able to do this in
a way that is safe from the most obvious attack, which is that the
password database gets leaked.

If the passwords are leaked and we store them as plain text then the attacker
can easily login to our site. What is more, they can try the same passwords
on other sites for this user, since people often re-use the same
password.  So, storing as plain text is the first thing we need to avoid.

### Encrypting Passwords

Instead of storing as plain text, we could [encrypt](https://en.wikipedia.org/wiki/Encryption)
the passwords in some way.
Encryption works by encoding the plain text using an encryption key, such that
the plain text can be retrieved again using the same (or a matching) key.

If we did this, then our application would need to contain both the encoding
and decoding keys (since it has to store and retrieve passwords).   The database
would store encrypted passwords, so leaking it would be safe.  However,
if the attacker got the database, they could probably get the source code
for the application, and this would contain the decryption key.  

So, encryption is not a good option for storing passwords.

### One-Way Hash Functions

The solution to this problem is to use a 
[one-way hash](https://en.wikipedia.org/wiki/Cryptographic_hash_function) function which
takes the plaintext password and generates a new string based on it such
that the probability of the same hash being generated from two different
input strings is very low.  As the name suggests, a one-way has is hard
to reverse, you can get the hash from the plain text but not the other
way around.

A common hash function is [MD5](https://en.wikipedia.org/wiki/MD5) which is
often used to provide a check that a file has not been corrupted once it
is downloaded.  The publisher displays the MD5 hash of a file. You compute
the same hash function on your downloaded file. If they are the same, you
can be assured that no data was lost in the download.   MD5 could also be
used to store our passwords, except that it is relatively easy to reverse -
that is, to find a plaintext string that generates a given hash value (a
collision attack).

A better hash function is SHA-2 which was developed specifically
as cryptographic hash functions for this kind of purpose.  It is
much more difficult to reverse and can use different hash sizes
for more secure applications (eg. SHA-256, SHA-512).  SHA-2 would
be a good candidate for storing our passwords except for one
thing - it's too fast.

SHA-2 is fast because it is often important to be able to compute
and verify hashes quickly, for example when checking the integrity
of files as in the MD5 example above.   However, if we use a fast
hash function for password storage, we make the job of the attacker
easier in a **brute force** attack.

### Brute Force Attacks

If the attacker gets hold of our password database, they can try
to guess what the passwords are, even if they can't read them.  Reversing
the hash function is too hard, but if they can guess a large number
of passwords, they can compute the hash function and see if they
get a hit in the database.  This is a **brute force attack**.

The attacker will use a collection of known passwords, eg. 'password',
'secret', '123456789', 'qwerty'.  They can also generate possible
passwords by randomly modifying these, eg replacing 'l' with '1' etc.
Each generated password is passed through the hash function and then
searched for in the password database.

This attack is very workable if they can generate and test many
passwords per second.  Here's a quote from
[The Security Factory](https://thesecurityfactory.be/password-cracking-speed/) 
in 2020: "At a current rate of 25$ per hour, an
AWS p3.16xlarge nets you a cracking power of 632GH/s (assuming we’re cracking
NTLM hashes). This means we’re capable of trying a whopping 632,000,000,000
different password combinations per second!".

So, as a result, we want our hash function to be **slow** in order to make
these attacks harder.

### A Nice Slow Hashing Algorithm

The current best practice hash algorithm for password storage is
[PBKDF2](https://en.wikipedia.org/wiki/PBKDF2).  This is designed
to be particularly slow as well as being very hard to reverse. 

PBKDF2 is actually a combination of other algorithms. It uses 
an underlying Hash-based Message Authentication Code (HMAC)
to do the hash computation.  HMAC-SHA256 is based based on SHA-256
but adds an additional secret cryptographic key to the input
string.

PBKDF2 also adds a **salt** value to the process, this is
a user-specific string that will be stored alongside the
hashed password.   Since the salt is different for each user,
the attacker needs to compute a different hash for each
guessed password for each user.  Even if they know the salt,
it still slows them down.

Critically, the PBKDF2 algorithm runs the hashing function over and
over again many times and this makes the overall process much
slower.   The number of iterations is in the thousands, with
1000 being the minimum recommendation and up to 100,000 being
used in some applications.

The end result is a hash function that computes a one-way hash
of an input password that can be stored in our database.  The
function is deliberately slow, meaning that an attacker
will take longer to try a given number of guessed passwords.
The algorithm is cryptographically strong, meaning it is
very hard or impossible to reverse.

This is the current best-practice for storing passwords but as
compute power increases, even this will not be enough.  One
criticism of PBKDF2 is that it doesn't take a lot of memory; it
could be made stronger by being a memory hog!  So new standards
will become the norm over time.  As developers, you need to
stay on top of this as what you are learning now is best
practice will one day be dangerously insecure!

