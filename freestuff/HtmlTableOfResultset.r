REBOL [
    Title: "Result-set to html table"
    Purpose: {Given an SQL result set, which comes in the form of
    a block of blocks, generate an html table that can be inserted
    into a larger html page.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a specialized help function for the specific job of reporting     ]
;; [ the results of an SQL query.  The result-set of an SQL query comes in     ]
;; [ the form of a block of blocks, where each sub-block is a row of the       ]
;; [ result-set.  This function makes an html table, from the <table> tag      ]
;; [ through the </table> tag, with each row being one row of the result-set.  ]
;; [ The planned use of this function would be to generate chunks of html      ]
;; [ that would be assembled into a larger page.                               ]
;; [ The function includes a refinement to cause the first row to be emitted   ]
;; [ as a table header.                                                        ]
;; [---------------------------------------------------------------------------]

HTML-TABLE-OF-RESULT-SET: func [
    ROWBLOCK
    /HEADER
    /local HTMLTABLE FIRSTROW
] [
    HTMLTABLE: copy ""
    FIRSTROW: false
    if HEADER [
        FIRSTROW: true
    ]
    append HTMLTABLE rejoin [
        {<table width="100%" border="1">}
        newline
    ]
    foreach ROW ROWBLOCK [
        append HTMLTABLE rejoin ["<tr>" newline]
        foreach COL ROW [
            either FIRSTROW [
                append HTMLTABLE rejoin [
                    "<th>"
                    COL
                    "</th>"
                    newline
                ]
            ] [
                append HTMLTABLE rejoin [
                    "<td>"
                    COL
                    "</td>"
                    newline
                ]
            ]              
        ]
        FIRSTROW: false
        append HTMLTABLE rejoin ["</tr>" newline]
    ]
    append HTMLTABLE rejoin [
        {</table>}
        newline
    ]
    return HTMLTABLE
]

;;Uncomment to test
;TBL1: HTML-TABLE-OF-RESULT-SET [
;    ["AAAA1" "BBBB1" "CCCC1"]
;    ["AAAA2" "BBBB2" "CCCC2"]
;    ["AAAA3" "BBBB3" "CCCC3"]
;    ["AAAA4" "BBBB4" "CCCC4"]
;    ["AAAA5" "BBBB5" "CCCC5"]
;]
;probe TBL1
;TBL2: HTML-TABLE-OF-RESULT-SET/HEADER [
;    ["COL1"  "COL2"  "COL3" ]
;    ["AAAA1" "BBBB1" "CCCC1"]
;    ["AAAA2" "BBBB2" "CCCC2"]
;    ["AAAA3" "BBBB3" "CCCC3"]
;    ["AAAA4" "BBBB4" "CCCC4"]
;    ["AAAA5" "BBBB5" "CCCC5"]
;]
;probe TBL2
;halt

