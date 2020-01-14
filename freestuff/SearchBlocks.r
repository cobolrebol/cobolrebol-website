REBOL [
    Title: "Search blocks"
    Purpose: {Search a block of blocks for a given string in a given position.}
]

;; [---------------------------------------------------------------------------]
;; [ This function is a little piece of a larger problem.                      ]
;; [ The goal is to find, in a block of sub-blocks, the first sub-block        ]
;; [ that has a given value in a given position.                               ]
;; [ So say you have this block of blocks:                                     ]
;; [ [ [a b c d] [e f g h] [i j k l] [m n o p]                                 ]
;; [ This function would find the sub-block, for example, that has "f" in      ]
;; [ the second position.  So to use the function, you would have to provide   ]
;; [ that "f" as a search key, the number 2 to indicate that you want to       ]
;; [ look in position 2 of each sub-block, and the block of blocks itself.     ]
;; [ The function would return the first block located, in the case,           ]
;; [ [e f g h].  If a sub-block was not found, the function would return       ]
;; [ none so you could use that as a success indicator.                        ]
;; [---------------------------------------------------------------------------]

SEARCH-BLOCKS: func [
    KEYVAL
    POS
    DATABLOCK
] [
    foreach SUBBLOCK DATABLOCK [
        if equal? KEYVAL pick SUBBLOCK POS [
            return SUBBLOCK
        ]
    ]
    return none
]

;;Uncomment to test
;TESTBLK: [
;    ["A" "B" "C" "D"]
;    ["E" "F" "G" "H"]
;    ["I" "J" "K" "L"]
;    ["M" "N" "O" "P"]
;]
;print "--------------------------"
;probe SEARCH-BLOCKS "X" 3 TESTBLK
;print "--------------------------"
;probe SEARCH-BLOCKS "F" 2 TESTBLK
;print "--------------------------"
;probe SEARCH-BLOCKS "P" 4 TESTBLK
;print "--------------------------"
;halt

