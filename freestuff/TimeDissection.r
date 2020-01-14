REBOL [
    Title: "Time dissection"
    Purpose: {Get the hours, minutes, and seconds from a time.}
]

;; [---------------------------------------------------------------------------]
;; [ This function was created because I got tired of the help that REBOL      ]
;; [ gives when working with time values.  That help is in the form of         ]
;; [ leaving off the seconds if they are zero, and suppressing the leading     ]
;; [ zero before noon.  This function takes a time value and returns a block   ]
;; [ of six things: the hours, minutes, and seconds as integers, and the       ]
;; [ hours, minutes, and seconds as two-byte strings.                          ]
;; [---------------------------------------------------------------------------]

TIME-DISSECTION: func [
    TIMEVAL 
    /local TIMESTRING TIMEPARTS TIMEBLOCK 
] [
    TIMESTRING: copy ""
    TIMEBLOCK: copy []
    TIMEPARTS: copy []
    TIMESTRING: to-string TIMEVAL 
    TIMEPARTS: parse/all TIMESTRING ":"
    append TIMEBLOCK to-integer TIMEPARTS/1
    append TIMEBLOCK to-integer TIMEPARTS/2
    either TIMEPARTS/3 [
        append TIMEBLOCK to-integer TIMEPARTS/3
    ] [
        append TIMEBLOCK 0
    ]
    either lesser? TIMEBLOCK/1 10 [
        append TIMEBLOCK rejoin [
            "0"
            to-string TIMEBLOCK/1
        ]  
    ] [
        append TIMEBLOCK to-string TIMEBLOCK/1
    ]
    either lesser? TIMEBLOCK/2 10 [
        append TIMEBLOCK rejoin [
            "0"
            to-string TIMEBLOCK/2
        ]  
    ] [
        append TIMEBLOCK to-string TIMEBLOCK/2
    ]
    either lesser? TIMEBLOCK/3 10 [
        append TIMEBLOCK rejoin [
            "0"
            to-string TIMEBLOCK/3
        ]  
    ] [
        append TIMEBLOCK to-string TIMEBLOCK/3
    ]
     return TIMEBLOCK 
]
;;Uncomment to test
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION now/time
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION 0:15
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION 3:21
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION 10:25
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION 0:52:21
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION 13:15:40
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;set [hh-int mm-int ss-int hh-str mm-str ss-str] TIME-DISSECTION now/time
;print ["hh-int = " hh-int ", type is " type? hh-int]
;print ["mm-int = " mm-int ", type is " type? mm-int]
;print ["ss-int = " ss-int ", type is " type? ss-int]
;print ["hh-str = " hh-str ", type is " type? hh-str]
;print ["mm-str = " mm-str ", type is " type? mm-str]
;print ["ss-str = " ss-str ", type is " type? ss-str]
;print "---------------------------------------------"
;halt

