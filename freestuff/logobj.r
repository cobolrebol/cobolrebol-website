REBOL [
    Title: "Log file writer"
    Purpose: {Try to generalize some logging functions for re-use.}
]

;; [---------------------------------------------------------------------------]
;; [ This is another idea for a log file.                                      ]
;; [ This is based on an idea from the REBOL cookbook, but expanded a bit.     ]
;; [ The feature of interest in this module is that it is packaged into an     ]
;; [ object so that there can be several functions available.                  ]
;; [ The reason we have several functions available is to separate the         ]
;; [ creating of a log file and the writing to a log file.  The reason we      ]
;; [ want to do that is that in some applications a log will be created        ]
;; [ every time the application is run, but in others, a log file might        ]
;; [ persist over several runs and just have lines added to it.                ]
;; [ In addition, we want each line to start with a date stamp and a time      ]
;; [ stamp, of uniform length so they look nice, and in a format that          ]
;; [ is REBOL-readable.                                                        ]
;; [ To use the module:                                                        ]
;; [ (log-file-name): make LOGOBJ [ {log-file-id) ]                            ]
;; [ To create the log file identifed by the file name you specified:          ]
;; [ (log-file-name)/LOGOBJ-CREATE                                             ]
;; [ To add an entry to the end of the log file:                               ]
;; [ (log-file-name)/LOGOBJ-WRITE (log-entry)                                  ]
;; [ The item (log-entry) can be just about anything, a string, a block,       ]
;; [ whatever.  It will be reduced and written to the log file.                ]
;; [ The line in the file will be started with a date stamp and a time         ]
;; [ stamp in yyyy-mm-dd hh:mm:ss format.  These formats seem to be            ]
;; [ recognized by REBOL in case you later want to analyze the log file        ]
;; [ with a REBOL program.                                                     ]
;; [ if, when writing a log line, the program reduces the input, things look   ]
;; [ nice, but, if the program remolds the input, then the log file            ]
;; [ becomes REBOL-readable.  What to do...                                    ]
;; [---------------------------------------------------------------------------]

LOGOBJ: make object! [

    FILE-ID: %logfile.log

    to-yyyymmdd: func [when /local stamp add2] [
        add2: func [num] [ ; always create 2 digit number
            num: form num
            if tail? next num [insert num "0"]
            append stamp num
        ]
        stamp: form when/year
        append stamp "-"
        add2 when/month
        append stamp "-"
        add2 when/day
        return stamp
    ]

    to-hhmmss: func [when /local stamp add2] [
        add2: func [num] [ ; always create 2 digit number
            num: form num
            if tail? next num [insert num "0"]
            append stamp num
        ]
        stamp: copy ""
        add2 when/hour
        append stamp ":"
        add2 when/minute
        append stamp ":"
        add2 to-integer when/second
        return stamp
    ]

    LOGOBJ-CREATE: does [
        attempt [delete FILE-ID]
        attempt [
            write FILE-ID rejoin [
                to-yyyymmdd now/date
                " "
                to-hhmmss now/time
                " "
                "Log started"
                newline
            ]
        ]
    ]
    LOGOBJ-WRITE: func [
        LOGOBJ-ITEM
    ] [
        write/append FILE-ID rejoin [
            to-yyyymmdd now/date
            " "
            to-hhmmss now/time
            " "
            reduce LOGOBJ-ITEM ;; reduce...remold...hmmm.
            newline
        ] 
    ]       
]

;;Uncomment to test
;TESTWORD: "TEST VALUE"
;LOG: make LOGOBJ [FILE-ID: %logtest.txt]
;LOG/LOGOBJ-CREATE
;LOG/LOGOBJ-WRITE "String entry"
;LOG/LOGOBJ-WRITE ["Entry created at " now]
;LOG/LOGOBJ-WRITE ["TESTWORD IS " TESTWORD]
;LOG/LOGOBJ-WRITE rejoin ["TESTWORD IS " TESTWORD] 
;halt

