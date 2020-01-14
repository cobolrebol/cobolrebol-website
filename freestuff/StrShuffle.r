REBOL [
    Title: "String shuffle"
    Purpose: {Given a string that is intended to be a word,
    return a new string that has the same first and last
    characters, but has the middle characters randomly shuffled.}
]

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

;Uncomment to test
;probe STRSHUFFLE ""
;probe STRSHUFFLE "a"
;probe STRSHUFFLE "to"
;probe STRSHUFFLE "the"
;probe STRSHUFFLE "four"
;probe STRSHUFFLE "five"
;probe STRSHUFFLE "postprandial"
;probe STRSHUFFLE "septuagenerian"
;probe STRSHUFFLE "spaniel"
;probe STRSHUFFLE "twenty"
;halt

