REBOL [
    Title: "Obscure one line of text"
    Purpose: {Given one line of text, break it apart into words,
    scramble each word, and put the line back together again.}
]

;; [---------------------------------------------------------------------------]
;; [ This was a demo project to obscure an email message without actual        ]
;; [ encryption.  It is based on the idea that many words can be recognzed     ]
;; [ if the first and last letters are left in place and the letters           ]
;; [ between the first and last are scrambled.                                 ]
;; [ The main function is OBSCURELINE which takes a line of text, scrambles    ]
;; [ the individual words, and returns a line of text.                         ]
;; [ The function STRSHUFFLE is a helper that scrambles just one word.         ]
;; [---------------------------------------------------------------------------]

ALPHABETIC: charset [#"A" - #"Z" #"a" - #"z"]
;; -- We can't use the double quote as punctuation because the
;; -- "parse" function is too helpful; it recognizes quoted
;; -- strings.
FRONTPUNCTUATION: {(['} 
ENDPUNCTUATION: {)]';:,.!} 

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
    /local WORDS FRONTPUNCT ENDPUNCT OBSCURED 
] [
    OBSCURED: copy ""
    WORDS: copy []
;;  -- Divide input into tokens based on spaces.
    WORDS: parse/all STR " "
;;  -- Put them all back together again.
    foreach WRD WORDS [
;;      print WRD
        FRONTPUNCT: copy ""
        ENDPUNCT: copy ""
        FRONTPUNCH: first WRD
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

;Uncomment to test
;print OBSCURELINE "This is a test of the emergency broadcast system."
;print OBSCURELINE "Lions, tigers, and bears; Oh my!"
;print OBSCURELINE {Lots (sixteen) of people say 'happy birthday' often.} 
;halt

