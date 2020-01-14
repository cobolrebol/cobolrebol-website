REBOL [
    Title: "Date dissection"
    Purpose: {Get the month, day, and year from a date.}
]

;; [---------------------------------------------------------------------------]
;; [ This function takes a REBOL date and returns the few things that          ]
;; [ REBOL does NOT produce when you work with a date.                         ]
;; [ It returns a block of six things; the year, month, and day as integers,   ]
;; [ and the year, month, and day as strings.  The month and day strings       ]
;; [ always are two characters.                                                ]
;; [---------------------------------------------------------------------------]

DATE-DISSECTION: func [
    DATEVAL
    /local DATEBLOCK
] [
    DATEBLOCK: copy []
    append DATEBLOCK DATEVAL/year
    append DATEBLOCK DATEVAL/month
    append DATEBLOCK DATEVAL/day
    append DATEBLOCK to-string DATEVAL/year
    either lesser? DATEVAL/month 10 [
        append DATEBLOCK rejoin ["0" to-string DATEVAL/month]
    ] [
        append DATEBLOCK to-string DATEVAL/month
    ]
    either lesser? DATEVAL/day 10 [
        append DATEBLOCK rejoin ["0" to-string DATEVAL/day]
    ] [
        append DATEBLOCK to-string DATEVAL/day
    ]  
    return DATEBLOCK  
]

;;Uncomment to test
;set [yyyy-int mm-int dd-int yyyy-str mm-str dd-str] DATE-DISSECTION request-date
;print ["Year integer = " mold yyyy-int]
;print ["Month integer = " mold mm-int]
;print ["Day integer = " mold dd-int]
;print ["Year string = " mold yyyy-str]
;print ["Month string = " mold mm-str]
;print ["Day string = " mold dd-str]
;halt

