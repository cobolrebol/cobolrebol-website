REBOL [
    Title: "Date and time 'to' functions"
    Purpose: {Some functions for formatting dates and time in useful ways.}
]

;; [---------------------------------------------------------------------------]
;; [ Some functions borrowed from or inspired by the REBOL cookook for         ]
;; [ putting dates and times into useful formats.                              ]
;; [ The important feature of these functions is that for single-digit         ]
;; [ items (January = 1) the function puts on a leading zero, so that the      ]
;; [ resulting dates and times all are the same length.  This is useful        ]
;; [ in, for example, date and time stamps in file names.                      ]
;; [---------------------------------------------------------------------------]

to-yyyymmdd: func [when /hyphens /slashes /local stamp add2] [
    add2: func [num] [ ; always create 2 digit number
        num: form num
        if tail? next num [insert num "0"]
        append stamp num
    ]
    stamp: form when/year
    if hyphens [append stamp "-"]
    if slashes [append stamp "/"]
    add2 when/month
    if hyphens [append stamp "-"]
    if slashes [append stamp "/"]
    add2 when/day
    return stamp
]

to-hhmmss: func [when /colons /local stamp add2] [
    add2: func [num] [ ; always create 2 digit number
        num: form num
        if tail? next num [insert num "0"]
        append stamp num
    ]
    stamp: copy ""
    add2 when/hour
    if colons [append stamp ":"]
    add2 when/minute
    if colons [append stamp ":"]
    add2 to-integer when/second
    return stamp
]

;;Uncomment to test
;print to-yyyymmdd now/date
;print to-yyyymmdd/hyphens now/date
;print to-yyyymmdd/slashes now/date
;print to-hhmmss now/time
;print to-hhmmss/colons now/time
;halt

