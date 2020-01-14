REBOL [
    Title: "Parse on comma"
    Purpose: {Parse a string on the comma, BUT, account for the situation 
    where part of the string is an item containing a comma and enclosed
    in quotes. This is how strings with commas come out of a spreadsheet
    when the spreadsheet is saved as a CSV file.}
]

;; [---------------------------------------------------------------------------]
;; [ Sometimes one has to take apart a CSV file from a popular spreadsheet     ]
;; [ program and some of the columns themselves have commas.  In those cases   ]
;; [ the spreadsheet program surrounds those value with quotes.                ]
;; [ This function parses a string of comma-separated values with the          ]
;; [ assumption that if any of the values contain commas, those values will    ]
;; [ be enclosed in quotes.  And yes, a simple solution would be to use a      ]
;; [ different separator, like the pipe symbol, but sometimes one must work    ]
;; [ within constraints.                                                       ]
;; [ The plan of action will be to make a first pass through the string        ]
;; [ and replace the commans inside quoted strings with some other character,  ]
;; [ then parse on the comma, then for each parsed field replace the "other"   ]
;; [ character with a comma.                                                   ]
;; [---------------------------------------------------------------------------]

PARSE-ON-COMMA: func [
    INSTRING
    /local OUTBLOCK IN-FIELD  
] [
    OUTBLOCK: copy []
    INFIELD: false
    foreach BYTE INSTRING [
        either equal? BYTE {"} [
            either IN-FIELD [
                IN-FIELD: false
            ] [
                IN-FIELD: true
            ]
        ] [
            if IN-FIELD [
                replace BYTE "," "|"
            ]
        ]
    ]
    OUTBLOCK: parse/all INSTRING ","
    foreach COL OUTBLOCK [
        replace/all COL "|" ","
    ]
    return OUTBLOCK 
]

;;Uncomment to test
;TEST1: {123,"X,Y",ZZZZZZ,456,"Brainerd, MN" 56401}
;PROBE PARSE-ON-COMMA TEST1 
;halt

