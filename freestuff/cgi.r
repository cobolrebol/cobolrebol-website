TITLE
CGI common procedures

SUMMARY
These are common procedure that can be used in CGI programs to make
it easier to write them, without having to remember some of the
technical details of CGI programs.

DOCUMENTATION
Include the module in your program with

do %cgi.r 

If the module is not in the current directory, specify the full name
either with a drive letter or a UNC name in the REBOL syntax.

Usually, your program will be executed by the web server in response
to a request from a web browser.  Also usually, there will be data
availble from some sort of HTML form.  In the HTML form, the INPUT
items will be identified by the "NAME" attribute.  To get your hands
on the data from the form, use this procedure:

CGI-GET-INPUT

This procedure detects the proper source of the input data (GET or
POST) and reads the data, and then assembles it into an object.
Each data item can be referenced using the "path" syntax of

CGI-INPUT/data-name-1  

where "data-name-1" is the name sepecified in the "NAME" attribute.

After processing any input, your program will display some HTML output.
There are two main ways of doing that.

What you are going to do in general is build up a full HTML page in memory
and the "print" it with the "print" function, which will cause the page
to be sent back to the web server and then the web browser.  But before
you do that, you must print some special headers with this function:

CGI-DISPLAY-HEADER.

To build up that HTML page that you will print, there are two ways.  Each way
has the common end point of appending some HTML coding to the end of that
big page in memory.

The first way is to construct HTML in your program.  You can do this a line
at a time, or several lines at a time.  The HTML can contain rebol words,
because it will be reduced.  Build you HTML in a word and then do

CGI-EMIT-HTML data-name-2

Where data-name-2 is that rebol word that contains your HTML line(s).

The second way is to make a separate file of HTML. In this HTML file, you may
embed rebol code inside <% and %> tags.  This code will be evaluated, and the
results of the evaluation will replace the rebol code and its surrounding
tags.  This is sort of what PHP does.  The rebol code can reference words in
your program, so that is how you can get data that is in your program put into
HTML.  Do this:

CGI-EMIT-FILE file-name-1

Where file-name-1 is the name of that file of HTML code with the optional
embedded rebol code.

When you have built up a full HTML page, it is your own responsibility to
send it to the web server with the following command:

print CGI-OUTPUT 

There is another somewhat-related service supplied by this module.
Sometimes a program is written to display HTML not to be interpreted by
a browser, but to be shown as HTML.  That can be done with:

data-name-3: CGI-ENCODE-HTML data-name-4

where data-name-4 is an HTML fragment, and data-name-3 is that same fragment
with the tag markers ("<" and ">") replaced the the code that causes them
to be shown by the browser.

SCRIPT
REBOL [
    Title: "CGI common procedures"
]

;; [---------------------------------------------------------------------------]
;; [ This is a module of common procedures used in a CGI program.              ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This procedure is used to gradually build up a string of HTML             ]
;; [ to return to the browser.  When this module is first loaded,              ]
;; [ it makes a string to hold the HTML.  Then, is is called                   ]
;; [ repeatedly with a block of REBOL code and data as a parameter.            ]
;; [ The procedure evaluates any REBOL expressions ("reduces" them)            ]
;; [ and then appends the result to the end of the string we are               ]
;; [ building.  Finally, it puts a line-feed at the end so we don't            ]
;; [ create just one gigantic string as the final result.                      ]
;; [ (This will be appreciated by anyone who tries to view the                 ]
;; [ source of the resulting page with the browser.)                           ]
;; [---------------------------------------------------------------------------]

CGI-OUTPUT: make string! 5000
CGI-EMIT-HTML: func [CGI-OUT-LINE] [
    repend CGI-OUTPUT CGI-OUT-LINE
    append CGI-OUTPUT newline
]

;; [---------------------------------------------------------------------------]
;; [ This little procedure displays the header that is required                ]
;; [ when sending an html page back to the browser.                            ]
;; [ The procedure is separate because, while it must be done,                 ]
;; [ and it must be the first thing done, the caller might be                  ]
;; [ sending back a regular page, or a debugging page, or                      ]
;; [ who-knows-what, so we will let the caller do this when he                 ]
;; [ wants to.  But he must.                                                   ]
;; [---------------------------------------------------------------------------]

CGI-DISPLAY-HEADER: does [
    print "content-type: text/html"
    print ""
    print ""
]

;; [---------------------------------------------------------------------------]
;; [ This procedure uses the above procedure and is an alternate               ]
;; [ way to emit HTML.  This procedure accepts a file name as a                ]
;; [ parameter and reads that file into a string, and then calls               ]
;; [ the above procedure to add the file to the end of the HTML                ]
;; [ string that is being built up by the above procedure.                     ]
;; [ Before this procedure calls the above procedure, it runs the              ]
;; [ build-markup function on the file it read.  That function                 ]
;; [ locates special tags (<% and %>) and runs REBOL code inside               ]
;; [ those tags, similar to what PHP does.  Inside those tags                  ]
;; [ there can be REBOL words to be evaluated.  It is the job of               ]
;; [ the caller of this procedure to make sure that any words                  ]
;; [ used inside the build-markup tags are actually defined in                 ]
;; [ the calling program.                                                      ]
;; [---------------------------------------------------------------------------]

CGI-EMIT-FILE: func [
    CGI-FILE-TO-EMIT [file!]
] [
    CGI-EMIT-HTML build-markup read CGI-FILE-TO-EMIT
] 

;; [---------------------------------------------------------------------------]
;; [ This is a procedure that attempts to do as much as possible               ]
;; [ to help in the processing of CGI data.                                    ]
;; [ The procedure CGI-GET-INPUT reads the CGI data in whatever                ]
;; [ form it is presented                                                      ]
;; [ (POST or GET), and then puts the raw data into a string                   ]
;; [ called CGI-STRING.  Then it uses the decode-cgi command to                ]
;; [ break it apart into name/value pairs.                                     ]
;; [ It passes the name/value pairs to the construct function                  ]
;; [ which makes them into a context called CGI-INPUT.                         ]
;; [ As a context, the data can be referenced as                               ]
;; [ CGI-INPUT/data-name where data-name is a name specified in                ]
;; [ the "name" attribute in the HTML form.                                    ]
;; [                                                                           ]
;; [ The procedure CGI-GET-INPUT seems to hang up on IIS.                      ]
;; [ As a workaround, there is a separate procedure for IIS that returns       ]
;; [ the same CGI-INPUT context, but by different means.                       ]
;; [ The "different means" is to read a fixed amount of data out of            ]
;; [ the system/ports/input port.                                              ]
;; [ These two procedures are mutually exclusive.  Use on or the other.        ]
;; [---------------------------------------------------------------------------]

CGI-STRING: ""                 

;;  -- Apache version

CGI-GET-INPUT: does [
    CGI-STRING: CGI-READ
    CGI-INPUT: construct decode-cgi CGI-STRING
]
CGI-READ: func [
    "Read CGI data (GET or POST) and return as a string or NONE"
    /limit CGI-MAX-INPUT "Limit input to this number of bytes"
    /local CGI-DATA CGI-BUFFER
] [
    if none? limit [CGI-MAX-INPUT: 100000]
    switch system/options/cgi/request-method [
        "POST" [
            CGI-DATA: make string! 1020
            CGI-BUFFER: make string! 16380
            while [positive? read-io system/ports/input CGI-BUFFER 16380] [
                append CGI-DATA CGI-BUFFER
                clear CGI-BUFFER
                if (length? CGI-DATA) > CGI-MAX-INPUT [
                    print ["aborted - form input too large:"
                        length? CGI-DATA "; limit:" CGI-MAX-INPUT]
                    quit
                ]  
            ]
        ]
        "GET" [
            CGI-DATA: system/options/cgi/query-string
        ]
    ]
    CGI-DATA
]

;;  -- IIS version

CGI-GET-INPUT-IIS: does [
   CGI-STRING: CGI-READ-IIS
   CGI-INPUT: construct decode-cgi CGI-STRING
]
CGI-READ-IIS: func [
] [
    CGI-DATA: make string! 5000
    switch system/options/cgi/request-method [
        "POST" [
            read-io system/ports/input CGI-DATA 5002
        ]
        "GET" [
            GGI-DATA: system/options/cgi/query-string
        ]
    ]
    CGI-DATA
]

;; [---------------------------------------------------------------------------]
;; [ This procedure exists for those cases where a CGI program                 ]
;; [ is going to display HTML code for the purpose of actually                 ]
;; [ displaying the code and not having that code rendered into                ]
;; [ an HTML display.  It accepts a string and replaces the                    ]
;; [ less-than and greater-than signs with the escape sequences                ]
;; [ that will cause a browser to display those signs instead of               ]
;; [ interpreting them.                                                        ]
;; [---------------------------------------------------------------------------]

CGI-ENCODE-HTML: func [
    "Make HTML tags into HTML viewable escapes (for posting code)"
    CGI-TEXT-TO-ENCODE
] [
    foreach [CGI-TAG-CHAR CGI-ESC-SEQ] ["&" "&amp;" "<" "&lt;" ">" "&gt;" ] [
        replace/all CGI-TEXT-TO-ENCODE CGI-TAG-CHAR CGI-ESC-SEQ
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Here is/are some debugging procedure(s) we can use to find                ]
;; [ out where things might be going wrong.  When a CGI program                ]
;; [ doesn't work, many times it doesn't produce any output at                 ]
;; [ all.                                                                      ]
;; [---------------------------------------------------------------------------]

CGI-DEBUG-MESSAGE: ""
CGI-DEBUG-PAGE: {
<HTML>
<HEAD>
<TITLE>CGI debugging page</TITLE>
</HEAD>
<BODY>
<% CGI-DEBUG-MESSAGE %>
</BODY>
</HTML>
}
CGI-DEBUG-DISPLAY: func [
    CGI-DEBUG-BLOCK [block!]
] [
    CGI-DEBUG-MESSAGE: reform CGI-DEBUG-BLOCK
    CGI-EMIT-HTML build-markup CGI-DEBUG-PAGE
    print CGI-OUTPUT
]

    
