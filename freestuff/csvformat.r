REBOL [
    Title: "csvformat"
    Purpose: {A function originally desigened to take the result of an
    SQL query, plus a block of column definitione, and produce a CSV
    file.}
]
;; [---------------------------------------------------------------------------]
;; [ This is a function designed to help with the work of making a CSV file    ]
;; [ out of the result of an SQL query.  The result of an SQL query comes      ]
;; [ in a block of blocks.  Each sub-block is a row of data.  Each element     ]
;; [ of a sub-block is data for one column of that row.                        ]
;; [                                                                           ]
;; [ The data elements can't always be written as-is to a CSV file.            ]
;; [ There are a couple reasons for that.  One reason is that the query        ]
;; [ might have returned data not in the preferred type.  For example,         ]
;; [ an element in the database defined as a number might come back with       ]
;; [ a decimal point when you really want an integer with no decimal.          ]
;; [ Another reason is that text data could have embedded commas and that      ]
;; [ would hose up a CSV file.                                                 ]
;; [                                                                           ]
;; [ To take care of those issues, the function needs one more thing in        ]
;; [ addition to the block of sub-blocks that hold the data.                   ]
;; [ It needs another block of blocks.  The sub-blocks in this block           ]
;; [ represent the columns expected in the data.  Each sub-block contains      ]
;; [ two elements.  The first element is a string that will be the column      ]
;; [ heading in the first row of the CSV output.                               ]
;; [ The second element will be an indicator of the type of data in that       ]
;; [ column.  The possibilities for that are shown below in the description    ]
;; [ of one of these sub-blocks.                                               ]
;; [                                                                           ]
;; [ ["col-name-1" ("integer" | "string" | "money" | "decimal") ]              ]
;; [                                                                           ]
;; [ For example, to define two columns of data:                               ]
;; [                                                                           ]
;; [ [                                                                         ]
;; [     ["ID-NUMBER" "integer"]                                               ]
;; [     ["DATE" "string"]                                                     ]
;; [ ]                                                                         ]
;; [                                                                           ]
;; [ If you ran this function using a set of data and the above block          ]
;; [ of descriptions, you would get a CSV file that contained a first row of   ]
;; [     ID-NUMBER,DATE                                                        ]
;; [ and subsequent rows of data elements from the block of data you           ]
;; [ also provided to the function.                                            ]
;; [                                                                           ]
;; [ To call the function then, two things are expected.  The first is a       ]
;; [ block of data blocks as you would get out of an SQL query.                ]
;; [ The second is a block of column descriptions as explained above.          ]
;; [ The function will return a big string which, if written to disk,          ]
;; [ will produce a CSV file.                                                  ]
;; [---------------------------------------------------------------------------]

CSVFORMAT: func [
    RAWDATA
    COLUMNS
    /local CSVOUT COLCOUNT CNT
] [
    CSVOUT: copy ""
    COLCOUNT: length? COLUMNS
;; Emit headings
    CNT: 0
    foreach COL COLUMNS [
        CNT: CNT + 1
        append CSVOUT COL/1
        if lesser? CNT COLCOUNT [
            append CSVOUT ","
        ]
    ]
    append CSVOUT newline 
;; Emit data
    foreach REC RAWDATA [
        CNT: 0
        foreach FLD REC [
            CNT: CNT + 1 
            if equal? COLUMNS/:CNT/2 "integer" [
                append CSVOUT to-integer FLD
            ]
            if equal? COLUMNS/:CNT/2 "string" [
                append CSVOUT rejoin [ {"} trim to-string FLD {"}] 
            ]  
            if equal? COLUMNS/:CNT/2 "money" [
                append CSVOUT to-money FLD  
            ] 
            if equal? COLUMNS/:CNT/2 "decimal" [
                append CSVOUT to-decimal FLD 
            ]  
            if lesser? CNT COLCOUNT [
                append CSVOUT ","
            ]
        ]
        append CSVOUT newline
    ] 
]

;;Uncomment to test
;RAWDATA: [
;    [93.0 20190101 123.00 34.5]
;    [100.0 20190101 340.67 23.7]
;]
;COLUMNS: [
;    ["PID" "integer"]
;    ["DATE" "string"]
;    ["AMOUNT" "money"]
;    ["UNITS" "decimal"]
;]
;print CSVFORMAT RAWDATA COLUMNS
;halt

