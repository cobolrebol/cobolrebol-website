REBOL [
    Title: "Function to divide a string on the first digit"
    Purpose: {This is a special-purpose function created originally
    to divide a single string containing a name and address, into
    two strings based on the first digit, which is assumed to be
    the start of an address.}
]

DIVIDE-FIRST-DIGIT: func [
    INPUT-STRING
    /local DIGITFOUND STRING1 STRING2 RESULTS
] [
    DIGITFOUND: false
    STRING1: copy ""
    STRING2: copy ""
    RESULTS: copy []
    foreach TEST-BYTE INPUT-STRING [
        if 
           (TEST-BYTE = #"0") or
           (TEST-BYTE = #"1") or
           (TEST-BYTE = #"2") or
           (TEST-BYTE = #"3") or
           (TEST-BYTE = #"4") or
           (TEST-BYTE = #"5") or
           (TEST-BYTE = #"6") or
           (TEST-BYTE = #"7") or
           (TEST-BYTE = #"8") or
           (TEST-BYTE = #"9")  [ 
            DIGITFOUND: true
        ]
        either DIGITFOUND [
            append STRING2 TEST-BYTE
        ] [
            append STRING1 TEST-BYTE 
        ]        
    ]
    append RESULTS trim STRING1
    append RESULTS trim STRING2
    return RESULTS
]

;;Uncomment to test
;print mold DIVIDE-FIRST-DIGIT "JOHN SMITH 123 MAIN ST 55431"
;print mold DIVIDE-FIRST-DIGIT "ALL CHARACTERS ALPHABETIC"
;print mold DIVIDE-FIRST-DIGIT "1ST COURIER SERVICE 7000 INDUSTRIAL BLVD"
;halt

