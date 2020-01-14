REBOL [
    Title: "Printing module using HTML"
    Purpose: {A COBOL-like method for printing basic
    text-oriented business reports in an html file with markup
    such that we can get proper page breaks.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a module for primitive printing.                                  ]
;; [ It puts pre-formatted lines of text into an html file that includes       ]
;; [ markup such that if the html file is printed then requested page          ]
;; [ breaks will ge made correctly.                                            ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These items are the ones that would have to adjusted for a particular     ]
;; [ installation.  They could be pulled out into a configuration file         ]
;; [---------------------------------------------------------------------------]

HTMPRT-INSTALLATION-NAME: "INFORMATION SYSTEMS"
HTMPRT-FILE-ID: %printfile.html
HTMPRT-REPORT-ID: ""

;; [---------------------------------------------------------------------------]
;; [ "Printing" is going to mean appending a print line to the end of          ]
;; [ this big string.  When we "close" the print "file," this big string       ]
;; [ will be written to a file. Actually putting it on paper will be done      ]
;; [ by reading the file with a web browser and using the browser to print.    ]
;; [---------------------------------------------------------------------------]

HTMPRT-FILE: ""

;; [---------------------------------------------------------------------------]
;; [ Here are some other important items, defined here so we can keep          ]
;; [ track of them.                                                            ]
;; [---------------------------------------------------------------------------]

HTMPRT-PAGE-SIZE: 57
HTMPRT-LINE-COUNT: 0

;; [---------------------------------------------------------------------------]
;; [ This is the html markup we will need to make this work.                   ]
;; [---------------------------------------------------------------------------]

HTMPRT-HEAD-DOC: {
<html>
<head>
<style>
.break {page-break-before: always;}
</style>
<title> <% HTMPRT-REPORT-ID %> </title>
</head>
<body>
}

HTMPRT-HEAD-FIRSTPAGE: {
<h1 align="center"> <% HTMPRT-INSTALLATION-NAME %> </h1>
<pre>
}

HTMPRT-HEAD-NEXTPAGE: {
</pre>
<h1 align="center" class="break"> <% HTMPRT-INSTALLATION-NAME %> </h1>
<pre>
}

HTMPRT-FOOT-DOC: {
</pre>
</body>
</html>
}

;; [---------------------------------------------------------------------------]
;; [ This procedure "opens" the print "file," which means we will clear        ]
;; [ out the string and put some initial printer control characters            ]
;; [ into it.  In this module, "control characters" means the html markup      ]
;; [ to cause the proper page break before each new heading when we print.     ]
;; [---------------------------------------------------------------------------]

HTMPRT-OPEN: does [
    HTMPRT-FILE: copy ""
    append HTMPRT-FILE build-markup HTMPRT-HEAD-DOC
    append HTMPRT-FILE build-markup HTMPRT-HEAD-FIRSTPAGE
    HTMPRT-LINE-COUNT: 0
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "closes" the print "file," which means we will             ]
;; [ put the appropriate closing markukp at the end of the string and          ]
;; [ write it to a file.                                                       ]
;; [---------------------------------------------------------------------------]

HTMPRT-CLOSE: does [
    append HTMPRT-FILE build-markup HTMPRT-FOOT-DOC
    write HTMPRT-FILE-ID HTMPRT-FILE
]

;; [---------------------------------------------------------------------------]
;; [ This procedure causes a page skip by adding a heading line with the       ]
;; [ "break" class so that if we print the page, the browser will eject        ]
;; [ a page.                                                                   ]
;; [---------------------------------------------------------------------------]

HTMPRT-EJECT: does [
    append HTMPRT-FILE build-markup HTMPRT-HEAD-NEXTPAGE
    HTMPRT-LINE-COUNT: 0
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "prints" a line passed to it, which means we will          ]
;; [ append the passed line to the file, and add a newline.                    ]
;; [ The refinement of "double" puts an extra newline at the end for           ]
;; [ double spacing.                                                           ]
;; [---------------------------------------------------------------------------]

HTMPRT-PRINT: func [
    HTMPRT-PRINT-LINE
    /DOUBLE
] [
    append HTMPRT-FILE HTMPRT-PRINT-LINE
    append HTMPRT-FILE newline
    HTMPRT-LINE-COUNT: HTMPRT-LINE-COUNT + 1
    if DOUBLE [
        append HTMPRT-FILE rejoin [<br> newline]
        HTMPRT-LINE-COUNT: HTMPRT-LINE-COUNT + 1
    ]
]

;; [---------------------------------------------------------------------------]
;; [ The procedures below use the procedures above for printing in a           ]
;; [ classic COBOL manner.  They print headings automatically, checks for      ]
;; [ page skips, and so on.                                                    ]
;; [ The caller of this module should "do" it early in the program to define   ]
;; [ the items below, and then set the following items to desired values:      ]
;; [ LP-PROGRAM:  Name of the program making the report.                       ]
;; [ LP-REPORT:   50-character report description.                             ]
;; [ LP-SUBTITLE: not used until we figure out how to center it.               ] 
;; [ What these procedures are going to give you is a report of text lines     ]
;; [ in a fixed-width font, like the line printer of the COBOL days.           ]
;; [---------------------------------------------------------------------------]

;; -- Items to be loaded before first use
HTMPRT-LP-PROGRAM: ""
HTMPRT-LP-REPORT: ""
HTMPRT-LP-SUBTITLE: ""
HTMPRT-LP-PAGE-COUNT: 1
HTMPRT-LP-TITLE: copy HTMPRT-INSTALLATION-NAME 
HTMPRT-LP-HEADING-1: ""
HTMPRT-LP-HEADING-2: ""
HTMPRT-LP-USER-HEADING-1: ""
HTMPRT-LP-USER-HEADING-2: ""
HTMPRT-LP-USER-HEADING-3: ""
HTMPRT-LP-USER-HEADING-COUNT: 0
HTMPRT-LP-PROG-LGH: 0
HTMPRT-LP-REPT-LGH: 0
HTMPRT-LP-PROG-20: ""
HTMPRT-LP-REPT-50: ""

;; -- Helper functions for the main printing functions
HTMPRT-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

HTMPRT-FILLER: func [
    "Return a string of a given number of spaces"
    SPACE-COUNT [integer!]
    /local FILLER 
] [
    FILLER: copy ""
    loop SPACE-COUNT [
        append FILLER " "
    ]
    return FILLER
]

HTMPRT-SPACEFILL: func [
    "Left justify a string, pad with spaces to specified length"
    INPUT-STRING
    FINAL-LENGTH
    /local TRIMMED-STRING
           LENGTH-OF-TRIMMED-STRING
           NUMBER-OF-SPACES-TO-ADD
           FINAL-PADDED-STRING
] [
    TRIMMED-STRING: copy ""
    TRIMMED-STRING: trim INPUT-STRING
    LENGTH-OF-TRIMMED-STRING: length? TRIMMED-STRING
    either (LENGTH-OF-TRIMMED-STRING < FINAL-LENGTH) [
        NUMBER-OF-SPACES-TO-ADD: (FINAL-LENGTH - LENGTH-OF-TRIMMED-STRING)
        FINAL-PADDED-STRING: copy TRIMMED-STRING
        loop NUMBER-OF-SPACES-TO-ADD [
            append FINAL-PADDED-STRING " "
        ]
    ] [
        FINAL-PADDED-STRING: COPY ""
        FINAL-PADDED-STRING: HTMPRT-SUBSTRING TRIMMED-STRING 1 FINAL-LENGTH
    ]
]

;; -- Main printing functions 
HTMPRT-LP-PRINT-USER-HEADINGS: does [
    HTMPRT-LP-USER-HEADING-COUNT: 0
    if (HTMPRT-LP-USER-HEADING-1 <> "") [
        HTMPRT-PRINT HTMPRT-LP-USER-HEADING-1
        HTMPRT-LP-USER-HEADING-COUNT: HTMPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (HTMPRT-LP-USER-HEADING-2 <> "") [
        HTMPRT-PRINT HTMPRT-LP-USER-HEADING-2
        HTMPRT-LP-USER-HEADING-COUNT: HTMPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (HTMPRT-LP-USER-HEADING-3 <> "") [
        HTMPRT-PRINT HTMPRT-LP-USER-HEADING-3
        HTMPRT-LP-USER-HEADING-COUNT: HTMPRT-LP-USER-HEADING-COUNT + 1
    ]
    if (HTMPRT-LP-USER-HEADING-COUNT > 0) [
        HTMPRT-PRINT ""
    ]
] 
  
HTMPRT-LP-OPEN: does [
    HTMPRT-OPEN
    HTMPRT-LP-PAGE-COUNT: 1
    HTMPRT-LP-PROG-LGH: length? HTMPRT-LP-PROGRAM
    either (HTMPRT-LP-PROG-LGH >= 20) [
        HTMPRT-LP-PROG-20: HTMPRT-SUBSTRING HTMPRT-LP-PROGRAM 1 20
    ] [
        HTMPRT-LP-PROG-20: HTMPRT-SPACEFILL HTMPRT-LP-PROGRAM 20
    ]
    HTMPRT-LP-REPT-LGH: length? HTMPRT-LP-REPORT
    either (HTMPRT-LP-REPT-LGH >= 50) [
        HTMPRT-LP-REPT-50: HTMPRT-SUBSTRING HTMPRT-LP-REPORT 1 50
    ] [
        HTMPRT-LP-REPT-50: HTMPRT-SPACEFILL HTMPRT-LP-REPORT 50
    ]
    HTMPRT-LP-HEADING-1: rejoin [
        HTMPRT-LP-PROG-20
        HTMPRT-FILLER 43
        HTMPRT-LP-TITLE
        HTMPRT-FILLER 52
        now/date
    ]
    HTMPRT-LP-HEADING-2: rejoin [
        HTMPRT-LP-REPT-50
        HTMPRT-FILLER 13
        HTMPRT-FILLER 39    ;; subtitle, eventually
        HTMPRT-FILLER 52
        "Page "
        to-string HTMPRT-LP-PAGE-COUNT
    ]
    HTMPRT-PRINT HTMPRT-LP-HEADING-1
    HTMPRT-PRINT/DOUBLE HTMPRT-LP-HEADING-2
    HTMPRT-LP-PRINT-USER-HEADINGS
]

HTMPRT-LP-CLOSE: does [
    HTMPRT-CLOSE
]

HTMPRT-LP-PRINT: func [
    HTMPRT-LP-PRINT-LINE
    /DOUBLE  ;; not used at this time 
] [
    if (HTMPRT-LINE-COUNT >= HTMPRT-PAGE-SIZE) [
        HTMPRT-LINE-COUNT: 0
        HTMPRT-LP-PAGE-COUNT: HTMPRT-LP-PAGE-COUNT + 1
        HTMPRT-LP-HEADING-2: copy ""
        HTMPRT-LP-HEADING-2: rejoin [
            HTMPRT-LP-REPT-50
            HTMPRT-FILLER 13
            HTMPRT-FILLER 39    ;; subtitle, eventually
            HTMPRT-FILLER 52
            "Page "
            to-string HTMPRT-LP-PAGE-COUNT
        ]
        HTMPRT-EJECT
        HTMPRT-PRINT HTMPRT-LP-HEADING-1 
        HTMPRT-PRINT/DOUBLE HTMPRT-LP-HEADING-2
        HTMPRT-LP-PRINT-USER-HEADINGS
    ]
    HTMPRT-PRINT HTMPRT-LP-PRINT-LINE
]
    
    
    
