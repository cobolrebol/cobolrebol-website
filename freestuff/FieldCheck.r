REBOL [
    Title: "Analyze a string for what is in it"
    Purpose: {Go through a string a character at a time and make
    notes about the composition of the string.  Return the results
    in a block.}
]

;; [---------------------------------------------------------------------------]
;; [ This object was written for the specific purpose of checking input        ]
;; [ fields on a window.  It goes through an input string a character at a     ]
;; [ time and assembles enough information so that a calling program can       ]
;; [ check relevant features with fewer lines of code.  For example one of     ]
;; [ the results is a flag that indicates the string is "numberic" meaning     ]
;; [ consisting of all numbers.                                                ]
;; [ Results are returned in a block.  To see how to use the function,         ]
;; [ look at the comments at the end which can be uncommented to test the      ]
;; [ function.                                                                 ]
;; [ This function is put into a context because it is rather long and         ]
;; [ there was concern that the large number of words in it could be in        ]
;; [ conflict with other words in a calling program.                           ]
;; [---------------------------------------------------------------------------]

FIELDCHECK: context [

    LETTERS-UC: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    LETTERS-LC: "abcdefghijklmnopqrstuvwxyz"
    DIGITS: "0123456789"
    RESULTS: []
    ISNUMERIC: false
    ISALPHABETIC: false
    ISALPHANUMERIC: false
    ISMIXED: false
    HASLETTER: false
    HASUPPER: false
    HASLOWER: false
    HASDIGIT: false
    HASOTHER: false
    STARTSWITHLETTER: false
    LEADINGSPACECOUNT: 0
    TRAILINGSPACECOUNT: 0
    EMBEDDEDSPACECOUNT: 0
    DECIMALCOUNT: 0
    LETTERCOUNT: 0
    DIGITCOUNT: 0
    INPUTLENGTH: 0
    FIRSTNONBLANKLOC: 0
    LASTNONBLANKLOC: 0
    INPUTSUB: 0

    ANALYZE-STRING: func [
        INPUT-STRING [string!]
    ] [
        RESULTS: copy []
        ISNUMERIC: false
        ISALPHABETIC: false
        ISALPHANUMERIC: false
        ISMIXED: false
        HASLETTER: false
        HASUPPER: false
        HASLOWER: false
        HASDIGIT: false
        HASOTHER: false
        STARTSWITHLETTER: false
        LEADINGSPACECOUNT: 0
        TRAILINGSPACECOUNT: 0
        EMBEDDEDSPACECOUNT: 0
        DECIMALCOUNT: 0
        LETTERCOUNT: 0
        DIGITCOUNT: 0
        INPUTLENGTH: length? INPUT-STRING
        FIRSTNONBLANKLOC: 0
        LASTNONBLANKLOC: 0

    ;; -- Find the location of the first non-blank.
        INPUTSUB: 1
        loop INPUTLENGTH [
            TESTBYTE: copy ""
            TESTBYTE: to-string pick INPUT-STRING INPUTSUB
            if not-equal? TESTBYTE " " [
                FIRSTNONBLANKLOC: INPUTSUB
                break
            ] 
            INPUTSUB: INPUTSUB + 1
        ]
    ;; -- Find the location of the last non-blank.
        INPUTSUB: INPUTLENGTH
        loop INPUTLENGTH [
            TESTBYTE: copy ""
            TESTBYTE: to-string pick INPUT-STRING INPUTSUB
            if not-equal? TESTBYTE " " [
                LASTNONBLANKLOC: INPUTSUB
                break
            ] 
            INPUTSUB: INPUTSUB - 1
        ]
   
    ;; -- Now it will be easier to analyze the string.
        INPUTSUB: 1
        loop INPUTLENGTH [
            TESTBYTE: copy ""
            TESTBYTE: to-string pick INPUT-STRING INPUTSUB
            if equal? TESTBYTE " " [
                if (INPUTSUB < FIRSTNONBLANKLOC) [
                    LEADINGSPACECOUNT: LEADINGSPACECOUNT + 1
                ]
                if (INPUTSUB > LASTNONBLANKLOC) [
                    TRAILINGSPACECOUNT: TRAILINGSPACECOUNT + 1
                ]
                if (INPUTSUB > FIRSTNONBLANKLOC) and (INPUTSUB < LASTNONBLANKLOC) [
                    EMBEDDEDSPACECOUNT: EMBEDDEDSPACECOUNT + 1  
                ]
                HASOTHER: true
            ]
            if not-equal? TESTBYTE " " [
                 if find LETTERS-UC TESTBYTE [
                     HASUPPER: true
                 ]
                 if find LETTERS-LC TESTBYTE [
                     HASLOWER: true
                 ]
                 if find rejoin [LETTERS-UC LETTERS-LC] TESTBYTE [
                     HASLETTER: true
                     LETTERCOUNT: LETTERCOUNT + 1
                 ]
                 if find DIGITS TESTBYTE [
                     HASDIGIT: true
                     DIGITCOUNT: DIGITCOUNT + 1 
                 ]
                 if not find rejoin [LETTERS-UC LETTERS-LC DIGITS] TESTBYTE [
                     HASOTHER: true
                 ]
                 if equal? TESTBYTE "." [
                     DECIMALCOUNT: DECIMALCOUNT + 1 
                 ]
            ]

            INPUTSUB: INPUTSUB + 1
        ] 

;; -- Use the above results for some outside-of-loop determinations.
        if (DIGITCOUNT = INPUTLENGTH) [
            ISNUMERIC: true
        ]
        if (LETTERCOUNT = INPUTLENGTH) [
            ISALPHABETIC: true
        ]
        if (LETTERCOUNT + DIGITCOUNT) = INPUTLENGTH [
            ISALPHANUMERIC: true
        ]
        if (LETTERCOUNT + DIGITCOUNT) < INPUTLENGTH [
            ISMIXED: true
        ]  
        TESTBYTE: to-string pick INPUT-STRING FIRSTNONBLANKLOC
        if find rejoin [LETTERS-UC LETTERS-LC] TESTBYTE [  
            STARTSWITHLETTER: true
        ]   

;; -- Prepare and return the block of results.
        RESULTS: compose reduce [
            ISNUMERIC
            ISALPHABETIC
            ISALPHANUMERIC
            ISMIXED
            HASLETTER
            HASUPPER
            HASLOWER
            HASDIGIT
            HASOTHER
            STARTSWITHLETTER
            LEADINGSPACECOUNT
            TRAILINGSPACECOUNT
            EMBEDDEDSPACECOUNT
            DECIMALCOUNT   
        ]
        return RESULTS
    ]
]

;;Uncomment to test
;;Make a function similar to the one below (without the printing) so that
;;you don't have to reproduce the code for every call to the field check.

;TESTSTRING: func [
;    TESTSTRING
;] [
;    set [
;        ISNUMERIC
;        ISALPHABETIC
;        ISALPHANUMERIC
;        ISMIXED
;        HASLETTER
;        HASUPPER
;        HASLOWER
;        HASDIGIT
;        HASOTHER
;        STARTSWITHLETTER
;        LEADINGSPACECOUNT
;        TRAILINGSPACECOUNT
;        EMBEDDEDSPACECOUNT
;        DECIMALCOUNT
;    ] FIELDCHECK/ANALYZE-STRING TESTSTRING
; 
;    print ["ISNUMERIC: " ISNUMERIC]
;    print ["ISALPHABETIC: " ISALPHABETIC]
;    print ["ISALPHANUMERIC: " ISALPHANUMERIC]
;    print ["ISMIXED: " ISMIXED]
;    print ["HASLETTER: " HASLETTER]
;    print ["HASUPPER: " HASUPPER]
;    print ["HASLOWER: " HASLOWER]
;    print ["HASDIGIT: " HASDIGIT]
;    print ["HASOTHER: " HASOTHER]
;    print ["STARTSWITHLETTER: " STARTSWITHLETTER]
;    print ["LEADINGSPACECOUNT: " LEADINGSPACECOUNT]
;    print ["TRAILINGSPACECOUNT: " TRAILINGSPACECOUNT]
;    print ["EMBEDDEDSPACECOUNT: " EMBEDDEDSPACECOUNT]
;    print ["DECIMALCOUNT: " DECIMALCOUNT]
;]
;print "Testing 12345"
;TESTSTRING "12345"
;print "-------------------------------------"
;print "Testing 12x567"
;TESTSTRING "12x567"
;print "-------------------------------------"
;print "Testing TestFileName.txt"
;TESTSTRING "TestFileName.txt"
;print "-------------------------------------"
;print "Testing 12345.980"
;TESTSTRING "12345.980"
;print "-------------------------------------"
;print "Testing Bad file name"
;TESTSTRING "Bad file name"
;print "-------------------------------------"
;print "Testing 75%"
;TESTSTRING "75%"
;print "-------------------------------------"
;print "Testing 12345789"
;TESTSTRING "12345789"
;print "-------------------------------------"
;print "   string with spaces   "
;TESTSTRING "   string with spaces   "
;print "-------------------------------------"
;halt     
    
