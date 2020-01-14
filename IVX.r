REBOL [
    Title: "Inverted index object"
    Purpose: {Provide an object for a simple inverted index.
    The index is a block consisting of pairs of a value, plus
    a block of identifiers where that value can be found.}
]

;; [---------------------------------------------------------------------------]
;; [ This module was written originally for a specific purpose.                ]
;; [ The original problem was a file of records, each record having a          ]
;; [ a unique key and some data fields.  We wanted a way to find all the       ]
;; [ records that had some particular value in some particular field.          ]
;; [ The solution was to create an inverted index that looked like this:       ]
;; [     (data-value) [ (record-key-1) (record-key-2) ... (record-key-n) ]     ]
;; [ This module provides what application-independent functions we can make   ]
;; [ to make it a little easier to work with such a structure.                 ]
;; [---------------------------------------------------------------------------]

IVX: make object! [

    FILE-ID: %inv-index.txt ;; In case we want to save the index
    WHOLE-INDEX: []         ;; The whole index, created or read in from disk
    KEY-BLOCK: []           ;; One block of keys 

;; We might want to work with an index saved from a prior time.
    LOAD-FROM-DISK: does [
        WHOLE-INDEX: copy []
        WHOLE-INDEX: load FILE-ID
    ]

;; Save so we can reload later.
    SAVE-TO-DISK: does [
        save FILE-ID WHOLE-INDEX
    ]

;; Add to the index a data value and some key value showing where it is
;; located.  
    ADD-ITEM: func [
        DATAVAL       ;; data field value
        KEYVAL        ;; key where data is located
    ] [
;; Is the data value in the index already?
        either KEY-BLOCK: select WHOLE-INDEX DATAVAL [
;; Yes.  Add the key to the block that already exists and put the block back.
            append KEY-BLOCK KEYVAL
            POSN: next find WHOLE-INDEX DATAVAL
            change/only POSN KEY-BLOCK
        ] [
;; No.  Add to data value and make a new block of keys.
            append WHOLE-INDEX DATAVAL
            KEY-BLOCK: copy []
            append KEY-BLOCK KEYVAL
            append/only WHOLE-INDEX KEY-BLOCK
        ]
    ]

;; Look up a data value and return the associated block of keys.
    FIND-ITEM: func [
        DATAVAL
    ] [
        return KEY-BLOCK: select WHOLE-INDEX DATAVAL 
    ]
]

;; Uncomment to test
;IVX/ADD-ITEM "data-value-1" "key-value-1"
;IVX/ADD-ITEM "data-value-1" "key-value-2"
;IVX/ADD-ITEM "data-value-1" "key-value-3"
;IVX/ADD-ITEM "data-value-1" "key-value-4"
;IVX/ADD-ITEM "data-value-2" "key-value-5"
;IVX/ADD-ITEM "data-value-2" "key-value-6"
;IVX/ADD-ITEM "data-value-2" "key-value-7"
;IVX/ADD-ITEM "data-value-2" "key-value-8"
;print IVX/FIND-ITEM "data-value-1"
;print IVX/FIND-ITEM "data-value-2"
;print IVX/FIND-ITEM "data-value-3"
;IVX/SAVE-TO-DISK
;INVERTED-INDEX: make IVX [FILE-ID: %inv-index.txt]
;INVERTED-INDEX/LOAD-FROM-DISK
;print INVERTED-INDEX/FIND-ITEM "data-value-2"
;halt 

