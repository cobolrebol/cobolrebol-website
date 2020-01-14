REBOL [
    Title: "Split address"
]

;; [---------------------------------------------------------------------------]
;; [ This is a specialized module for a specialized situation.                 ]
;; [ In property-related systems, building addresses often consist of a        ]
;; [ house number followed by a street name.  Often they are coded in one      ]
;; [ string.  And often it is useful to obtain just the house number or        ]
;; [ just the street name.                                                     ]
;; [ This function takes an address in that for, for example,                  ]
;; [     1800 W Old Shakopee Rd                                                ]
;; [ and returns a two-item block consisting of the first non-blank            ]
;; [ string of characters plus whatever else followed that first token,        ]
;; [ minus any leading or trailing spaces that will be trimmed off.            ]
;; [---------------------------------------------------------------------------]

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

; uncomment to test
;
;set [HOUSE-NUMBER STREET-NAME] SPLIT-ADDRESS "1800 W OLD SHAKOPEE RD"
;print [HOUSE-NUMBER STREET-NAME]
;set [HOUSE-NUMBER STREET-NAME] SPLIT-ADDRESS "  9900 LYNDALE AVE S  "
;print [HOUSE-NUMBER STREET-NAME]
;set [HOUSE-NUMBER STREET-NAME] SPLIT-ADDRESS " 8300 1/2 GLEN WILDING DR "
;print [HOUSE-NUMBER STREET-NAME]
;halt

