REBOL [
    Title: "Phone number edit"
]

;; [---------------------------------------------------------------------------]
;; [ This is a function to produce a phone number in the form of               ]
;; [     (999) 999-9999                                                        ]
;; [ from a phone number in that format or in one of the other two formats of  ]
;; [     9999999999    999-999-9999                                            ]
;; [ or in the original format, in which case this formatting would not be     ]
;; [ necessary but is included for completeness.                               ]
;; [ The procedure will be to trim out whitespace and special characters       ]
;; [ and the restring the remaining characters together.  If the remaining     ]
;; [ characters are not ten in number, the the original input is returned      ]
;; [ without any reformatting.                                                 ]
;; [---------------------------------------------------------------------------]

PHONE-EDIT: func [
    PHONE-NUMBER
] [
    PHONE-TRIMMED: trim/all/with copy PHONE-NUMBER " -()"
    if not-equal? length? PHONE-TRIMMED 10 [
        return PHONE-NUMBER
        exit
    ]
    PHONE-OUT: copy ""
    PHONE-OUT: rejoin [
        "("
        pick PHONE-TRIMMED 1
        pick PHONE-TRIMMED 2
        pick PHONE-TRIMMED 3
        ") "
        pick PHONE-TRIMMED 4
        pick PHONE-TRIMMED 5
        pick PHONE-TRIMMED 6
        "-"
        pick PHONE-TRIMMED 7
        pick PHONE-TRIMMED 8
        pick PHONE-TRIMMED 9
        pick PHONE-TRIMMED 10
    ]
    return PHONE-OUT
]

; Uncomment to test
;
; print PHONE-EDIT "1234567890"
; print PHONE-EDIT "(123)456-7890"
; print PHONE-EDIT "123-456-7890"
; halt

