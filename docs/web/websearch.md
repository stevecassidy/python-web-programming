

Web Search
==========

<div class="slide">

The Web as Data Store
---------------------

-   The Web can be seen as a very large, unstructured data store
-   There exist hundreds of millions of Web pages, but there is no
    central index
-   Even worse: it is unknown where all the Web servers are
-   The solution: search engines and directories



<div class="slide">

How does a Search Engine work?
------------------------------

Have you ever wondered ...

-   ... why a search engine is so fast?
-   ... how the search engine can find something?
-   ... where the search happens?



<div class="slide">

Search Engines
--------------

A search engine basically consists of:

-   A *crawler* that finds and fetches web pages ("offline")
-   An *indexer* that extracts words from web pages, generates an
    inverted index and stores this index in a huge database ("offline")
-   The *query processor* compares a search query of the user with the
    index and recommends the most relevant documents ("online")



<div class="slide">

Collecting and Storing the Data
-------------------------------

![](graphics/spider.gif)



<div class="slide">

Web Crawlers
------------

The Web can be seen as a network consisting of nodes (pages) and arcs
(links)
There is no unique starting point to access all web pages
1.  Take heavily used servers with very popular pages as starting point
2.  Index these web pages and follow hyperlinks to other pages
3.  Continue indexing until you only see pages that are already indexed

This is in essence the task of a *crawler* (also called spider) of a
search engine



<div class="slide">

Term Indexing
-------------

-   Terms (important words) are extracted by the indexer from web pages
    that the crawler retrieved
-   Stop words (function words) are not extracted by the indexer
-   The extracted terms are stored as *inverted index* with pointers to
    the documents:

    ``` {.programlisting}
                 Term1: [URL1, URL2, URL3]
                 Term2: [URL2, URL4, URL5, URL6]
    ```

-   Weights are (sometimes) assigned to each entry
-   Hits are automatically ranked and presented by relevance
-   The algorithms for ranking are often company secrets (Google
    considers over a 100 factors)



<div class="slide">

What Information to Keep?
-------------------------

-   Imortant words:
    -   Remove stop words (e.g. *the, a, on, of* )
    -   Keep words that are frequent in the page but rare elsewhere
-   Position of words within the page
    -   Gross position: start/end
    -   More precision for early words
-   Special tags (e.g. `title`, `h1-h6`)
-   Text of links *to the page*, eg

        <a href="http://www.ics.mq.edu.au/~cassidy">Steve Cassidy</a>



<div class="slide">

Building the Index
------------------

-   There are quite a few ways to build an efficient index
-   The most effective way is to build a *hash table*
-   Python:

        index = dict()
        for term,url in parse_page(base_url):
            if dict.has_key(term):
                dict[term].append(url)
            else:
                dict[term] = list(url)
                

-   Underneath, a hash function allows access to terms in constant time
-   How well does this scale?



<div class="slide">

Relevance - Internal Factors
----------------------------

Factors based on a Web page's content:

-   Word frequency (how often search terms occur in a page)
-   Location of search terms in the page (title, top of the page)
-   Relational clustering (how many pages in a site contain a term)
-   Page design (does it use frames, does it load fast)



<div class="slide">

Relevance - External Factors
----------------------------

Factors external to the page:

-   Link popularity (number of links pointing to a page)
-   Click popularity (pages visited more often are prioritised)
-   Sector popularity (pages visited by demographic groups)
-   Business alliances among services
-   Pay-for-placement rankings



<div class="slide">

How Google PageRank Works
-------------------------

-   Google relies on the democratic nature of the Web
-   A link from page A to page B is a vote by A for B
-   In addition Google analyses the page that casts the vote
-   Votes from pages that are "important" weigh more heavily
-   These votes help to make other pages "important"
-   Google combines page ranking with text-matching techniques
-   Pages have to be both important and relevant to a search
-   Read: [How Google
    works](http://www.googleguide.com/google_works.html)



<div class="slide">

Boolean Search
--------------



<div class="slide">

Boolean Search
--------------

-   Idea: Convert boolean operations into set operations
    -   Taking advantage of the information stored in inverted indices
-   Return the pages that satisfy the boolean query
-   Need to implement an additional method to rank the pages



<div class="slide">

Boolean Search - Example
------------------------

-   Documents:

        D1 = {unit, comp225, exam},
        D2 = {comp225},
        D3 = {unit, comp225, comp248, exam},
        D4 = {unit, comp248},
        D5 = {comp248, comp249, exam}
        D6 = {unit}, D7 = {unit, comp249}

-   Inverted index:

        unit: {D1, D3, D4, D6, D7}
        comp225: {D1, D2, D3}
        comp248: {D3, D4, D5}
        comp249: {D5, D7}
        exam: {D1, D3, D5}



<div class="slide">

Example (cont'd)
----------------

-   The query:

        unit & (comp225 or comp249) & not  exam

-   Map `&` to INTERSECTION, `or` to UNION, `& not` to DIFFERENCE:
-   The equivalent set operation for this query is:

        ({D1, D3, D4, D6, D7}
           INTERSECTION
         ({D1, D2, D3} UNION {D5, D7})
        )
        DIFFERENCE
        {D1, D3, D5} = {D7}
              
            
            
              Implicit Boolean Queries
              
                But my favourite search engine does not use boolean
                queries ... does it?
                Have a look at the advanced search mode
                Implied boolean query
                
                  By default all query words are connected with &
                  (or)
                  +: explicit &
                  -: explicit negation
                
              
            

            
               Making use of Meta-Data
            

            
              What are Meta Tags?
              
                Meta tags are data that are not displayed by the
                browser but they can be accessed by crawlers
                Meta tags are inserted between
                <head>and
                </head>tags
                Meta tags allow you to interact with the search
                engines
              
            
            
              Description Tag
              
                Description tag summarizes a page in the result list of
                some search engines
                The size of the description should be less than 200
                characters
                Provided information should be attractive to make the
                visitor click on your link in the search engine
                results
                The description tag format looks like this:
                
          <meta name="description"
           content="COMP248 Introduction to Natural Language
                    Processing, Technology of the 21st Century">



<div class="slide">

Keywords Tag
------------

-   The keyword tag is used by search engines to index your site
-   Keywords make the search engine decide under what queries your site
    will come up
    -   This can be helpful if terms on a page are ambiguous
-   Basic HTML format of the meta keyword tag is:

    ``` {.programlisting}
       <meta name="keywords"
             content="keyword1 keyword2 keyword3 ...">
    ```

-   Your keywords must be as specific as possible
-   Danger: somebody might add meta tags that fit very popular topics
    but have nothing to do with the actual contents of the page



<div class="slide">

Robots Tag
----------

-   This tag tells the crawler what to do with your page
-   Available parameters for robots tag are: `index`, `noindex`,
    `follow`, and `nofollow`
-   INDEX tells the crawler to index your site on its database
-   FOLLOW tells the crawler to follow all the links in your site
-   Robots tag looks like this:

    ``` {.programlisting}
            <meta name="robots" content="parameter">
    ```

-   However, you have very little or no control over crawlers.



<div class="slide">

Alternatives to Search Engines
------------------------------



<div class="slide">

Directories
-----------

-   Directories ([Yahoo!](http://au.dir.yahoo.com/),
    [dmoz](http://www.dmoz.org/)) have real people who review and index
    links
-   Directory editors look at the quality of a site:
    -   functionality
    -   content
    -   design
-   As a result, directories, indexes tend to contain high-quality
    links, but:
    -   It may take long for a web page to be included in the directory
    -   The coverage of the directory is much smaller than that of a
        search engine



<div class="slide">

Hybrid Search Engines
---------------------

-   Hybrid search engines combine a directory with a search engine
-   Most search sites are hybrids
-   For example, Yahoo! started out as a directory
-   Yahoo! later supplemented its manually compiled listings with search
    results from Google
-   Yahoo! announced the use of an in-house search engine instead ( *The
    Australian* , 24 Feb 2004)
-   Google uses Open Directory Project's directory to enrich its
    automatically generated listings



<div class="slide">

Metasearch
----------

-   Unlike search engines, meta search engines do not crawl the Web
-   Instead, they allow searches to be sent to several search engines
-   The results are then blended together onto one page



<div class="slide">

Limitations of Search Engines
-----------------------------



<div class="slide">

The "Invisible" Web
-------------------

-   **Opaque Web:** search engines choose not to index
-   **Private Web:** password protected
-   **Proprietary Web:** registration required (either fee or free)
-   **Truly invisible Web:**
    -   cannot search certain file formats and databases
    -   most crawlers do not crawl sites that include scripts



<div class="slide">

Recall
------

-   Not all the relevant web pages are found:
    -   Because they were not indexed
    -   Because the retrieval engine failed to spot their relevance
-   Recall is the number of documents the search engine got right
    divided by the number of possible right documents
-   Sometimes high recall is not important, as long as we find *one* web
    page that is relevant



<div class="slide">

Precision
---------

-   Irrelevant web pages can be found
-   How is this possible?
    -   Ambiguous terms (e.g. "chips (silicon)" and "chips (food)" and
        "chips (wood)")
    -   Spamming techniques (e.g. the authors introduce
        irrelevant metadata)
    -   The topic of the web page is just missed (need for more
        sophisticated language technology techniques)
    -   A document is more than the sum of its keywords
-   Precision is the number of documents the search engine got right
    divided by the number of documents the search engine found.



<div class="slide">

Example
-------

To find web pages about sales of beef in Chile, try the following
queries:

-   *[chilean beef
    sales](http://www.google.com/search?q=chilean+beef+sales)*
-   *["chilean beef
    sales"](http://www.google.com/search?q=%22chilean+beef+sales%22)*
-   Assess recall (do we have all relevant pages?) vs. precision (are
    all returned pages relevant?).



Future Developments
-------------------

<div class="slide">

Concept Based Search
--------------------

-   One research area is concept-based searching:
    -   car, automobile (synonymy)
    -   station wagon, car, vehicle (hyponymy)
-   Some of this research involves using
    -   statistical analysis
    -   ontologies (collections of standardised terms)

    in order to find other pages you might be interested in
-   The information stored is greater for a concept-based search engine
-   Far more processing is required for each search



<div class="slide">

Natural Language-based Search
-----------------------------

-   The idea behind natural-language queries is that you can type a
    question in the same way you would ask it to a human *Who is the
    president of the United States?*
-   No need to keep track of Boolean operators or query structures
-   The most popular natural language query site is
    [AskJeeves](http://www.ask.com/)
-   AskJeeves parses the query for keywords
-   It then applies the keywords to a list of canned questions of which
    it knows the answer (typically linked to generic Web databases)
-   Recent entrant: [Powerset](http://www.powerset.com/) tries to
    understand the target documents.



<div class="slide">

Web-based Question Answering
----------------------------

-   We start seeing sites that search the Web for specific facts
    -   Rather, "factoids": the answer may be wrong!
-   Examples:
    -   [START](http://www.ai.mit.edu/projects/infolab/)\[http://www.ai.mit.edu/projects/infolab/\]
    -   [BrainBoost](http://www.brainboost.com/)\[http://www.brainboost.com/\]
-   Question answering is a hot research topic (see (
    [TREC](http://trec.nist.gov)\[http://trec.nist.gov\] ))




