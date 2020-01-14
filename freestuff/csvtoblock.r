REBOL [
    Title: "CSV to block"
    Purpose: {Parse a CSV file into a block of headings and a block of data.}
]

;; [---------------------------------------------------------------------------]
;; [ This module is part of a larger project.  It provides an object so that   ]
;; [ it is possible to bring into one program more than one CSV file and       ]
;; [ parse each one into a block of headings plus a block of sub-blocks that   ]
;; [ represent the data lines in the CSV file.  This is based on a somewhat    ]
;; [ standard assumption that the CSV file has a first line of column          ]
;; [ headings.                                                                 ]
;; [ After you load the file, what you do with it is up to you.                ]
;; [ You will notice that after the program takes apart a line of data,        ]
;; [ it replaces commas in all the columns with spaces.  This was a response   ]
;; [ to the program's original use of creating a new CSV file out of data      ]
;; [ parsed out the old one.  Of course there were better solutions, like      ]
;; [ using a delimiter other than a comma, but stubborness prevailed.          ]
;; [---------------------------------------------------------------------------]

CSVBLK: make object! [

    FILE-ID: none       ;; Name the file, will be passed at run time
    FILE-LINES: none    ;; The entire file, as lines
    HEADINGS: none      ;; The column headings in a block
    DATABLOCK: none     ;; The block of blocks that is all the data
    WORDCOUNT: 0        ;; number of "columns" in the file
    RECORD: none        ;; One line of the input data 
    VALUES: none        ;; The parsed values from a single data line
    RECBLK: none        ;; Values from one record, in a block, commas restored
    EOF: false          ;; End-of-file flag when we "read" beyond last "record"
    LENGTH: 0           ;; Number of lines in the file, including heading line
    COUNTER: 0          ;; Record counter as we move through the file
    VAL-COUNTER: 0      ;; For stepping through values in one record
    COMMACOUNT: 0       ;; Used to NOT put comma after last field of record 
    IN-FIELD: false     ;; Used in comma-replacement operation
    COMMA-MARKER: "%C%" ;; Will replace comma temporarily before parsing

    CLEAR-WS: does [
        FILE-ID: none     
        FILE-LINES: none    
        HEADINGS: none 
        DATABLOCK: copy []
        WORDCOUNT: 0 
        RECORD: none
        VALUES: none  
        RECBLK: none
        EOF: false     
        LENGTH: 0      
        COUNTER: 0     
        VAL-COUNTER: 0 
        COMMACOUNT: 0 
        IN-FIELD: false
    ]

    CSVOPEN: func [
        FILE-TO-OPEN      
    ] [
        CLEAR-WS
        FILE-ID: FILE-TO-OPEN
        FILE-LINES: read/lines FILE-ID
        LENGTH: length? FILE-LINES
        HEADINGS: parse/all first FILE-LINES ","
        WORDCOUNT: length? HEADINGS
        COUNTER: 1 
        EOF: false
        return EOF 
    ]

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

    CSVREAD: does [
        COUNTER: COUNTER + 1
        if (COUNTER > LENGTH) [
            EOF: true
            return EOF 
        ]
        RECORD: pick FILE-LINES COUNTER
        VALUES: PARSE-ON-COMMA RECORD
        VAL-COUNTER: 0
        RECBLK: copy [] 
        foreach WORD HEADINGS [
            VAL-COUNTER: VAL-COUNTER + 1 ;; point to next value
            TEMP-VAL: pick VALUES VAL-COUNTER ;; get next value
            if not TEMP-VAL [   ;; don't want to crash if no value found
                TEMP-VAL: copy ""
            ]
            replace/all TEMP-VAL "," ""
            append RECBLK TEMP-VAL
        ]
        return EOF 
    ]

    CSV-TO-BLOCK: func [
        CSV-FILE-ID
    ] [
        CSVOPEN CSV-FILE-ID
        CSVREAD
        until [  ;; EOF = true
            append/only DATABLOCK RECBLK
            CSVREAD
        ]
    ]
]

;;Uncomment to test
;write %csvtest.csv {COL1,COL2,COL3
;A,B,C 
;D,E,F
;G,H,E
;J,K,L}
;CSVBLK/CSV-TO-BLOCK %csvtest.csv
;probe CSVBLK/HEADINGS
;print "--------------------"
;probe CSVBLK/DATABLOCK
;halt

