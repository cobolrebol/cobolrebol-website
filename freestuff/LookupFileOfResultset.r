REBOL [
    Title: "Result-set to lookup table"
    Purpose: {Given an SQL result set, which comes in the form of
    a block of blocks, generate a lookup table and put it into a
    file so it can be loaded by another program.  Make the file
    somewhat nice-looking so it can be scanned visually with a
    text editor.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a specialized function for a specific project.  It starts with    ]
;; [ the result set of an SQL query, which is a block of blocks, where each    ]
;; [ sub-block is a row of the result set.  It transforms that data into a     ]
;; [ lookup table.  The key to the table is formed by combining one or         ]
;; [ more of the columns in a row.  Which columns to use is specified in       ]
;; [ another block passed to the function, a block that contains one or more   ]
;; [ field numbers from the row.  The function will create a lookup key by     ]
;; [ taking the specified fields and concatenating them.                       ]
;; [ For example, if the result set look like this:                            ]
;; [ [                                                                         ]
;; [     [dataname11 dataname12 dataname13 dataname14...]                      ]
;; [     [dataname21 dataname22 dataname23 dataname24...]                      ]
;; [     ...                                                                   ]
;; [ ]                                                                         ]
;; [ and the block of field postions looked like this:                         ]
;; [     [1 3]                                                                 ]
;; [ then the resulting table would look like this:                            ]
;; [ [                                                                         ]
;; [     dataname11-dataname13 [dataname11 dataname12 dataname13 dataname14...]]
;; [     dataname21-dataname23 [dataname21 dataname22 dataname23 dataname24...]]
;; [     ...                                                                   ]
;; [ ]                                                                         ]
;; [ and one would look up an item in the table with the "select" function     ]
;; [ using dataname111dataname13, etc., as a key.                              ]
;; [ An additional argument to the function is a file name, because the        ]
;; [ resulting table will be written to a file with that name.                 ]
;; [ As a final feature, the lookup table will be written to disk with one     ]
;; [ entry per line of text, so it can be scanned visually.                    ]
;; [                                                                           ]
;; [ The expected use of this file is that it will be read by some other       ]
;; [ program using the "load" function, which will bring it in as a block      ]
;; [ that is compatible with the "select" function.                            ]
;; [---------------------------------------------------------------------------]

LOOKUP-FILE-OF-RESULT-SET: func [
    FILEID
    KEYBLOCK
    ROWBLOCK
    /local LOOKUPTABLE TEMPKEY KEYLGH KEYCNT ATTRBLK LINELIST
] [
    LOOKUPTABLE: copy []
    foreach ROW ROWBLOCK [
        ROWLGH: length? ROW
        TEMPKEY: copy ""
        KEYLGH: length? KEYBLOCK
        KEYCNT: 0
        foreach KEYNUM KEYBLOCK [
            KEYCNT: KEYCNT + 1
            append TEMPKEY pick ROW KEYNUM
            if lesser? KEYCNT KEYLGH [
                append TEMPKEY "-"
            ]
        ]
        append LOOKUPTABLE TEMPKEY
        ATTRBLK: copy []
        foreach ITEM ROW [
            append ATTRBLK ITEM
        ]
        append/only LOOKUPTABLE ATTRBLK
    ]
    LINELIST: copy ""
    foreach [KEY VAL] LOOKUPTABLE [
        append LINELIST rejoin [
            mold KEY
            " "
            mold VAL
            newline
        ]        
    ]
    write FILEID LINELIST
]

;;Uncomment to test
;LOOKUP-FILE-OF-RESULT-SET %lookupfile.txt [1 2] [
;    ["AAAA1" "BBBB1" "CCCC1" "DDDD1"]
;    ["AAAA2" "BBBB2" "CCCC2" "DDDD2"]
;    ["AAAA3" "BBBB3" "CCCC3" "DDDD3"]
;    ["AAAA4" "BBBB4" "CCCC4" "DDDD4"]
;    ["AAAA5" "BBBB5" "CCCC5" "DDDD5"]
;]
;TBL: load %lookupfile.txt
;print ["TBL is type" type? TBL]
;print ["First TBL is" mold TBL/1]
;print ["Second TBL is" mold TBL/2]
;print ["Value for AAAA4-BBBB4 is" mold select TBL "AAAA4-BBBB4"]
;halt

