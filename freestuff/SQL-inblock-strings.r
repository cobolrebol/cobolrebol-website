REBOL [
    Title: "Make SQL in-list from block of strings"
    Purpose: {Use a files of strings, one per line, and put them
    together in the form of a list that will by syntactically correct
    when pasted into an "in" list in an SQL query.}
]

;; [---------------------------------------------------------------------------]
;; [ This module is an aid in generating an SQL script.                        ]
;; [ There are times when you want to have, on an SQL script, a "where"        ]
;; [ clause that requests items that are "in" a list.  The syntax is           ]
;; [     where (column-name) in                                                ]
;; [         (                                                                 ]
;; [         value-1                                                           ]
;; [         ,value-2                                                          ]
;; [         ,value-3                                                          ]
;; [         ...                                                               ]
;; [         ,value-n                                                          ]
;; [         )                                                                 ]
;; [ Often, those values can be obtained programatically from some source.     ]
;; [ If you can get those values into a block, then this module can create     ]
;; [ the list, everthing EXCEPT the opening and closing parentheses.           ]
;; [ Then, you could insert, progrmatically or by pasting, the result of       ]
;; [ this function into an SQL script.                                         ]
;; [                                                                           ]
;; [ This module is written with the assumption that the values are strings    ]
;; [ and that you got them from some source that does not create strings       ]
;; [ in a format compatible with SQL, where the string delimiter seems to      ]
;; [ be a single quote.  In other words, the input block would look like       ]
;; [ this:                                                                     ]
;; [     [value-1 value-2 value-3 ... value-n]                                 ]
;; [ and the output would look like this:                                      ]
;; [     'value-1'                                                             ]
;; [     ,'value-2'                                                            ]
;; [     ,'value-3'                                                            ]
;; [     ...                                                                   ]
;; [     ,'value-n'                                                            ]
;; [                                                                           ]
;; [ And now for the important feature of this, often the values are           ]
;; [ obtained programmatically, like from a spreadsheet.  In such a case,      ]
;; [ they might be in a text file that looks like this:                        ]
;; [     value-1                                                               ]
;; [     value-2                                                               ]
;; [     value-3                                                               ]
;; [     ...                                                                   ]
;; [     value-n                                                               ]
;; [ If you read that file into memory with the "load" function, the result    ]
;; [ should be a block that is ready to feed into this function.               ]
;; [---------------------------------------------------------------------------]

SQL-INBLOCK-STRINGS: func [
    BLK
    /local INLIST FIRSTVAL
] [
    INLIST: copy ""
    FIRSTVAL: true
    foreach VAL BLK [
        either FIRSTVAL [
            FIRSTVAL: false
            append INLIST rejoin ["'" VAL "'" newline]
        ] [
            append INLIST rejoin [",'" VAL "'" newline]
        ]
    ]
    return INLIST
]

;;Uncomment to test
;TESTDATA: {value-1
;value-2
;value-3
;value-n}
;IN-LIST: SQL-INBLOCK-STRINGS load TESTDATA
;print IN-LIST
;halt

