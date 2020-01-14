REBOL [
    Title: "Multi-block lookup table"
    Purpose: {Provide an object that is a lookup table that has a single
    key value and a block of attributes, but each attribute is itself 
    another block.  Originally written to make a table of properties
    with multiple detached garages.}
]

;; [---------------------------------------------------------------------------]
;; [ This module provides an object for a particular type of lookup table.     ]
;; [ The table has one key value, and a block of attributes.  The block of     ]
;; [ attributes is a block of blocks.  Something like this:                    ]
;; [                                                                           ]
;; [ key1 [ [attr-1-1-1 attr-1-1-2 ...] [attr-1-2-1 attr-1-2-2 ...] ... ]      ]
;; [ key2 [ [attr-2-1-1 attr-2-1-2 ...] [attr-2-2-1 attr-2-2-2 ...] ... ]      ]
;; [ key3 [ [attr-3-1-1 attr-3-1-2 ...] [attr-3-2-1 attr-3-2-2 ...] ... ]      ]
;; [ ...                                                                       ]
;; [                                                                           ]
;; [ Functions are provided for adding new keys, adding new attribute          ]
;; [ sub-blocks to existing attribute blocks.                                  ]
;; [                                                                           ]
;; [ Adding items.                                                             ]
;; [ When we add an item, we would like to have a key, and one of the          ]
;; [ sub-blocks, and get those into the table.  In this situation, the key     ]
;; [ might not be in the table at all, or it might be in there from a          ]
;; [ previous addition.  If it is not there at all, we would want to add       ]
;; [ it with an attribute containing the given sub-block.  If it is there      ]
;; [ from a previous insertion, we would want to find the attribute block      ]
;; [ for the key and add the sub-block to the existing attribute block.        ]
;; [                                                                           ]
;; [ Searching for items.                                                      ]
;; [ Because of the power of REBOL, it is not necessary to write a             ]
;; [ search function.  The caller can use the existing "select"                ]
;; [ function to return the attribute block for a given key.                   ]
;; [                                                                           ]
;; [ Saving and loading.                                                       ]
;; [ The expected use of this module is to create a lookup table and then      ]
;; [ save it to disk for use by some other program.  That other program        ]
;; [ would use this module to load the file for lookups.                       ]
;; [---------------------------------------------------------------------------]

MBLT: make object! [

    FILE-ID: %MBLT.txt
    TBL: []      ;; The whole table
    REC: []      ;; Attribute block for one key

;;  Add an item.
;;  Call the function with a key value and a sub-block
;;  to be added to the attribute block for the key.  
    ADD-ITEM: func [
        KEY
        BLK
        /local INSERTPOINT
    ] [
        TBL: head TBL
        either INSERTPOINT: find TBL KEY [
            INSERTPOINT: next INSERTPOINT
            REC: first INSERTPOINT
            append/only REC BLK
            change/only INSERTPOINT REC
        ] [
            append TBL KEY
            REC: copy []
            append/only REC BLK
            append/only TBL REC
        ]
        TBL: head TBL 
    ]        

;;  Save the table to a file for later loading.
    SAVE-TBL: does [
        save FILE-ID TBL
    ]

;;  Load a saved table.
    LOAD-TBL: does [
        TBL: copy []
        TBL: load FILE-ID
    ]
]

;;Uncomment to test
;MBLT/ADD-ITEM 1 ["1-1-1" "1-1-2"]
;MBLT/ADD-ITEM 2 ["2-1-1" "2-1-2"]
;MBLT/ADD-ITEM 3 ["3-1-1" "3-1-2"]
;MBLT/ADD-ITEM 4 ["4-1-1" "4-1-2"]
;MBLT/ADD-ITEM 2 ["2-2-1" "2-2-2"]
;MBLT/ADD-ITEM 4 ["4-2-1" "4-2-2"]
;MBLT/ADD-ITEM 5 ["5-1-1" "5-1-2"]
;MBLT/ADD-ITEM 2 ["2-3-1" "2-3-2"]
;print "TBL after a few additions:"
;foreach [KEYVAL ATTRBLK] MBLT/TBL [
;    print [KEYVAL ":" mold ATTRBLK]
;]
;print "--------------------------"
;print "Find a few:"
;print ["5:" mold select MBLT/TBL 5]
;print ["2:" mold select MBLT/TBL 2]
;print ["6:" mold select MBLT/TBL 6]
;halt

