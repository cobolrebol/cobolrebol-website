REBOL [
    Title: "Character type tests"
    Purpose: {Encapsulate basic data type checking into
    functions that I can remember.}
]

;; [---------------------------------------------------------------------------]
;; [ These a functions that are so simple (thanks to the power of parsing)     ]
;; [ that one could just as well code them in-line, but some people like       ]
;; [ the readability of an appropriately-named function like IS-NUMERIC.       ]
;; [---------------------------------------------------------------------------] 

CHARSET-NUMERIC: charset [#"0" - #"9"]
CHARSET-ALPHABETIC: charset [#"A" - #"Z" #"a" - #"z"]
CHARSET-ALPHANUMERIC: union CHARSET-ALPHABETIC CHARSET-NUMERIC 

IS-NUMERIC: func [
    STR
] [
    return parse STR [some CHARSET-NUMERIC]
]

IS-APLHABETIC: func [
    STR
] [
    return parse STR [some CHARSET-ALPHABETIC]
]

IS-ALPHANUMERIC: func [
    STR
] [
    return parse STR [some CHARSET-ALPHANUMERIC]
]

;;Uncomment to test
;STR: "12345" 
;print [STR ":"]
;print ["Numeric: " IS-NUMERIC STR] 
;print ["Alphabetic: " IS-ALPHANUMERIC STR] 
;print ["Alphanumeric: " IS-ALPHANUMERIC STR] 
;print "------------------------------"
;STR: "ABCde" 
;print [STR ":"]
;print ["Numeric: " IS-NUMERIC STR] 
;print ["Alphabetic: " IS-ALPHANUMERIC STR] 
;print ["Alphanumeric: " IS-ALPHANUMERIC STR] 
;print "------------------------------"
;STR: "123ab" 
;print [STR ":"]
;print ["Numeric: " IS-NUMERIC STR] 
;print ["Alphabetic: " IS-ALPHANUMERIC STR] 
;print ["Alphanumeric: " IS-ALPHANUMERIC STR] 
;print "------------------------------"
;STR: " a 1@" 
;print [STR ":"]
;print ["Numeric: " IS-NUMERIC STR] 
;print ["Alphabetic: " IS-ALPHANUMERIC STR] 
;print ["Alphanumeric: " IS-ALPHANUMERIC STR] 
;print "------------------------------"
;halt

