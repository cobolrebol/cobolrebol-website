REBOL [
    Title: "Log error object"
]

;; [---------------------------------------------------------------------------]
;; [ This is a little helper module that one easily could code in-line but     ]
;; [ is encapsulated here for those who might forget how to do this.           ]
;; [ When you "do" this module, it removes an error file of a given name       ]
;; [ which you may change by modifying this module.  Then it provides a        ]
;; [ function to which you would pass an error object created with the         ]
;; [ "disarm" function.  The function formats the fields of the error          ]
;; [ object into lines of text and writes them to the file.                    ]
;; [ The general idea is that if your code detects an error, you would disarm  ]
;; [ the error and pass the resulting error object to this function,           ]
;; [ which would create a file containing the contents of the error object.    ]
;; [ Usually, an error worthy of being caught in this manner would be a        ]
;; [ fatal error, so the existence of the error file from this module could    ]
;; [ be detected by some sort of controlling script and be used to indicate    ]
;; [ that the program calling this function crashed in some fatal way.         ]
;; [ Here is what you would do to make use of this module:                     ]
;; [ 1.  Modify the name of the log file, if you want to.                      ]
;; [ 2.  Load it into your program with the "do" function.                     ]
;; [ 3.  In your program, where there is some function that might produce      ]
;; [     an error that you want to capture, code it like this:                 ]
;; [     if error? RESULT: try [code-that-might-produce-error] [               ]
;; [         ERROR-OBJECT: disarm RESULT                                       ]
;; [         LOG-ERROR-OBJECT ERROR-OBJECT                                     ]
;; [         (whatever code you want to run in case of error)                  ]
;; [     ]                                                                     ]
;; [ What step 3 does is to try to run your code, and return to RESULT         ]
;; [ (which is a word of your choice and need not be "RESULT") either          ]
;; [ the result of your code or an error.  Then you check to see if you        ]
;; [ got an error, and if you did, you capture that error into an object       ]
;; [ which is called ERROR-OBJECT (once again, a name of your choice which     ]
;; [ need not be "ERROR-OBJECT").  You pass that object to the function        ]
;; [ below called LOG-ERROR-OBJECT which will write the contents of the        ]
;; [ object to the error file.                                                 ]
;; [ In the original use scenario for this module, an error captured in        ]
;; [ this way would be a fatal one, and the calling program would quit,        ]
;; [ leaving behind the error file as an indicator of failure.                 ]
;; [---------------------------------------------------------------------------]

LOG-ERROR-FILE-ID: %errorlogfile.txt
if exists? LOG-ERROR-FILE-ID [
    delete LOG-ERROR-FILE-ID
]

LOG-ERROR-OBJECT: func [
    ERROR-OBJECT
] [
    ERROR-TEXT: copy []
    append ERROR-TEXT rejoin [
        now
        " An error has occurred at the function call "
        ERROR-OBJECT/where
;;      newline  ;; It seems that newline is included in error data.
    ]
    append ERROR-TEXT rejoin [
        "near lines: "
        ERROR-OBJECT/near
;;      newline
    ]
    append ERROR-TEXT rejoin [
        "id: "
        ERROR-OBJECT/id
;;      newline
    ]
    append ERROR-TEXT rejoin [
        "arg1: "
        ERROR-OBJECT/arg1
;;      newline
    ]
    append ERROR-TEXT rejoin [
        "arg2: "
        ERROR-OBJECT/arg2
;;      newline
    ]
    append ERROR-TEXT rejoin [
        "arg3: "
        ERROR-OBJECT/arg3
;;      newline
    ]
        write/lines LOG-ERROR-FILE-ID ERROR-TEXT
]

