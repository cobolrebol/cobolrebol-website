REBOL [
    Title: "No double spaces"
    Purpose: {Take double spaces out of a string, 
    for cosmetic purposes.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function to take a string and remove all cases of more than     ]
;; [ one consecutive blank.  It was created for tidying up lines of a log      ]
;; [ file where the line was assembled out of data items that could be         ]
;; [ blank and thus would result in a line with several blanks in a row.       ]
;; [ The way it works is to copy the input string to an output string one      ]
;; [ character at a time, but, pass each character through a one-character     ]
;; [ "holding area" so the if we encounter a blank we can check to see if      ]
;; [ the previous character was a blank.                                       ]
;; [---------------------------------------------------------------------------]

NO-DOUBLE-SPACES: func [
    INSTRING
    /local BUFFER OUTSTRING
] [
    BUFFER: copy ""
    OUTSTRING: copy ""
    foreach CHAR INSTRING [
;;;;;;  print [CHAR " " BUFFER " " OUTSTRING] ;; for debugging 
        either equal? CHAR #" " [
            if not-equal? BUFFER #" " [
                append OUTSTRING BUFFER
                BUFFER: CHAR
            ]
        ] [
            append OUTSTRING BUFFER
            BUFFER: CHAR
        ]
    ]
    append OUTSTRING BUFFER ;; Don't forget the last character. 
    return trim reverse trim reverse OUTSTRING
]

;;Uncomment to test
;print rejoin ["'" NO-DOUBLE-SPACES "ABCDEF" "'"]
;print rejoin ["'" NO-DOUBLE-SPACES "ABC DEF" "'"]
;print rejoin ["'" NO-DOUBLE-SPACES "ABC   DEF" "'"]
;print rejoin ["'" NO-DOUBLE-SPACES "   ABC    DEF   " "'"]
;halt


