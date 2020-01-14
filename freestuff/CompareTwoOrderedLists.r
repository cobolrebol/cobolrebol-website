REBOL [
    Title: "Compare two ordered lists"
    Purpose: {Compare two blocks of items, on the assumption
    that the items are sorted and are mostly the same except 
    that a few items will differ, and some will be present in
    one list but not the other.  This was originally used on
    two text files, but could be used on any blocks since it 
    it is a function that takes two blocks.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function that was part of a larger project.                     ]
;; [ This function takes two blocks of items which are assumed to be           ]
;; [ sorted in ascending order.  The original input was blocks of text         ]
;; [ lines read from files with the "read/lines" function, and the files       ]
;; [ were created by reading all the file names in a folder and writing        ]
;; [ those file names to text files, one file name per line.                   ]
;; [ The function starts at the head of each block and compares items          ]
;; [ one by one.  If items are equal, all is well, but as soon as one item     ]
;; [ is larger than the one at the same position in the other file,            ]
;; [ the function reads items from those that are less until it finds one      ]
;; [ that is equal and the blocks are thus matching again.                     ]
;; [ The original use was comparing lists of files from two folders and        ]
;; [ finding out which folder had files not present in the other.              ]
;; [ The results of this function, finding items in one list but not the       ]
;; [ other, don't necessarily have any meaning without some context.           ]
;; [ Was something added to one list?  Was something deleted from the other?   ]
;; [ The only thing we know is that an item is in one list and not the         ]
;; [ other, so that is all we will report.  The result of this function        ]
;; [ will be a block, containt two sub-blocks.  The first sub-block will       ]
;; [ be the items that were in the first list but not the second, and the      ]
;; [ second sub-block will be the items that were in the second block but      ]
;; [ not the first.  It will be up to the caller to decide what it all means.  ]
;; [                                                                           ]
;; [ As a tribute to my incompetence, I am leaving all the debugging code      ]
;; [ in here to show the terrible time I had getting this to work.             ]
;; [ To debug the function, I put all the words from the function outside      ]
;; [ the function to make them global, so I could "probe" them when the        ]
;; [ function crashed.  Then, when I got it working, I put all the words       ]
;; [ back into the function, making them local to the function.                ]
;; [---------------------------------------------------------------------------]

;; -- Started with global words for probing after the inevitable crash
;   LIST1: []
;   LIST2: []
;   L1SUB: 0       ;; For picking items from LIST1
;   L2SUB: 0       ;; For picking items from LIST2
;   L1END: 0       ;; Size of LIST1
;   L2END: 0       ;; Size of LIST2 
;   L1EXTRAS: []   ;; Items in LIST1 not in LIST2
;   L2EXTRAS: []   ;; Items in LIST2 not in LIST1 
;   COMPARISON: "" ;; Comparison result for debugging
;   RESULT: []     ;; Block of 2 blocks returned to caller
;   LOC: ""        ;; For debugging
COMPARE-TWO-ORDERED-LISTS: func [
    LIST1 [block!]
    LIST2 [block!]
    /local 
    L1SUB        ;; For picking items from LIST1
    L2SUB        ;; For picking items from LIST2
    L1END        ;; Size of LIST1
    L2END        ;; Size of LIST2 
    L1EXTRAS     ;; Items in LIST1 not in LIST2
    L2EXTRAS     ;; Items in LIST2 not in LIST1 
    COMPARISON   ;; Item comparison result
    RESULT       ;; Block of 2 blocks returned to caller
;   LOC          ;; For debugging
] [
    L1SUB: 1
    L2SUB: 1
    L1END: length? LIST1
    L2END: length? LIST2 
    L1EXTRAS: copy []
    L2EXTRAS: copy []
    RESULT: copy []
;;  -- Functions we will use when lists stop matching
;;  -- Flush the rest of LIST1
    FLUSH-LIST1-TO-END: does [
;       LOC: copy "FLUSH-LIST1-TO-END"
        while [L1SUB <= L1END] [
            append L1EXTRAS LIST1/:L1SUB
            L1SUB: L1SUB + 1
        ]
    ]
;;  -- Flush the rest of LIST2
    FLUSH-LIST2-TO-END: does [
;       LOC: copy "FLUSH-LIST2-TO-END"
        while [L2SUB <= L2END] [
            append L2EXTRAS LIST2/:L2SUB
            L2SUB: L2SUB + 1
        ]
    ]
;;  -- Flush LIST1 until it matches LIST2 or we hit the end
    FLUSH-LIST1-TO-END-OR-EQUAL: does [
;       LOC: copy "FLUSH-LIST1-TO-END-OR-EQUAL"
        while [(L1SUB <= L1END) and (lesser? LIST1/:L1SUB LIST2/:L2SUB)] [
            append L1EXTRAS LIST1/:L1SUB
            L1SUB: L1SUB + 1 
            if (L1SUB > L1END) [break] ;; 'and' might not work like we think
        ]
    ]
;;  -- Flush LIST2 until it matches LIST1 or we hit the end
    FLUSH-LIST2-TO-END-OR-EQUAL: does [
;       LOC: copy "FLUSH-LIST2-TO-END-OR-EQUAL"
        while [(L2SUB <= L2END) and (lesser? LIST2/:L2SUB LIST1/:L1SUB)] [
            append L2EXTRAS LIST2/:L2SUB
            L2SUB: L2SUB + 1     
            if (L2SUB > L2END) [break] ;; 'and' might not work like we think
        ]
    ]
;;  -- Start looping through the two lists.
;;  -- Do this until we have gone through both lists, which will be
;;  -- indicated by L1SUB and L2SUB both being greater than the sizes
;;  -- of their respective lists.
    until [
;       LOC: copy "MAIN LOOP"
;;      -- If we come into this function with either list empty,
;;      -- flush the non-empty one and quit the loop.
;;      -- If both lists empty, quit now
        if ((L1END = 0) and (L2END = 0)) [
            break
        ]
;;      -- If list 1 is empty, flush list 2 if not empty and quit
        if (L1END = 0) [
            either (L2END > 0) [
                FLUSH-LIST2-TO-END
                break
            ] [
                break
            ]
        ]
;;      -- If list 2 is empty, flush list 1 if not empty and quit
        if (L2END = 0) [
            either (L1END > 0) [
                FLUSH-LIST1-TO-END
                break
            ] [
                break
            ]
        ]
;;      -- Start the actual matching now that we have two
;;      -- non-empty lists.
;;      -- If current items are the same, go to the next pair
        if equal? LIST1/:L1SUB LIST2/:L2SUB [
            COMPARISON: copy "EQUAL"
        ]
        if lesser? LIST1/:L1SUB LIST2/:L2SUB [
            COMPARISON: copy "LESS"
        ]
        if lesser? LIST2/:L2SUB LIST1/:L1SUB [
            COMPARISON: copy "GREATER"
        ]
        if equal? COMPARISON "EQUAL" [
            L1SUB: L1SUB + 1
            L2SUB: L2SUB + 1
        ]
        if equal? COMPARISON "LESS" [
            FLUSH-LIST1-TO-END-OR-EQUAL    
        ]
        if equal? COMPARISON "GREATER" [
            FLUSH-LIST2-TO-END-OR-EQUAL
        ]
;;      -- If any of the above comparisons put either list at
;;      -- its end, then flush the other list.
        if (L1SUB > L1END) [
            if (L2SUB <= L2END) [
                FLUSH-LIST2-TO-END
            ]
        ]
        if (L2SUB > L2END) [
            if (L1SUB <= L1END) [
                FLUSH-LIST1-TO-END
            ]
        ]
;;      -- Compare the two subscipts to the endpoints.
;;      -- If both are beyond the end, the test will return true
;;      -- and the loop will end.
        ((L1SUB > L1END) and (L2SUB > L2END))
    ]
;;  -- Build our result block of two sub-blocks
    append/only RESULT L1EXTRAS
    append/only RESULT L2EXTRAS 
    return RESULT
]

;;Uncomment to test
;print "----------------------------------"

;print "Identical lists"
;;LIST1:   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;;LIST2:   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;DIFFS: COMPARE-TWO-ORDERED-LISTS 
;   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "Empty lists" 
;;LIST1:   []
;;LIST2:   []
;DIFFS: COMPARE-TWO-ORDERED-LISTS 
;   []
;   []
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "One list empty" 
;;LIST1:   ["A" "B" "C"]
;;LIST2:   []
;DIFFS: COMPARE-TWO-ORDERED-LISTS 
;   ["A" "B" "C"]
;   []
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "Differences in the middle"
;;LIST1:   ["A" "B"     "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;;LIST2:   ["A" "B" "C" "D" "E" "F"         "I" "J" "K" "L" "M" "N"]
;DIFFS: COMPARE-TWO-ORDERED-LISTS 
;   ["A" "B"     "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;   ["A" "B" "C" "D" "E" "F"         "I" "J" "K" "L" "M" "N"]
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "Differences at the ends"
;;LIST1:   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"        ]
;;LIST2:   [                    "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;DIFFS: COMPARE-TWO-ORDERED-LISTS
;   ["A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"        ]
;   [                    "F" "G" "H" "I" "J" "K" "L" "M" "N"]
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "List 1 is shorter"
;;LIST1:   ["A" "B" "C" "D" "E"]
;;LIST2:   ["A" "B" "C" "D" "E" "F"]
;DIFFS: COMPARE-TWO-ORDERED-LISTS
;   ["A" "B" "C" "D" "E"]
;   ["A" "B" "C" "D" "E" "F"]
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;print "List 2 is shorter"
;;LIST1:   ["A" "B" "C" "D" "E" "F"]
;;LIST2:   ["A" "B" "C" "D" "E"]
;DIFFS: COMPARE-TWO-ORDERED-LISTS
;   ["A" "B" "C" "D" "E" "F"]
;   ["A" "B" "C" "D" "E"]
;;DIFFS: RESULT
;print ["Not in 2 " mold DIFFS/1]
;print ["Not in 1 " mold DIFFS/2]
;print "----------------------------------"

;halt

