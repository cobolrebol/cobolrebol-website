REBOL [
    Title: "Duplicate item counter"
    Purpose: {Given a block of items, usually some sort of identifier
    value, of string type, produce a result block that is a lookup 
    table of each unique item followed by a count of the number of
    times it appeared in the original block.}
]

;; [---------------------------------------------------------------------------]
;; [ Given a block of key values, produce a resulting block of each unique     ]
;; [ key value followed by the number of times it occurred in the input        ]
;; [ block.  For example:                                                      ]
;; [ Input block:                                                              ]
;; [     ["111" "112" "113" "113" "114" "114" "114" "115" "111"]               ]
;; [ Output block:                                                             ]
;; [     ["111" 2 "112" 1 "113" 2 "114" 3 "115" 1]                             ]
;; [ Yes, believe it or not, I actually had a use for that.                    ]
;; [---------------------------------------------------------------------------]

DUPCOUNTS-TABLE: func [
    KEYBLOCK
    /local COUNTERTABLE COUNTER KEYHOLDER
] [
    COUNTERTABLE: copy []
    COUNTER: 0 
    if empty? KEYBLOCK [
        return COUNTERTABLE
    ]
    sort KEYBLOCK
    KEYHOLDER: copy first KEYBLOCK
    foreach ITEM KEYBLOCK [
        either equal? ITEM KEYHOLDER [
            COUNTER: COUNTER + 1
        ] [
            append COUNTERTABLE KEYHOLDER
            append COUNTERTABLE COUNTER
            COUNTER: 1
            KEYHOLDER: copy ITEM
        ] 
    ]
    append COUNTERTABLE KEYHOLDER
    append COUNTERTABLE COUNTER 
    return COUNTERTABLE
]
;;Uncomment to test
;probe DUPCOUNTS-TABLE ["111" "112" "113" "113" "114" "114" "114" "115" "111"]
;halt 

