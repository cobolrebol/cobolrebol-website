REBOL [
    Title: "Group list of result set"
    Purpose: {Transform a query result that is a grouping of
    one item within another, to another structure that is the
    major group item followed by a block of its associated 
    items.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function written for a very specific part of a very specific    ]
;; [ project.  It might have some more general use in other areas.             ]
;; [ The original situation was to analyze a database table for two columns,   ]
;; [ find all the distinct values for the first column and then, for each      ]
;; [ of those distinct values, find all the possible values that might         ]
;; [ appear in the second column.  The data was extracted out of the table     ]
;; [ and "pre-processed" so to speak into a result set, and then this          ]
;; [ function transformed the result set to the desired format.                ]
;; [ More specifically, imagine a table that has assorted data plus the two    ]
;; [ of relevance called OCC_CODE and LOT_TYPE.  We want to find all the       ]
;; [ distinct OCC_CODE and find all the different LOT_TYPE values that occur   ]
;; [ in the records with the different OCC_CODE.  To accomplish this, we       ]
;; [ would run an SQL query something like this:                               ]
;; [     select                                                                ]
;; [     OCC_CODE, LOT_TYPE                                                    ]
;; [     from LND_TABLE                                                        ]
;; [     group by OCC_CODE                                                     ]
;; [     order by LOT_TYPE                                                     ]
;; [ A query like this might return results like this:                         ]
;; [    [                                                                      ]
;; [    [A1 T1]                                                                ]
;; [    [A1 T2]                                                                ]
;; [    [A2 T3]                                                                ]
;; [    [A2 T4]                                                                ]
;; [    [A3 T1]                                                                ]
;; [    [A3 T4]                                                                ]
;; [    ]                                                                      ]
;; [ Note how the results of an SQL query returned to REBOL comes in the       ]
;; [ form of a block of blocks, where each sub-block is a row of the result.   ]
;; [ This function will take the block-of-blocks result set and transform      ]
;; [ it into a format like this:                                               ]
;; [    [                                                                      ]
;; [    A1 [T1 T2]                                                             ]
;; [    A2 [T3 T4]                                                             ]
;; [    A3 [T1 T4]                                                             ]
;; [    ]                                                                      ]
;; [ You might ask, why not produce a block of blocks instead of just a        ]
;; [ block.  No particular reason, this was just easier and accompished        ]
;; [ the design goal.                                                          ]
;; [---------------------------------------------------------------------------]

GROUP-LIST-FROM-RESULTSET: func [
    RESULTSET
    /local GROUPLIST CRNTCODE SUBBLOCK
] [
    if empty? RESULTSET [
        return []
    ]
    GROUPLIST: copy [] 
    SUBBLOCK: copy [] 
    CRNTCODE: first first RESULTSET
    foreach REC RESULTSET [
        either not-equal? CRNTCODE first REC [
            append GROUPLIST CRNTCODE 
            append/only GROUPLIST SUBBLOCK
            SUBBLOCK: copy []
            append SUBBLOCK second REC
            CRNTCODE: first REC
        ] [
            append SUBBLOCK second REC
        ]
    ]
    append GROUPLIST CRNTCODE 
    append/only GROUPLIST SUBBLOCK
    return GROUPLIST
]

;;Uncomment to test
;TESTRESULT: [
;    ["A1" "T1"]
;    ["A1" "T2"]
;    ["A2" "T3"]
;    ["A2" "T4"]
;    ["A3" "T1"]
;    ["A3" "T4"]
;]   
;GRP: GROUP-LIST-FROM-RESULTSET TESTRESULT
;probe GRP
;foreach [CODE LIST] GRP [
;    print [CODE ":" mold LIST]
;]
;halt

