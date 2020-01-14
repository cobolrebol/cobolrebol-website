REBOL [
    Title: "Find duplicate items in a block"
    Purpose: {This is a module that can be used in another program to
    find duplicates of a thing, if the things to check can be put into
    a compatible format of a key value followed by a string of various
    attributes.}
]

;; [---------------------------------------------------------------------------]
;; [ This module was written as part of a larger program to check for          ]
;; [ duplicate items of data.  It was created because it always seems to be    ]
;; [ a struggle to remember the best way to check for duplicates, so we        ]
;; [ thought we would solve the problem once and for all at the expense        ]
;; [ of maybe a little memory and processing overhead.                         ]
;; [ The input to the function is a block of strings, occurring in pairs.      ]
;; [ The first item of a pair is a key value.  These are the items that        ]
;; [ might occur as duplicates.  The second item of a pair is a string that    ]
;; [ is whatever you want it to be.  This string identifies some entity        ]
;; [ that contains the key value and of which their might be several.          ]
;; [ For example, you might want to check a list of names and addresses to     ]
;; [ see if any address is occupied by two people.  The address would be the   ]
;; [ key value because it might occur more than one time.  The name would      ]
;; [ be the attribute value because you want to know what attributes have the  ]
;; [ same key value.  So the data would look look like this:                   ]
;; [     key-1 attribute-1                                                     ]
;; [     key-2 attribute-2                                                     ]
;; [     key-3 attribute-3                                                     ]
;; [     key-2 attribute-4                                                     ]
;; [ Notice how key-2 appears twice.  We want to find those keys that          ]
;; [ appear more than once.                                                    ]
;; [ The output of the function is a block that is in a format that is a       ]
;; [ little easier to use for reporting the duplicates.                        ]
;; [ The output block will be data items that occur in pairs.                  ]
;; [ The first item of a pair will be a key value that occurred more than      ]
;; [ once.  The second item of a pair will be a block that contains all        ]
;; [ the attributes that occurred for that key.  It will NOT contain all       ]
;; [ key values, but only those that occurred more than once.  In the above    ]
;; [ example, the output would look like this:                                 ]
;; [     key-2 [attribute-2 attribute-4]                                       ]
;; [ This format is easier to use for the purpose of finding duplicate         ]
;; [ key values and identifying what other data entities contain those         ]
;; [ key values.                                                               ]
;; [ How to use:                                                               ]
;; [ Everything is in a context so the words in the context don't conflict     ]
;; [ with words in your program.                                               ]
;; [ The word INBLOCK is provided to "load" so to speak with the data          ]
;; [ you want to check.  You would:                                            ]
;; [     append DUPCHECK/INBLOCK key-value-1                                   ]
;; [     append DUPCHECK/INBLOCK attributes-value-1                            ]
;; [ and so on until the block contains all the data you want to check.        ]
;; [ Then you call the function DUPCHECK/FIND-DUPLICATES.                      ]
;; [ After that, the word DUPCHECK/OUTBLOCK will refer to the reorganized      ]
;; [ data as explained above.                                                  ]
;; [ If you want to look into the input and output in some manner other        ]
;; [ than halting your program and probing, the function DUPCHECK/DUMP-DATA    ]
;; [ will put the internal data items into a text file, as indicated below.    ]
;; [ IMPORTANT NOTE:  The function is written as if the input data is          ]
;; [ correctly formatted as explained above.  It was written for internal      ]
;; [ use so the proper formatting was handled by the calling program.          ]
;; [ If your data is not correct as explained above, you program will crash.   ]
;; [ Note that the checking for duplicates involves checking the number of     ]
;; [ attributes, seeing if it is greater than one.  That "one" is in the       ]
;; [ word called LIMIT.  If you change the LIMIT to zero, then the             ]
;; [ output of the function will include items for which there is just         ]
;; [ one attribute, which might be helpful in some situations.                 ]
;; [---------------------------------------------------------------------------]

DUPCHECK: context [
    DEBUG: false
    INBLOCK: []
    OUTBLOCK: []
    ATTRIBUTE-BLOCK: []
    TESTBLOCK: []
    RECORDSIZE: 2  ;; Number of strings in one unit of data in INBLOCK
    DUMPFILE-ID: %DUPCHECK-DUMP.txt
    DUMPFILE-TEXT: ""
    HOLD-KEY: ""
    LIMIT: 1
    FIND-DUPLICATES: does [
        if (length? INBLOCK) = 0 [
            exit
        ]
        OUTBLOCK: copy [] ;; in case we do this more than once 
        TESTBLOCK: copy [] 
        sort/skip INBLOCK RECORDSIZE
        HOLD-KEY: copy first INBLOCK 
        foreach [KEY ATTR] INBLOCK [
            if not-equal? KEY HOLD-KEY [  ;; do control break
                if (length? TESTBLOCK) > LIMIT [ ;; found duplicates
                    if DEBUG [
                        print ["-->append a key: " mold HOLD-KEY]
                    ]
                    append OUTBLOCK HOLD-KEY
                    if DEBUG [
                        print ["-->append attributes: " mold TESTBLOCK]
                    ]
                    append/only OUTBLOCK TESTBLOCK
                ]
                TESTBLOCK: copy []
            ]
            HOLD-KEY: copy KEY
            append TESTBLOCK ATTR
        ]
        if (length? TESTBLOCK) > LIMIT [ ;; check after last record
            if DEBUG [
                print ["--*append a final key: " mold HOLD-KEY]
            ]
            append OUTBLOCK HOLD-KEY
            if DEBUG [
                print ["--*append final attributes: " mold TESTBLOCK]
            ]
            append/only OUTBLOCK TESTBLOCK
        ]
    ]
    DUMP-DATA: does [
        DUMPFILE-TEXT: copy ""
        foreach [KEY ATTRBLOCK] OUTBLOCK [
            append DUMPFILE-TEXT rejoin [
                KEY 
                ": "
                mold ATTRBLOCK
                newline
            ] 
        ]
        write DUMPFILE-ID DUMPFILE-TEXT
    ]
]

;; Uncomment to test 
;DUPCHECK/DEBUG: true
;append DUPCHECK/INBLOCK "KEY1" 
;append DUPCHECK/INBLOCK "ATTRIBUTE-1"
;append DUPCHECK/INBLOCK "KEY2" 
;append DUPCHECK/INBLOCK "ATTRIBUTE-2"
;append DUPCHECK/INBLOCK "KEY3" 
;append DUPCHECK/INBLOCK "ATTRIBUTE-3"
;append DUPCHECK/INBLOCK "KEY2" 
;append DUPCHECK/INBLOCK "ATTRIBUTE-4"
;append DUPCHECK/INBLOCK "KEY1" 
;append DUPCHECK/INBLOCK "ATTRIBUTE-5"
;DUPCHECK/FIND-DUPLICATES
;DUPCHECK/DUMP-DATA
;print [read DUPCHECK/DUMPFILE-ID]
;halt


