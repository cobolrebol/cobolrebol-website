REBOL [
    Title: "Decomma-encomma"
]

;; [---------------------------------------------------------------------------]
;; [ These are little procedures to deal with "numbers" that are present       ]
;; [ as strings of digits separated with commas every three digits,            ]
;; [ a format that REBOL does not recognize.                                   ]
;; [ There also is a procedure to format an integer with those commas,         ]
;; [ for presentation purposes.                                                ]
;; [ Spreadsheets are evil.                                                    ]
;; [---------------------------------------------------------------------------]

DECOMMA: func [
    DC-INPUT [string!]
    /local
        DC-OUTPUT
] [
    DC-OUTPUT: to-integer replace/all copy DC-INPUT "," ""
    return DC-OUTPUT
]

ENCOMMA: func [
    EC-INPUT [integer!]
    /local
        EC-WORK
        EC-LENGTH
        EC-LEFT
        EC-123
        EC-OUTPUT
] [
    EC-WORK: copy ""
    EC-WORK: reverse to-string EC-INPUT  ;; must work from right to left
    EC-LENGTH: length? EC-WORK
    EC-LEFT: EC-LENGTH
    EC-123: 0
    EC-OUTPUT: copy ""
    foreach EC-DIGIT EC-WORK [
        append EC-OUTPUT EC-DIGIT    ;; output one digit
        EC-123: EC-123 + 1           ;; count a group of three
        EC-LEFT: EC-LEFT - 1         ;; note how many are left
        if equal? EC-123 3 [         ;; if we have emitted three digits...
            EC-123: 0
            if greater? EC-LEFT 0 [  ;; ...and there are more to emit...
                append EC-OUTPUT "," ;; ...emit a comma
            ]
        ]
    ]
    EC-OUTPUT: reverse EC-OUTPUT     ;; undo that first reverse 
    return EC-OUTPUT
]

;; -- Un-comment to test:
;X: DECOMMA "123,456,789"
;print [X " is an " type? X]
;Y: ENCOMMA 123456789
;print [Y " is a " type? Y]
;halt

