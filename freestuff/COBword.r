REBOL [
    Title: "Test a string to see if it is a COBOL word"
    Purpose: {Part of a (possible) larger project.  This is a 
    function to test a string and see if qualifies as a word
    in the COBOL language.}
]

;; [---------------------------------------------------------------------------]
;; [ This function, part of a larger project, tests a string to see if it      ]
;; [ meets the requirements of a COBOL data name.  It must start with a        ]
;; [ letter, contain only letters, numbers, and hyphens, and be no more        ]
;; [ than 30 characters long.                                                  ]
;; [---------------------------------------------------------------------------]

COBWORD: context [
    LETTERS: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    NUMBERS: "0123456789"
    SPECIALS: "-"
    STRINGSIZE: 0
    VALIDCOUNT: 0
    STRINGSUB: 0
    TESTBYTE: ""
    
    DATANAME?: func [
        TESTWORD [string!]
    ] [
        STRINGSIZE: length? TESTWORD  
        VALIDCOUNT: 0
        STRINGSUB: 1
        if (STRINGSIZE > 30) [
            return false
        ]
        if (STRINGSIZE = 0) [
            return false
        ]
        TESTBYTE: copy ""
        TESTBYTE: to-string pick TESTWORD 1
        if not find LETTERS TESTBYTE [
            return false
        ]
        loop STRINGSIZE [
            TESTBYTE: copy ""
            TESTBYTE: to-string pick TESTWORD STRINGSUB
            if find rejoin [LETTERS NUMBERS SPECIALS] TESTBYTE [
                VALIDCOUNT: VALIDCOUNT + 1
            ]
            STRINGSUB: STRINGSUB + 1
        ]
        either (VALIDCOUNT = STRINGSIZE) [
            return true
        ] [
            return false
        ]
    ]
]

;; Uncomment to test
;CHECKWORD: "01"
;either COBWORD/DATANAME? CHECKWORD [
;    print [CHECKWORD "is a COBOL data name"]
;] [
;    print [CHECKWORD "is NOT a data name"]
;]
;CHECKWORD: "INPUT-RECORD"
;either COBWORD/DATANAME? CHECKWORD [
;    print [CHECKWORD "is a COBOL data name"]
;] [
;    print [CHECKWORD "is NOT a data name"]
;]
;CHECKWORD: "X(5)"
;either COBWORD/DATANAME? CHECKWORD [
;    print [CHECKWORD "is a COBOL data name"]
;] [
;    print [CHECKWORD "is NOT a data name"]
;]
;halt

