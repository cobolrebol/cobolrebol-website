REBOL [
    Title: "Tab-delimited file from a block"
    Purpose: {Create a tab-delimited file from a block of headings and a 
    block of data.}
]

;; [---------------------------------------------------------------------------]
;; [ The purpose is to create a tag-delimited file from data in                ]
;; [ a specific form.  That form is a block of column headings plus a block    ]
;; [ of sub-blocks where each sub-block is going to be a line in the file.     ]
;; [ So to call the function, you must specify a file name for the output      ]
;; [ file, plus a block of heading strings (or words because we will convert   ]
;; [ them to strings to be sure), plus a block of sub-blocks of data.          ]
;; [ For example,                                                              ]
;; [ TAB-FROM-BLOCK %tabfile.txt ["COL1" "COL2" COL3"] [                       ]
;; [     ["A" "B" "C"]                                                         ]
;; [     ["D" "E" "F"]                                                         ]
;; [     ["G" "H" "I"]                                                         ]
;; ] ]                                                                         ]
;; [ The result would be a file called tabfile.txt containing:                 ]
;; [ COL1(tab)COL2(tab)COL3                                                    ]
;; [ A(tab)B(tab)C                                                             ]
;; [ D(tab)E(tab)F                                                             ]
;; [ G(tab)H(tab)I                                                             ]
;; [ Note that you must provide clean data.  The number of heading items       ]
;; [ must match the number of data items in each data sub-block.               ]
;; [---------------------------------------------------------------------------]

TAB-FROM-BLOCK: func [
    FILEID
    HEADERBLOCK
    DATABLOCK
    /local DATAFILE COLS CNT 
] [
    DATAFILE: copy ""
    COLS: length? HEADERBLOCK
    CNT: 0
    foreach HDR HEADERBLOCK [
        CNT: CNT + 1
        append DATAFILE HDR
        if lesser? CNT COLS [
            append DATAFILE "^(tab)"
        ]
    ]
    append DATAFILE newline
    foreach BLK DATABLOCK [
        CNT: 0
        foreach ITEM BLK [
            CNT: CNT + 1
            append DATAFILE ITEM
            if lesser? CNT COLS [
                append DATAFILE "^(tab)"
            ]
        ]
        append DATAFILE newline
    ]
    write FILEID DATAFILE
]

;;Uncomment to test
;TAB-FROM-BLOCK %tabfile.txt ["COL1" "COL2" "COL3"] [
;    ["A" "B" "C"] 
;    ["D" "E" "F"] 
;    ["G" "H" "I"]
;]  
;halt

