REBOL [
    Title: "Simple stack object"
    Purpose: {Originally an experiment, provide the basic push and pop
    functions of a stack.  The stack item is a block so it can contain
    whatever you like; there is no fixed format.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a simple stack object, with the basic operations to push or pop.  ]
;; [ It is not designed for any special purpose, so you may put anything       ]
;; [ onto the stack, as long as it is in one block. The format of the data     ]
;; [ in the block is up to you.  The push function takes a block, the pop      ]
;; [ operation returns a block.                                                ]
;; [---------------------------------------------------------------------------]

STACK: make object! [
    ITEM: copy []
    STRUCTURE: copy []
    PUSH: func [
        PUSH-BLOCK
    ] [
        insert/only STRUCTURE PUSH-BLOCK
        STRUCTURE: head STRUCTURE
    ]
    POP: does [
        STRUCTURE: head STRUCTURE
        ITEM: copy first STRUCTURE
        remove STRUCTURE
        return ITEM
    ]
]

;Uncomment to test
;print ["Initial state: " STACK/STRUCTURE]
;STACK/PUSH [123.45]
;print ["1. " STACK/STRUCTURE]
;STACK/PUSH ["TEST STRING" 01-JAN-2000]
;print ["2. " STACK/STRUCTURE]
;STACK/PUSH [1]
;print ["3. " STACK/STRUCTURE]
;STACK/PUSH ["+"]
;print ["4. " STACK/STRUCTURE]
;STACK/PUSH [2]
;print ["5. " STACK/STRUCTURE]
;print ["POP: " STACK/POP]
;print ["6. " STACK/STRUCTURE]
;print ["POP: " STACK/POP]
;print ["7. " STACK/STRUCTURE]
;halt

