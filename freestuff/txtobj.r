REBOL [
    Title: "Generic text file"
    Purpose: {Provide a generic text file for situations where just
    reading through from front to end is not enough.}
]

;; [---------------------------------------------------------------------------]
;; [ This is an object for a plain text file.                                  ]
;; [ Plain text files are very easy to work with in REBOL but sometimes you    ]
;; [ want to do things in a not-quite-so-automated way.  This module           ]
;; [ brings a whole file into memory and provides functions for moving around  ]
;; [ in the file, changing lines, deleting lines, and so on; things that       ]
;; [ are a bit more involved than just reading from start to end.              ]
;; [ This module was written for internal use, so it is possible to misuse     ]
;; [ it and get bad results.  Error checking is limited, but for the sake      ]
;; [ of debugging, each function will write its name into a trace area         ]
;; [ and also set a result code.                                               ]
;; [---------------------------------------------------------------------------]

TXT: make object! [

;; [---------------------------------------------------------------------------]
;; [ When you make an instance of this object, these are the items you might   ]
;; [ want to change.                                                           ]
;; [---------------------------------------------------------------------------]

    FILE-ID: %default.txt

;; [---------------------------------------------------------------------------]
;; [ These are the items you will use as your "interface" so to speak.         ]
;; [ A note on the EOF flag:  The EOF flag is not intended to be a status      ]
;; [ code reporting on the results of a function.  However, one of the         ]
;; [ original uses of this module was to loop through a text file until the    ]
;; [ end.  So we will try to have the various reading functions return the     ]
;; [ EOF flag in situations where some operation puts us beyond the end of     ]
;; [ the file.                                                                 ]
;; [---------------------------------------------------------------------------]

    RECORD: ""
    RECORD-NUMBER: 0
    FILE-SIZE: 0       ;; refer but don't change
    EOF: false         ;; refer but don't change

;; [---------------------------------------------------------------------------]
;; [ Working items.  Of course you can change these, but if you don't know     ]
;; [ what you are doing you will break things.                                 ]
;; [---------------------------------------------------------------------------]

    FILE-DATA: [] 
    FILE-OPEN: false 
    COPY-DATA: []

;; [---------------------------------------------------------------------------]
;; [ For debugging, the functions below will set these items which you may     ]
;; [ check if you are having problems.                                         ]
;; [ For the result code, 1 will be success and other non-zero values will     ]
;; [ be for various errors.                                                    ]
;; [ The caller is welcome to use these for checking results, but the are      ]
;; [ included mainly for debugging.                                            ]
;; [ 0 = Undefined; a function was not executed.                               ]
;; [ 1 = Successful result for this function.                                  ]
;; [ 2 = No file has been opened.                                              ]
;; [ 3 = File is empty (record count is zero).                                 ]
;; [ 4 = Reading or writing past the end.                                      ]
;; [ 5 = Reading or writing below the beginning.                               ]
;; [---------------------------------------------------------------------------]

    LAST-FUNCTION-CALLED: ""
    LAST-FUNCTION-RESULT: 0

;; [---------------------------------------------------------------------------]
;; [ Functions.                                                                ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Open the file for input.                                                  ]
;; [ Read the whole file into memory.  Set the file size.                      ]
;; [ Do not load the record area; make the caller execute the "read first"     ]
;; [ function.                                                                 ]
;; [---------------------------------------------------------------------------]

    OPEN-INPUT: does [
        LAST-FUNCTION-CALLED: copy "OPEN-INPUT"
        FILE-DATA: copy []
        FILE-DATA: read/lines FILE-ID
        FILE-SIZE: length? FILE-DATA
        FILE-OPEN: true
        EOF: false
        RECORD-NUMBER: 0
        RECORD: copy ""
        COPY-DATA: copy []
        LAST-FUNCTION-RESULT: 1
    ]

;; [---------------------------------------------------------------------------]
;; [ Read the first record.                                                    ]
;; [ If the file is not open or is empty, the record area will be blank.       ]
;; [ No error will be produced if the file is closed or empty.                 ]
;; [ If the file is empty, EOF will be set because that makes sense.           ]
;; [---------------------------------------------------------------------------]

    READ-FIRST: does [
        LAST-FUNCTION-CALLED: copy "READ-FIRST"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            EOF: true
            return EOF
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            return EOF
        ]
        RECORD-NUMBER: 1
        RECORD: copy pick FILE-DATA RECORD-NUMBER
        EOF: false
        LAST-FUNCTION-RESULT: 3
        return EOF
    ]

;; [---------------------------------------------------------------------------]
;; [ Read the next record.                                                     ]
;; [ RECORD-NUMBER points to the current one, so if you have changed that,     ]
;; [ then be prepared for appropriate results.  Reading past the end will set  ]
;; [ the EOF flag.                                                             ]
;; [---------------------------------------------------------------------------]

    READ-NEXT: does [
        LAST-FUNCTION-CALLED: copy "READ-NEXT"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            EOF: true
            return EOF
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            EOF: true
            return EOF
        ]
        RECORD-NUMBER: RECORD-NUMBER + 1
        either lesser-or-equal? RECORD-NUMBER FILE-SIZE [
            RECORD: copy pick FILE-DATA RECORD-NUMBER
            EOF: false
            LAST-FUNCTION-RESULT: 1
        ] [
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 4
        ]
        return EOF
    ]

;; [---------------------------------------------------------------------------]
;; [ Read the previous record.                                                 ]
;; [ RECORD-NUMBER points to the current one, so if you have changed that,     ]
;; [ then be prepared for appropriate results.  Reading any record will        ]
;; [ reset the EOF flag since you are not at the "end" if you have read        ]
;; [ some record successfully.                                                 ]
;; [---------------------------------------------------------------------------]

    READ-PREV: does [
        LAST-FUNCTION-CALLED: copy "READ-PREV"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            EOF: true
            return EOF
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            return EOF
        ]
        if equal? 0 RECORD-NUMBER [
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 5
            EOF: false
            return EOF
        ]
        RECORD-NUMBER: RECORD-NUMBER - 1
        if equal? 0 RECORD-NUMBER [
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 5
            EOF: false
            return EOF
        ]
        either lesser-or-equal? RECORD-NUMBER FILE-SIZE [
            RECORD: copy pick FILE-DATA RECORD-NUMBER
            EOF: false
            LAST-FUNCTION-RESULT: 1
        ] [
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 4
        ]
        return EOF
    ]

;; [---------------------------------------------------------------------------]
;; [ Read the last record.                                                     ]
;; [---------------------------------------------------------------------------]

    READ-LAST: does [
        LAST-FUNCTION-CALLED: copy "READ-LAST"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            EOF: true
            return EOF
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            return EOF
        ]
        RECORD-NUMBER: FILE-SIZE
        RECORD: copy pick FILE-DATA RECORD-NUMBER
        EOF: false
        LAST-FUNCTION-RESULT: 1
        return EOF
    ]
    
;; [---------------------------------------------------------------------------]
;; [ Read the record pointed to by the record number.                          ]
;; [ The caller should change RECORD-NUMBER and then execute this function.    ]
;; [ If you change the record number past the end, EOF will be set.            ]
;; [ If you set the record number to zero, no error will be returned.          ]
;; [---------------------------------------------------------------------------]

    READ-SPECIFIC: does [
        LAST-FUNCTION-CALLED: copy "READ-SPECIFIC"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            EOF: true
            return EOF
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            return EOF
        ]
        if equal? 0 RECORD-NUMBER [
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 5
            EOF: false
            return EOF
        ]
        if greater? RECORD-NUMBER FILE-SIZE [
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 4
            return EOF
        ]
        RECORD: copy pick FILE-DATA RECORD-NUMBER
        EOF: false
        LAST-FUNCTION-RESULT: 1
        return EOF
    ]

;; [---------------------------------------------------------------------------]
;; [ Copy the record area to the COPY-DATA block.  This operation is           ]
;; [ available in case you want to "filter" the input file and copy selected   ]
;; [ records to a new file.                                                    ]
;; [---------------------------------------------------------------------------]

    COPY-RECORD: does [
        LAST-FUNCTION-CALLED: copy "COPY-RECORD"
        append COPY-DATA RECORD
        LAST-FUNCTION-RESULT: 1
    ]

;; [---------------------------------------------------------------------------]
;; [ Save the COPY-DATA block.  This function writes any records you might     ]
;; [ have copied, into a file the name of which is passed to the function.     ]
;; [---------------------------------------------------------------------------]

    SAVE-COPY: func [
        COPY-FILE-ID 
    ] [
        LAST-FUNCTION-CALLED: copy "SAVE-COPY"
        write/lines COPY-FILE-ID COPY-DATA
        LAST-FUNCTION-RESULT: 1
    ]
    
;; [---------------------------------------------------------------------------]
;; [ Rewrite the record pointed to by the record number.                       ]
;; [ The caller should change RECORD-NUMBER and then execute this function.    ]
;; [ If you change the record number past the end, EOF will be set.            ]
;; [ If you set the record number to zero, no error will be returned.          ]
;; [---------------------------------------------------------------------------]

    REWRITE-SPECIFIC: does [
        LAST-FUNCTION-CALLED: copy "REWRITE-SPECIFIC"
        if not FILE-OPEN [
            RECORD-NUMBER: 0
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 2
            exit
        ]
        if equal? 0 FILE-SIZE [
            RECORD-NUMBER: 0
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 3
            exit
        ]
        if equal? 0 RECORD-NUMBER [
            RECORD: copy ""
            LAST-FUNCTION-RESULT: 5
            exit
        ]
        if greater? RECORD-NUMBER FILE-SIZE [
            RECORD: copy ""
            EOF: true
            LAST-FUNCTION-RESULT: 4
            exit
        ]
        FILE-DATA: head FILE-DATA
        change at FILE-DATA RECORD-NUMBER RECORD
        EOF: false
        LAST-FUNCTION-RESULT: 1
    ]
]

;; -----------------------------------------------------------------------------

;; uncomment to test
;write %default.txt {Line 1
;Line 2
;Line 3
;Line 4
;Line 5}
;TXT/OPEN-INPUT
;probe TXT/FILE-DATA
;TXT/READ-FIRST
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-NEXT
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-NEXT
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-NEXT
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-NEXT
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-NEXT
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/READ-PREV
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/RECORD-NUMBER: 3
;TXT/READ-SPECIFIC
;print ["EOF: " TXT/EOF " RECORD: " TXT/RECORD]
;TXT/RECORD: "New line 3"
;TXT/REWRITE-SPECIFIC
;probe TXT/FILE-DATA
;halt

