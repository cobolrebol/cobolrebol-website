REBOL [
    Title: "Scramble a text message"
    Purpose: {Provide an interface for typing some text and
    then scrambling it.}
]

ALPHABETIC: charset [#"A" - #"Z" #"a" - #"z"]
;; -- We can't use the double quote as punctuation because the
;; -- "parse" function is too helpful; it recognizes quoted
;; -- strings.
FRONTPUNCTUATION: {(['} 
ENDPUNCTUATION: {)]';:,.!} 
;; -- Working items for the function are made global so we
;; -- can probe them.
WORDS: ""
FRONTPUNCT: ""
ENDPUNCT: ""
OBSCURED: ""
WRDCNT: 0
WRDWRK: ""
SOURCELINES: []
OBSCURED-TEXT: ""

STRSHUFFLE: func [
    STR
    /local LGH SHUFFLE FST LST MID MIDLGH
] [
    SHUFFLE: copy ""
    LGH: length? STR
    if lesser-or-equal? LGH 3 [ 
        SHUFFLE: copy STR
        return SHUFFLE
    ]
    MIDLGH: LGH - 2
    FST: first STR
    LST: last STR
    MID: copy/part skip STR 1 MIDLGH 
    append SHUFFLE rejoin [
        FST
        random MID
        LST
    ]
    return SHUFFLE
]

OBSCURELINE: func [
    STR
;;  /local WORDS FRONTPUNCT ENDPUNCT OBSCURED 
] [
    OBSCURED: copy ""
    WORDS: copy []
;;  -- Divide input into tokens based on spaces.
    WORDS: parse/all STR " "
;;  -- Put them all back together again.
    foreach WRD WORDS [
;;      print WRD
        WRDWRK: copy WRD
        WRDCNT: WRDCNT + 1
        FRONTPUNCT: copy ""
        ENDPUNCT: copy ""
        FRONTPUNCT: first WRD
        either find FRONTPUNCTUATION FRONTPUNCT [
            remove WRD
        ] [
            FRONTPUNCT: copy ""
        ]
        ENDPUNCT: last WRD
        either find ENDPUNCTUATION ENDPUNCT [
            remove back tail WRD
        ] [
            ENDPUNCT: copy "" 
        ]
        WRD: head WRD
        append OBSCURED rejoin [
            FRONTPUNCT
            STRSHUFFLE WRD
            ENDPUNCT
            " "
        ]
    ]
    return OBSCURED
]

SCRAMBLE-TO-CLIPBOARD: does [
;;  write clipboard:// OBSCURELINE MAIN-TEXT/text
;;  alert "Clipboard loaded."
    if equal? MAIN-TEXT/text "" [
        alert "No text supplied."
        exit
    ]
    OBSCURED-TEXT: ""
    SOURCELINES: parse/all MAIN-TEXT/text "^/"
    foreach LINE SOURCELINES [
        if not-equal? LINE "" [
            replace/all LINE "  " " " ;; multiple spaces kill us
            append OBSCURED-TEXT rejoin [
                OBSCURELINE LINE
                newline
                newline
            ]
        ]
    ]
    write clipboard:// OBSCURED-TEXT
    alert "Clipboard loaded."
]

MAIN-WINDOW: layout [
    across 
    banner "Text scrambler"
    return
    MAIN-TEXT: area 400x500 wrap
    return
    button 200 "Scramble to clipboard" [SCRAMBLE-TO-CLIPBOARD]
    button "Quit" [quit]
    button "Debug" [halt]
]

view center-face MAIN-WINDOW


