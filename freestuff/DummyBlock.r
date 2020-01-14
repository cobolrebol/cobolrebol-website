REBOL [
    Title: "Dummy block"
    Purpose: {Make a block of a specified number of empty strings.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a very simple piece of a larger problem.                          ]
;; [ Given a number, return a block with that number of empty strings.         ]
;; [---------------------------------------------------------------------------]

DUMMY-BLOCK: func [
    NUM
    /local BLK
] [
    BLK: copy []
    loop NUM [
        append BLK ""
    ]
    return BLK
]

;;Uncomment to test
;probe DUMMY-BLOCK 10 
;halt

