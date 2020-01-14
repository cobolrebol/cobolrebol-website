REBOL [
    Title: "Wait for a file to exist"
    Purpose: {A function that can be called to loop until a
    file of a given names comes into existence.  Can be used
    for coordinating several programs running as a job.}
]

;; [---------------------------------------------------------------------------]
;; [ This module provides a function that will loop, and in every pass it      ]
;; [ will check for the existence of a file, the name of which was passed      ]
;; [ as an argument.  When the file comes into existence, the function         ]
;; [ will exit with a value of true.  If a certain amount of time passess      ]
;; [ and the file has not appeared, it will pop up an alert box to ask         ]
;; [ if it should continue waiting.  If the response is yes, it will begin     ]
;; [ the waiting process again.  If the response is no, it will exit with      ]
;; [ a return value of false.  The "certain amount of time" is hard-coded      ]
;; [ because a time-out hardly ever will be an issue.  If you want to          ]
;; [ change the time-out, you could just change the value in the code.         ]
;; [---------------------------------------------------------------------------]

WAIT-FOR-FILE: func [
    FILENAME
    /local TIMEOUT TIMER INTERVAL KEEPWAITING 
] [
    TIMEOUT: 00:00:10
    TIMER: 00:00:00
    INTERVAL: 00:00:01
    KEEPWAITING: false
    forever [
        either exists? FILENAME [
            return true
        ] [
            TIMER: TIMER + INTERVAL 
            wait INTERVAL
            if TIMER > TIMEOUT [
                KEEPWAITING: alert [
                    rejoin ["File " FILENAME " has not appeared"]
                    "Wait more"
                    "Give up"
                ]
                either KEEPWAITING [
                    TIMER: 00:00:00
                ] [
                    return false
                ]
            ]
        ]
    ]
]

;; Uncomment to test; create your own file called exists.txt. 
;either WAIT-FOR-FILE %exists.txt [
;    print "File is there"
;] [
;    print "File is not there"
;]
;halt 


