REBOL [
    Title: "Take a letter, Maria"
    Purpose: {Use a skeleton of a basic letter and fill it in
    with text requested from a window.  This saves us the labor
    of opening a word-processing program to type a basic letter.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a program named after the song that starts with,                  ]
;; [ "Take a letter, Maria," by R. B. Greaves.                                 ]
;; [ It provides a box for the text of a letter, and then fills that text      ]
;; [ into a letter template and formats an html page suitable for printing.    ]
;; [ This program was created because the author got tired of fighting         ]
;; [ with a popular large word-processing program to do the logically          ]
;; [ simple task of writing a basic letter for printing.                       ]
;; [ The reason this works is that there are features in html that control     ]
;; [ the margins around various parts of the page content.  In the template    ]
;; [ below, the margins of the page are set to zero, which forces any          ]
;; [ browser-produced headings off the physical page.  Then the margins        ]
;; [ around the body move the body into the page.  The end result is that      ]
;; [ the html page contains the letter you wrote without any headers or        ]
;; [ footers or page numbers or file names produced by the browser.            ]
;; [ To use this program for your own purposes, modify the template.           ]
;; [ Note that when typing the body of the letter into the text area,          ]
;; [ if you want what will appear to be a paragraph break, use the "enter"     ]
;; [ key at the end of a paragraph to move to the next line, and then          ]
;; [ immediately hit the "enter" key again to make a blank line.               ]
;; [ The result of these keystrokes is that your text will contain a           ]
;; [ double line-feed at the point where you want a blank line in the          ]
;; [ letter body.  The program replaces double line-feeds with the "br"        ]
;; [ tag to make a blank line.                                                 ]
;; [ Note also that the trick below of fiddling with the margin seems to       ]
;; [ work in Chrome but not in IE.  To make it suppress the headers and        ]
;; [ footers in IE, it seems you have to go to the "page setup" menu and       ]
;; [ turn them off manually before printing.                                   ]
;; [---------------------------------------------------------------------------]

LETTER-TEMPLATE: {
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Letter</title>
    <style type="text/css" media="print">
    @page 
    {
        size:  auto;  
        margin: 0mm;  /* forces header and footer off the physical page */
    }
  
    html
    {
        margin: 0px;  
    } 
  
    body  /* margins around the content */
    {
	margin-top: 25mm;
	margin-bottom: 25mm;
	margin-left: 25mm;
	margin-right: 25mm;
    }
    </style>
</head>
<body>

<p>
<% now/date %>
</p>

<p>
Mister Smith<br>
123 Main St<br>
Minneapolis MN 55431<br>
</p>

<p>
<% LETTER-TO %>
</p>

<p>
Dear <%LETTER-SALUTATION%>:
</p>

<%LETTER-BODY%>

<p>
Sincerely yours,
</p>

<br><br><br>

<p>
Mister Smith
</p>

</body>
</html>
}

DOUBLE-LF: rejoin [newline newline]
LETTER-TO: copy ""
LETTER-SALUTATION: copy ""
LETTER-BODY: copy ""
DEFAULT-FILEID: %UntitledLetter.html
SAVE-FILEID: none

FORMAT-LETTER: does [
    either equal? "" MAIN-FILEID/text [
        SAVE-FILEID: DEFAULT-FILEID
    ] [
        SAVE-FILEID: to-file trim/all get-face MAIN-FILEID
    ]
    LETTER-TO: MAIN-TO/text
    LETTER-SALUTATION: get-face MAIN-SALUTATION
    LETTER-BODY: MAIN-BODY/text
    replace/all LETTER-TO newline </br>
    replace/all LETTER-BODY DOUBLE-LF "<br><br>"
    write SAVE-FILEID build-markup LETTER-TEMPLATE
    browse SAVE-FILEID 
]

MAIN-WINDOW: layout [
    across
    banner "Take a letter, Maria" font [shadow: none]
    return
    label "TO"
    tab
    MAIN-TO: area 400x60 as-is
    return
    label "DEAR"
    tab
    MAIN-SALUTATION: field 400
    return
    label "BODY"
    tab
    MAIN-BODY: area 800x600
    return
    label "FILEID"
    tab
    MAIN-FILEID: field 400 "UntitledLetter.html"
    return
    button "Quit" [quit]
    button "Format" [FORMAT-LETTER]
]


view center-face MAIN-WINDOW




