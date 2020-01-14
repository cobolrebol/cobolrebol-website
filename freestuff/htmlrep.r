TITLE
HTML report

SUMMARY
This is a module to help make a "report" that is directed to an html table.
It provides services to "open" and "close" the report, and to emit heading
and detail lines.  The result will be a single html file for viewing on
a screen.  For a paper copy of the "report," one would print the html page.
The module does not provide any page breaks that would make the printed
version of this page look good.  Controlling printing to physical paper
is not part of the mission of html.

DOCUMENTATION
Load the module into your program with:

do %htmlrep.r

Before the first call:

1.  Put a file name in HTMLREP-FILE-ID.  This should be a value with
    the type of "file."  In other words, put a percent sign in front of it.
2.  Put a value in HTMLREP-TITLE.
3.  Put a program in HTMLREP-PROGRAM-NAME.  This will appear in a footer.
4.  call HTMLREP-OPEN.  

Optionally, before "printing" the first detail line, call HTMLREP-EMIT-HEAD
in the following manner:

HTMLREP-EMIT-HEAD ["literal-1" ... "literal-n"]

where literal-1, etc., are strings to be turned into <TH> entries.

To "print" a line of data, call HTMREP-EMIT-LINE in the following manner:

HTMLREP-EMIT-LINE reduce [word-1...word-n]

where word-n is the word whose value you want to print.  The procedure will
generate a <TD> entry for each word, in one row of an html table.
Historical note: In the first version of this module, we just passed the
words in a block and did not reduce the block, and the HTMLREP-EMIT-LINE
procedure used the "get" function to get the values of the words.
This turned out not to work if the words passed in were in an object, so
we moved the "reduction" process up to the level of the caller.
Now we pass values to HTMLREP-EMIT-LINE instead of words.

At the end:

Call HTMLREP-CLOSE.  You MUST do this step because all the other procedures
just build up an html string in memory.  The HTMLREP-CLOSE procedure actually
writes the data to disk under the name you loaded into HTMLREP-FILE-ID.

SCRIPT
REBOL [
    Title: "HTML report"
]

;; [---------------------------------------------------------------------------]
;; [ Items set up by the caller.                                               ]
;; [---------------------------------------------------------------------------]

HTMLREP-FILE-ID: %htmlrep.html
HTMLREP-TITLE: "&nbsp;"
HTMLREP-PRE-STRING: "&nbsp;"
HTMLREP-POST-STRING: "&nbsp;"
HTMLREP-PROGRAM-NAME: "&nbsp;"
HTMLREP-CODE-BLOCK: "&nbsp;"

;; [---------------------------------------------------------------------------]
;; [ Internal working items.                                                   ]
;; [---------------------------------------------------------------------------]

HTMLREP-FILE-OPEN: false

;; [---------------------------------------------------------------------------]
;; [ This is the top of the html page.                                         ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE-HEAD: {
<html>
<head>
<title> <%HTMLREP-TITLE%> </title>
<style>
body {
   background: #F2F2E3;
}
h1 {
    color: #9931fE;
    font-family: rial, helvetica, sans-serif;
}
th {
    font-family: arial, helvetica, sans-serif;
}
td {
    font-family: arial, helvetica, sans-serif;
}
p {
    font-family: arial, helvetica, sans-serif;
}
</style>
</head>

<body>
<table width="100%" border="0">
<tr>

<td><img border=0 alt="Company logo"
src="data:image/gif;base64,R0lGODlhbABsAPQAAAAAAAgMDRQbHB0mKCYwMi05OzRCRDtKTEFRVEdYW0xfYlJl
aVdsb1xydWF4e2V9gWqDhwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAACH5BAAAAAAALAAAAABsAGwAAAX+ICSOZGmeaKqubOu+cCzP
dG3feK7vfO//wKBwSCwaj8ikcslMNhjQKMPRrEIaCgRhAOh6v10BAbGgWoWORCEA
bru/AoPicd45ENy3ft8tzOs1CgR8hIUGDIAvDwgChY6FAgqJKwlsj5eEBA2TJgyN
mKCECZwiDwahqHwEpJ6YBAcIsQYElqleBZwIlwYLKQ4KBbYAvYCmjwZmLA4HtZcC
iQ95hAKIMQ7BmJJ10Y4FdDQKzXzP29J8BjgN4nraVtyGOuqZgNiE6Dvye9VWuoUD
PvncHKjDwFGAZDwWvAnwrcqDdW/a+TjghpiVeqqGmAMw8IxCR5uEPFigBcA9d5/+
7JEq0q8QwpU/HjpaBVNIS0IWa/qQWSiAziAJjv0EkhLnUB8FHx31cWrm0h4Q3yB4
uuOjo31Ub1BUmjVHUT7/ut54cAmXWBtWC009W+OmKLY1Bj3CChfGVz5067rA9FIv
iwaY/MZIylWwi7SFDL9wS0ixC8Z8HLeAvEcHgcuYM2vezHlzyB2U9egQhrdH6Dej
SevJe+O0m9Sq3bC24brNZxux38xui2k3DAQF7goTcKBv6948HCwwIPwSAd+0Ma31
sQDjJYnUMXUEogDUdCCEnQoJ+sjnEMCXzAdx4LwIKOM8Ln0PspEQdh/yi1hXKSQ/
kdpgkBOEf0OEB1J/j8z7F0RUemz3A4FD7MeHeg8maER32QxoYRFkYRJWhY4oGISE
pYGo1hGIFUITfhsa0dwe9+UA4X+gMMRiiEjwVNaNJyIBYBujxNfiES/ukRMOMxaR
Yk+33ZCkfqEEcGQNTxKhIyZBOjkkEgY6B98LVRZBXpQINBQDeo5kuURTqARgQJMq
PCBImEewmQpxC8AJAQMk1TchdHXmltsAX64pKGkinoHhoaBQU1MDRTLaRpk/PUCi
pF9o8lQrmLYhwJRHVdJpGDE+9UACkaISiWHV5XaIZBDIaQCDewTgh5mwivCLFn52
EQABBiQAaK4kPCAFscgmq+yyzDbr7LNJhAAAOw=="></td>

<td><H1>REBOL Reporting Services</H1></td>
</tr>
</table>
<hr>
<p>
Created on: <% now %>
</p>
<hr>

<h1> <%HTMLREP-TITLE%> </h1>

<p>
<% HTMLREP-PRE-STRING %>
</p>

<table width="100%" border="1">
}

;; [---------------------------------------------------------------------------]
;; [ This is the end of the html page.                                         ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE-FOOT: {
</table>
<p>
<% HTMLREP-POST-STRING %> 
</p>
<hr>
<p>
The above report was produced by the Information Systems Division.
Refer to a program called "<% HTMLREP-PROGRAM-NAME %>."
</p>
<hr>
<pre>
<% HTMLREP-CODE-BLOCK %>
</pre>
</body>
</html>
}

;; [---------------------------------------------------------------------------]
;; [ This is the area where we will build up the html page in memory.          ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE: make string! 5000

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to "open" the report.                               ]
;; [ The "build-markup" function will replace the placeholders in the html     ]
;; [ with the values resulting from their evaluation.                          ]
;; [---------------------------------------------------------------------------]

HTMLREP-OPEN: does [
    HTMLREP-PAGE: copy ""
    append HTMLREP-PAGE build-markup HTMLREP-PAGE-HEAD
    append HTMLREP-PAGE newline
    HTMLREP-FILE-OPEN: true
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to "close" the report.                              ]
;; [ It writes to disk the html page we have built up in memeory.              ]
;; [---------------------------------------------------------------------------]

HTMLREP-CLOSE: does [
    append HTMLREP-PAGE build-markup HTMLREP-PAGE-FOOT
    append HTMLREP-PAGE newline
    write HTMLREP-FILE-ID HTMLREP-PAGE
    HTMLREP-FILE-OPEN: false
]

;; [---------------------------------------------------------------------------]
;; [ This procedure emits a row of an html table containing heading            ]
;; [ elements supplied by the caller in a block of strings.                    ]
;; [---------------------------------------------------------------------------]

HTMLREP-EMIT-HEAD: func [
    "Emit a heading row with literals supplied in a block"
    HTMLREP-HEADING-BLOCK [block!]
] [
    append HTMLREP-PAGE "<TR>"
    foreach HTMLREP-HEAD-LIT HTMLREP-HEADING-BLOCK [
        append HTMLREP-PAGE "<TH>"
        append HTMLREP-PAGE to-string HTMLREP-HEAD-LIT ; to-string just in case
        append HTMLREP-PAGE "</TH>"                    ; caller supplied words
    ]
    append HTMLREP-PAGE "</TR>"
    append HTMLREP-PAGE newline
]

;; [---------------------------------------------------------------------------]
;; [ This procedure emits a row of an html table containing the values of      ]
;; [ words supplied by the caller in a block.                                  ]
;; [ Note the requirement that the caller "reduce" the block passed to this    ]
;; [ function so that we are getting values and not words.                     ]
;; [---------------------------------------------------------------------------]

HTMLREP-EMIT-LINE: func [
    "Emit a detail row with values supplied in a block"
    HTMLREP-DETAIL-BLOCK [block!]
] [
    append HTMLREP-PAGE "<TR>"
    foreach HTMLREP-VALUE HTMLREP-DETAIL-BLOCK [
        append HTMLREP-PAGE "<TD>"
        append HTMLREP-PAGE HTMLREP-VALUE
        append HTMLREP-PAGE "</TD>"
    ]
    append HTMLREP-PAGE "</TR>"
    append HTMLREP-PAGE newline
]

