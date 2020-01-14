REBOL [
    Title: "Space-fill and zero-fill functions"
    Purpose: {Provide two useful function, in as little
    code as possible, one of which pads a string on the
    right with trailing spaces out to a specified length,
    and the other of which pads a string with leading zeros
    up to a given length.}
]

SPACEFILL: func [
    "Left justify a string, pad with spaces to specified length"
    INPUT-STRING 
    FINAL-LENGTH
] [
    head insert/dup tail copy/part trim INPUT-STRING FINAL-LENGTH #" " 
        max 0 FINAL-LENGTH - length? INPUT-STRING
]

ZEROFILL: func [
    "Add zeros to the front of a string up to a given length"
    INPUT-STRING
    FINAL-LENGTH
] [
    head insert/dup INPUT-STRING #"0" max 0 FINAL-LENGTH - length? INPUT-STRING
]

;;Uncomment to test
;print rejoin ["'" SPACEFILL "  TEST STRING   " 30 "'"]
;print rejoin ["'" SPACEFILL "  TEST STRING THAT IS LONGER THAN 30  " 30 "'"]
;print rejoin ["'" ZEROFILL "123" 6 "'"] 
;print rejoin ["'" ZEROFILL "123456" 6 "'"] 
;halt

