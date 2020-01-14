REBOL [
    Title: "Fixed Format Text file functions"
    Purpose: {Useful functions for working with a text file
    of fixed-format records.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a bunch of functions for working with a file of fixed-format      ]
;; [ text lines.  It was created originally as the base for a program to       ]
;; [ provide minimal, carefully controlled, editing of such a file by those    ]
;; [ not familiary with text editors.                                          ]
;; [ There will be procedures to open a file, read the next or previous        ]
;; [ record, delete a record, add a new record at the end, and save the        ]
;; [ file under its same name or a new name.                                   ]
;; [ This module is not an independent program.  It will be called by a        ]
;; [ controlling program.                                                      ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Items we will use in processing the file.                                 ]
;; [---------------------------------------------------------------------------]

FFTF-FILE-ID: none      ;; File name we will be working on
FFTF-FILE-ID-SAVE: none ;; File name for save-as operation
FFTF-FIELDS: none       ;; Field names and locations in a record
FFTF-DATA: []           ;; Whole file in memory as a block of lines
FFTF-RECORD: ""         ;; One line of the file, the one we are working with
FFTF-RECNO: 0           ;; Index of the record we are positioned at
FFTF-FILE-SIZE: 0       ;; Number of lines in DATA
FFTF-EOF: false         ;; Set to true if we try to read past end
FFTF-FOUND: false       ;; Returned when searching

;; [---------------------------------------------------------------------------]
;; [ Open an existing file.                                                    ]
;; [ This function requires two items.  The first is the name of the file.     ]
;; [ The second is a block.  The block will contain repetitions of a word      ]
;; [ and a pair.  The word will the the name of a field in the fixed-format    ]
;; [ record.  The pair will the the one-relative starting position of the      ]
;; [ field (x) and the length of the field (y).                                ]
;; [ The "open" function will bring the whole file into memory and set up      ]
;; [ various pointers and such for working with the lines in the file.         ]
;; [---------------------------------------------------------------------------]

FFTF-OPEN-INPUT: func [
    FILEID [file!]
    FIELDLIST [block!]
] [
;;  -- Save what was passed to us.
    FFTF-FILE-ID: FILEID
    FFTF-FIELDS: FIELDLIST
;;  -- Read the entire file into memory.  Set various working items.
    FFTF-DATA: copy []
    FFTF-DATA: read/lines FFTF-FILE-ID
    FFTF-FILE-SIZE: length? FFTF-DATA
    FFTF-RECNO: 0
    FFTF-EOF: false
]

;; [---------------------------------------------------------------------------]
;; [ Read a record indicated by FFTF-RECNO.                                    ]
;; [ "Read" means to copy the specified line into the record area and then     ]
;; [ use the field list to set the words in the field list to the data         ]
;; [ indicated by the position-length pair.                                    ]
;; [---------------------------------------------------------------------------]

FFTF-READ-SPECIFIC: does [
    FFTF-EOF: false
    FFTF-RECORD: pick FFTF-DATA FFTF-RECNO
    foreach [FIELDNAME POSITION] FFTF-FIELDS [
        FFTF-RECORD: head FFTF-RECORD
        FFTF-RECORD: skip FFTF-RECORD (POSITION/x - 1)
        set FIELDNAME copy/part FFTF-RECORD POSITION/y
    ]
]

;; [---------------------------------------------------------------------------]
;; [ To read the first/next/previous/last record, we will just adjust the      ]
;; [ RECNO and use the above READ-SPECIFIC function.                           ]
;; [ Notice that we don't let RECNO get out of bounds, just in case we         ]
;; [ misuse these procedures and try to read out of bounds.                    ]
;; [---------------------------------------------------------------------------]

FFTF-READ-FIRST: does [
    FFTF-RECNO: 1
    either (FFTF-RECNO > FFTF-FILE-SIZE) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-NEXT: does [
    FFTF-RECNO: FFTF-RECNO + 1
    either (FFTF-RECNO > FFTF-FILE-SIZE) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-PREV: does [
    FFTF-RECNO: FFTF-RECNO - 1
    either (FFTF-RECNO < 1) [
        FFTF-RECNO: 1
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-LAST: does [
    FFTF-RECNO: FFTF-FILE-SIZE
    either (FFTF-RECNO < 1) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Operations for saving the data or making a new file.                      ]
;; [---------------------------------------------------------------------------]

FFTF-SAVE-FILE: does [
    write/lines FFTF-FILE-ID FFTF-DATA
]

FFTF-SAVE-FILE-AS: does [
    FFTF-FILE-ID-SAVE: request-file/only/save
    either FFTF-FILE-ID-SAVE [
        write/lines FFTF-FILE-ID-SAVE FFTF-DATA
    ] [
        alert "No save-as ID requested"
    ]
]

;; [---------------------------------------------------------------------------]
;; [ We are going to have to be able to delete records, and also to update     ]
;; [ them if the values of the fields are changed by some calling program.     ]
;; [---------------------------------------------------------------------------]

;;  -- Build a record using current values of the field names.
FFTF-BUILD-RECORD: does [
    FFTF-RECORD: copy ""
    loop 1024 [append FFTF-RECORD " "]
    foreach [FIELDNAME POSITION] FFTF-FIELDS [
        FFTF-RECORD: head FFTF-RECORD
        FFTF-RECORD: skip FFTF-RECORD (POSITION/x - 1)
        change/part FFTF-RECORD (get FIELDNAME) POSITION/y
    ]    
    FFTF-RECORD: head FFTF-RECORD
    FFTF-RECORD: trim/tail FFTF-RECORD
]

;;  -- Delete the line pointed to by RECNO.
FFTF-DELETE-RECORD: does [
    remove at FFTF-DATA FFTF-RECNO
    FFTF-FILE-SIZE: FFTF-FILE-SIZE - 1
]

;;  -- Add a new record at the end of the file.
FFTF-ADD-RECORD: does [
    FFTF-BUILD-RECORD
    append FFTF-DATA FFTF-RECORD
    FFTF-FILE-SIZE: FFTF-FILE-SIZE + 1 
] 

;;  -- Change the record pointed to by RECNO using the field name values.
FFTF-CHANGE-RECORD: does [
    FFTF-BUILD-RECORD
    poke FFTF-DATA FFTF-RECNO FFTF-RECORD
]

;;  -- Search for the record where the value of a given word is equal
;;  -- to a given value.  Return true or false.
FFTF-SEARCH: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-FIRST
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-NEXT
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;;  -- Search ahead from where we are.
FFTF-SEARCH-NEXT: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-NEXT
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-NEXT
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;;  -- Search backwards from where we are.
FFTF-SEARCH-PREV: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-PREV
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-PREV
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;; Uncomment to test
;FID: %fftf-testdata.txt
;;               123456789*123456789*123456789*123456789*1234
;write/lines FID {11111111 22222222222222222222 3 4 5555555555
;FIELD-1  TWENTY CHARACTERS... X Y 1234567890
;AAAAAAAA BBBBBBBBBBBBBBBBBBBB P Q 0987654321
;CCCCCCCC DDDDDDDDDDDDDDDDDDDD J K **********}
;FFTF-OPEN-INPUT FID [F1 1X8 F2 10X20 F3 31X1 F4 33X1 F5 35X10]
;foreach line FFTF-DATA [
;    print line
;]
;FFTF-READ-NEXT
;print rejoin ["F1 = '" F1 "'"]
;print rejoin ["F2 = '" F2 "'"]
;print rejoin ["F3 = '" F3 "'"]
;print rejoin ["F4 = '" F4 "'"]
;print rejoin ["F5 = '" F5 "'"]
;FFTF-READ-NEXT
;print rejoin ["F1 = '" F1 "'"]
;print rejoin ["F2 = '" F2 "'"]
;print rejoin ["F3 = '" F3 "'"]
;print rejoin ["F4 = '" F4 "'"]
;print rejoin ["F5 = '" F5 "'"]
;either FFTF-SEARCH 'F3 "P" [
;    print "P found"
;] [
;    print "No P found"
;]
;either FFTF-SEARCH 'F1 "FIELD-2" [
;    print "FIELD-2 found"
;] [
;    print "No FIELD-2 found"
;]
;FFTF-READ-FIRST
;F2: copy "New value"
;FFTF-CHANGE-RECORD
;foreach line FFTF-DATA [
;    print line
;]
;halt

