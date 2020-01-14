REBOL [
    Title: "Remove range address"
    Purpose: {Remove the -xx part of a range address.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a specialized function for a special situation where we want to   ]
;; [ clean up some range addresses to remove the range part.  For example,     ]
;; [ We want an address that looks like this:                                  ]
;; [     1234-36 MAIN ST                                                       ]
;; [ to look like this:                                                        ]
;; [     1234 MAIN ST                                                          ]
;; [ For increased usefulness, the function will return a block of two stings. ]
;; [ The first string will be the "1234 MAIN ST" part, and the second string   ]
;; [ will be the "36" that was dropped out of the original string.             ]
;; [ The hyphen will be eliminated.                                            ] 
;; [---------------------------------------------------------------------------]

REMOVE-RANGE-ADDRESS: func [
    ADR
    /local INRANGE STR1 STR2 RSLT
] [
    INRANGE: false
    STR1: copy ""
    STR2: copy ""
    RSLT: copy []
    foreach CHR ADR [
        if equal? #"-" CHR [
            INRANGE: true
        ]
        if not INRANGE [
            append STR1 CHR
        ]
        if INRANGE [
            if not-equal? #"-" CHR [
                if not-equal? #" " CHR [
                    append STR2 CHR
                ] 
                if equal? #" " CHR [
                    append STR1 CHR
                    INRANGE: false
                ]
            ]
        ] 
    ]
    append RSLT STR1
    append RSLT STR2
    return RSLT
]

;;Uncomment to test
;probe REMOVE-RANGE-ADDRESS "1234 MAIN ST"
;probe REMOVE-RANGE-ADDRESS "1234-36 MAIN ST"
;probe REMOVE-RANGE-ADDRESS "1234 -36 MAIN ST"
;halt

