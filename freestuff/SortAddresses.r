REBOL [
    Title: "Sort block of addresses"
    Purpose: {Sort a block of addresses on street name
    and then house number.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a specialized module for a very specific purpose.                 ]
;; [ It takes a block of addresses expected to be in the form like this:       ]
;; [     1800 W OLD SHAKOPEE RD                                                ]
;; [ and sorts the block first on the street name and then on the house        ]
;; [ number.  For addresses that do not match this form, the results will      ]
;; [ not be as wanted.                                                         ]
;; [ To accomplish this sort, we will make a fixed-length sort key and attach  ]
;; [ it to each address.  The sort key will be 30 characters of the street     ]
;; [ name plus six characters of the house number with leading zeros.          ]
;; [---------------------------------------------------------------------------]

SPACEFILL: func [
    "Left justify a string, pad with spaces to specified length"
    INPUT-STRING 
    FINAL-LENGTH
] [
    head insert/dup tail copy/part trim INPUT-STRING FINAL-LENGTH #" " 
        max 0 FINAL-LENGTH - length? INPUT-STRING
]

ZEROFILL: func [
    "Add zeros to the front of a string up to a given length"
    INPUT-STRING
    FINAL-LENGTH
] [
    head insert/dup INPUT-STRING #"0" max 0 FINAL-LENGTH - length? INPUT-STRING
]

SPLIT-ADDRESS: func [
    ADDRESS
    /local
    FIRST-TOKEN
    ADDRESS-REMAINDER
    FIRST-SPACE-FOUND
    ADDRESS-PARTS
] [
    trim ADDRESS
    FIRST-TOKEN: copy ""
    ADDRESS-REMAINDER: copy ""
    ADDRESS-PARTS: copy []
    FIRST-SPACE-FOUND: false
    foreach ADDRESS-CHARACTER ADDRESS [
        if equal? ADDRESS-CHARACTER #" " [
            FIRST-SPACE-FOUND: true
        ]
        either FIRST-SPACE-FOUND [
            append ADDRESS-REMAINDER ADDRESS-CHARACTER
        ] [
            append FIRST-TOKEN ADDRESS-CHARACTER
        ]
    ]
    append ADDRESS-PARTS trim FIRST-TOKEN
    append ADDRESS-PARTS trim ADDRESS-REMAINDER
    return ADDRESS-PARTS
]

SORT-ADDRESSES: func [
    ADDRESSBLOCK 
    /local PARTSBLOCK ADDRBLK HOUSE STREET SORTKEY RESULT
] [
    PARTSBLOCK: copy [] 
    foreach ADDRESS ADDRESSBLOCK [
;;  -- Dissect the address into house number and street name 
        set [HOUSE STREET] SPLIT-ADDRESS ADDRESS
;;  -- Build a fixed-length sort key out of the house and street
        SORTKEY: copy ""
        append SORTKEY rejoin [SPACEFILL STREET 30 ZEROFILL HOUSE 6]
;;      print SORTKEY
;;  -- Make a block out of the sort key and the original address
        ADDRBLK: copy []
        append ADDRBLK SORTKEY 
        append ADDRBLK ADDRESS
;;      print mold ADDRBLK
;;  -- Add the block we made to the cumulative block
        append/only PARTSBLOCK ADDRBLK
    ]
;;  -- Sort the cumulative block on the sort key
    sort/compare PARTSBLOCK func [REC1 REC2] [REC1/1 < REC2/1]
;;  -- Pick out only the original addresses and add them to the result
    RESULT: copy []
    foreach ADDRBLK PARTSBLOCK [
        append RESULT ADDRBLK/2
    ]
    return RESULT 
]

;;Uncomment to test.
;SORTED-ADDRESSES: SORT-ADDRESSES [
;"203 ZENITH AVE"
;"1040 MAIN ST"
;"123 ZENITH AVE"
;"21 JUMP ST"
;"4 FOURTH ST"
;"100 FOURTH ST"  
;]
;foreach ADDR SORTED-ADDRESSES [
;    print ADDR
;]
;halt

