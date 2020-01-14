REBOL [
    Title: "Fixed-Format File object"
]

;; [---------------------------------------------------------------------------]
;; [ This is an "object" for a fixed-format file, that is, a file that is      ]
;; [ "line sequential" and has text data fields in fixed locations.            ]
;; [ You can create instances of this object and assign names to sub-strings   ]
;; [ of the data in each record, and then refer by name to the "fields"        ]
;; [ thus created.                                                             ]
;; [ To create an instance of the FFF object:                                  ]
;; [     object-name: make FFF []                                              ]
;; [ To process records until end of file, so an initial read and then use     ]
;; [ the "until" loop with the last function call in the "until" loop being    ]
;; [ "object-name/READ-RECORD, like this:                                      ]
;; [     object-name/READ-RECORD                                               ]
;; [     until [                                                               ]
;; [         ...code of your own...                                            ]
;; [         object-name/READ-RECORD  ;; last function call in loop            ]
;; [     ]                                                                     ]
;; [---------------------------------------------------------------------------]

FFF: make object! [

    FILE-ID: none       ;; file name passed to "open" function
    FIELDS: none        ;; [fieldname locationpair fieldname locationpair, etc]
    FILE-DATA: []       ;; whole file in memory, as block of lines
    OUTPUT-DATA: []     ;; new file if we write 
    RECORD-AREA: ""     ;; one line from FILE-DATA, for picking apart
    RECORD: none        ;; an object we will create to make new words available
    RECORD-NUMBER: 0    ;; for keeping track of which line we picked
    FILE-SIZE: 0        ;; number of lines in FILE-DATA
    EOF: false          ;; set when we "pick" past end 

;; [---------------------------------------------------------------------------]
;; [ Open an existing file. What does that mean?                               ]
;; [ We are supplied with a file ID and a block of field names.                ]
;; [ Each field name is followed by a pair, which indicates the position       ]
;; [ and length of the substring that represents, in each record, the value    ]
;; [ of the field.  These items (words plus positions) must be saved so        ]
;; [ that we can use them each time we read a record, in order to take         ]
;; [ apart the record into its fields.                                         ]
;; [---------------------------------------------------------------------------]

    OPEN-INPUT: func [
        FILEID [file!]     ;; will be a file name
        FIELDLIST [block!] ;; will be sets of word! and pair!
    ] [
    ;;  -- Save what was passed to us.
        FILE-ID: FILEID
        FIELDS: copy []
        FIELDS: copy FIELDLIST
    ;;  -- Read the entire file into memory and set various items in preparation
    ;;  -- for reading the file a record at a time.
        FILE-DATA: copy []
        FILE-DATA: read/lines FILE-ID
        FILE-SIZE: length? FILE-DATA
        RECORD-NUMBER: 0
        EOF: false
    ]

;; [---------------------------------------------------------------------------]
;; [ Read the next record.  What does this mean?                               ]
;; [ Using the record number counter, pick the next line in the block          ]
;; [ of file data.  Then, using the list of field names, set the word that     ]
;; [ is the field name to the value that is the substring indicated by the     ]
;; [ pair for that word.                                                       ]
;; [ After a record is "read" in this way, the calling program may refer       ]
;; [ to each field by FFF/RECORD/<word> where <word> is one of the words       ]
;; [ that was passed to OPEN-INPUT.                                            ]
;; [---------------------------------------------------------------------------]

    READ-RECORD: does [
    ;; pick a line if there are lines left to be picked 
        RECORD-NUMBER: RECORD-NUMBER + 1
        if (RECORD-NUMBER > FILE-SIZE) [
            EOF: true
            return EOF
        ]
        RECORD-AREA: copy ""
        RECORD-AREA: copy pick FILE-DATA RECORD-NUMBER
    ;; Set the words passed to the "open" function to values extracted
    ;; out of the data, based on the locations passed to the "open" function.   
    ;; Put those words and values in the RECORD object.
        RECORD: make object! []
        foreach [FIELDNAME POSITION] FIELDS [
            RECORD-AREA: head RECORD-AREA
            RECORD-AREA: skip RECORD-AREA (POSITION/x - 1)
            RECORD: make RECORD compose [
                (to-set-word FIELDNAME) copy/part RECORD-AREA POSITION/y] 
        ]
    return EOF 
    ]

;; [---------------------------------------------------------------------------]
;; [ Open a file for output.  What does that mean?                             ]
;; [ A common way of working with files in REBOL is to have the whole file     ]
;; [ in memory, so we will do that.                                            ]
;; [ We will clear out our data areas, and then when we "write" to the file    ]
;; [ we will add a formatted line to the data area, and then write the         ]
;; [ whole data area to disk when we "close" the file.                         ]
;; [ To make the supplied field names available for values, we will create     ]
;; [ a RECORD object out of the supplied names.                                ]
;; [ The caller will set values in FFF/RECORD/data-name.                       ]
;; [---------------------------------------------------------------------------]

    OPEN-OUTPUT: func [
        FILEID [file!]
        FIELDLIST [block!]
    ] [
        FILE-ID: FILEID
        FIELDS: copy FIELDLIST
        OUTPUT-DATA: copy []
        FILE-SIZE: 0
        RECORD-NUMBER: 0
        EOF: false
        RECORD: make object! []
        foreach [FIELDNAME POSITION] FIELDS [
            RECORD: make RECORD compose [
                (to-set-word FIELDNAME) {""}]   
        ]
    ]

;; [---------------------------------------------------------------------------]
;; [ When writing a file, we have to have a "close" procedure to actually      ]
;; [ put the data into a disk file.                                            ]
;; [---------------------------------------------------------------------------]

    CLOSE-OUTPUT: does [
        write/lines FILE-ID OUTPUT-DATA
    ]

;; [---------------------------------------------------------------------------]
;; [ Write a record.  What does this mean?                                     ]
;; [ The caller will have set values to the words passed to the "open"         ]
;; [ function, using the RECORD oject created at open time.                    ] 
;; [ That is, set a value to FFF/RECORD/data-name.                             ]
;; [ What we do with them is to put the values of those words                  ]
;; [ into the specified positions in the record area, and then append the      ]
;; [ record area to the data area.                                             ]
;; [ To build the record area, we can't append because we might not be         ]
;; [ adding data from front to back; we can't insert because that might        ]
;; [ move previously-inserted data.  So we will have to make a big blank       ]
;; [ string, "change" data, and then trim off the right end.                   ]
;; [ Remember that our data file is "line sequential" which means that the     ]
;; [ lines end with an LF and can vary in length.                              ]
;; [---------------------------------------------------------------------------]

    WRITE-RECORD: does [
;;;     RECORD-AREA: make string! 1028  ;; Does not work; does not space fill.
        RECORD-AREA: copy ""
        loop 1028 [append RECORD-AREA " "]
        foreach [FIELDNAME POSITION] FIELDS [
            RECORD-AREA: head RECORD-AREA 
            RECORD-AREA: skip RECORD-AREA (POSITION/x - 1)
            change/part RECORD-AREA RECORD/:FIELDNAME POSITION/y
        ]
        RECORD-AREA: head RECORD-AREA 
        RECORD-AREA: trim/tail RECORD-AREA
        append OUTPUT-DATA RECORD-AREA
    ]

]

