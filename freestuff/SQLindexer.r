REBOL [
    Title: "SQL script indexer"
    Purpose: {Create a primitive html index of all sql scripts in a
    specified folder, using structured text in a comment block.}
]

;; [---------------------------------------------------------------------------]
;; [ This program solves a site-specific problem of making an html index of    ]
;; [ sql scripts in a given folder, assuming that each script has a            ]
;; [ comment block of structured text that can be parsed out and used for      ]
;; [ the index.  The text must look like this sample:                          ]
;; [                                                                           ]
;; [ /*                                                                        ]
;; [ AUTHOR: "J Smith"                                                         ]
;; [ DATE-WRITTEN: 29-JUN-2017                                                 ]
;; [ DATABASE: "database-name"                                                 ]
;; [ SEARCH-WORDS: ["keyword-1" "keyword-2"]                                   ]
;; [ REMARKS: {Multi-line free-format description of the script.}              ]
;; [ COLUMN-NAMES: {column-1,column-2,column-3}                                ]
;; [ */                                                                        ]
;; [                                                                           ]
;; [ Note that there can be any number of search words, and any number of      ]
;; [ column names.  All of these items are optional and the program will       ]
;; [ just produce blanks in the index for anything that is missing.            ]
;; [                                                                           ]
;; [ The index produced by this program is very primitive. It just puts the    ]
;; [ items in the comment block into a row on an html page.                    ]
;; [---------------------------------------------------------------------------]

;; To save mouse clicks, go to the place where scripts are likely
;; to be found.  This will change for each installation.

change-dir %/F/PROGRAMMING/SQL/CollectedProjects/

;; Find the folder where the sql scripts are located, go there, and find
;; all the sql scripts in it.

if not dir? PROGRAMS-DIR: request-dir [
    alert "No directory selected."
    quit
]

program-file?: func ["Returns true if file is a SQL file" file] [
    find [%.sql] find/last file "."
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

;; HTML fragments to assemble into a page

HTML-HEAD: {
<html>
<head>
<title>SQL script</title>
</head>
<body>
<h1>SQL scripts we have written</h1>
<table width="100%" border="1">
}

HTML-FOOT: {
</table>
</body>
</html>
}

;; The html file that we will create.

HTML-FILE-ID: %SqlScriptIndex.html
HTML-FILE: ""

HTML-ROW: {
<tr>
<td> <% WS-DATABASE %> </td>
<td> <a href="<%WS-FILEID%>"> <% WS-FILEID %> </a> </td>
<td> <% WS-DATEWRITTEN %> </td>
<td> <% WS-REMARKS %> </td>
</tr>
}

;; Data items that we will put on the index.

WS-DATABASE: ""
WS-FILEID: ""
WS-DATEWRITTEN: ""
WS-REMARKS: ""

;; Begin.

append HTML-FILE HTML-HEAD
append HTML-FILE newline

DEBUG-FILEID: ""

foreach SCRIPTFILE PROGRAM-NAMES [
    DEBUG-FILEID: to-string SCRIPTFILE
    print ["Indexing " DEBUG-FILEID] 
    SCRIPTCODE: read SCRIPTFILE
    COMMENTBLOCK: copy ""
    parse/case SCRIPTCODE [thru "/*" copy COMMENTBLOCK to "*/"]
    if greater? (length? COMMENTBLOCK) 0 [
        AUTHOR: none
        DATE-WRITTEN: none
        DATABASE: none
        SEARCH-WORDS: none
        REMARKS: none
        COLUMN-NAMES: none 
        WS-DATABASE: copy ""
        WS-FILEID: copy ""
        WS-DATEWRITTEN: copy ""
        WS-REMARKS: copy ""
        do load COMMENTBLOCK
        if value? DATABASE [
            WS-DATABASE: copy DATABASE
        ]
        if value? DATE-WRITTEN [
;;          WS-DATEWRITTEN: to-string DATE-WRITTEN
            WS-DATEWRITTEN: rejoin [
                DATE-WRITTEN/year
                "/"
                DATE-WRITTEN/month
                "/"
                DATE-WRITTEN/day
            ]
        ]
        if value? REMARKS [
            WS-REMARKS: copy REMARKS
        ]
        WS-FILEID: to-string SCRIPTFILE
        append HTML-FILE build-markup HTML-ROW
    ]
]

;; Finish the file and write it to disk.

append HTML-FILE HTML-FOOT
append HTML-FILE newline

write HTML-FILE-ID HTML-FILE 

;; Alert that we are done.

print "Done."
halt


