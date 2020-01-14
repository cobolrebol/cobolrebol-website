REBOL [
    Title: "Script indexer"
    Purpose: {Read throught all REBOL scripts in a selected
    directory and extract the "Title" and "Purpose" text.
    Put those items into an html page.  The html page will
    not be a full page, but will be a table only.  This is
    so the table can be inserted manually into some other
    page with other data and the appropriate headers.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a quick-and-dirty program that reads all the rebol scripts in     ]
;; [ a specified folder and locates the "Title" and "Purpose" items in the     ]
;; [ header.  It than makes an indexing web page with the file name, the       ]
;; [ title, and the purpose.  The file name is written as an html link to      ]
;; [ the script.  The html that is generated is not a full page, but is a      ]
;; [ table only, so that it can be inserted into some other web page.          ]
;; [ This program was written to make an indexing page for a copy of the       ]
;; [ rebol.org script library. That library got lost, then recovered,          ]
;; [ and after the recovery I made my own personal copy to guard against       ]
;; [ another outage.  I needed an index, but not a fancy one, so I did this.   ]
;; [---------------------------------------------------------------------------]

if not dir? PROGRAMS-DIR: request-dir [
    alert "No directory selected."
    quit
]

program-file?: func ["Returns true if file is an REBOL program" file] [
    find [%.r] find/last file "."
]

change-dir PROGRAMS-DIR
PROGRAM-NAMES: []
PROGRAM-NAMES: read %.

while [not tail? PROGRAM-NAMES] [
    either program-file? first PROGRAM-NAMES 
        [PROGRAM-NAMES: next PROGRAM-NAMES]
        [remove PROGRAM-NAMES]
]
PROGRAM-NAMES: head PROGRAM-NAMES
if empty? PROGRAM-NAMES [
    alert "No programs found" 
    halt 
]

HTML-HEAD: {
<table width="100%" border="1">
}

HTML-FOOT: {
</table>
}

HTML-ROW: {
<tr>
<td> <a href="<%WS-FILEID%>"> <% WS-FILEID %> </a> </td>
<td> <% WS-TITLE %> </td>
<td> <% WS-PURPOSE %> </td>
</tr>
}

HTML-FILE-ID: %ScriptTable.html
HTML-FILE: ""

WS-FILEID: ""
WS-TITLE: ""
WS-PURPOSE: ""

append HTML-FILE HTML-HEAD
append HTML-FILE newline

DEBUG-CODE: ""
DEBUG-FILEID: ""

foreach SCRIPTFILE PROGRAM-NAMES [
    DEBUG-FILEID: to-string SCRIPTFILE
    print ["Checking " DEBUG-FILEID] 
    SCRIPTCODE: copy ""
    WS-TITLE: copy ""
    WS-PURPOSE: copy ""
    if attempt [SCRIPTCODE: do first load/header SCRIPTFILE] [
        DEBUG-CODE: to-string SCRIPTCODE
        WS-FILEID: to-string SCRIPTFILE 
        if SCRIPTCODE/Title [
            WS-TITLE: copy SCRIPTCODE/Title
        ]
        if SCRIPTCODE/Purpose [
            WS-PURPOSE: copy SCRIPTCODE/Purpose
        ] 
        append HTML-FILE build-markup HTML-ROW
    ]
]

append HTML-FILE HTML-FOOT
append HTML-FILE newline

write HTML-FILE-ID HTML-FILE 

print "Done."
halt

