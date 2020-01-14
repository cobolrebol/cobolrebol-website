REBOL [
    Title: "Lookup list object"
    Purpose: {Create a lookup list from a text file, using the
    trimmed content of each line of the file.  This was created
    for a rather specific situation of making a lookup list of
    identifying numbers, one per line of a text file.}
]

;; [---------------------------------------------------------------------------]
;; [ This module was created to aid in the mind-numbing and error-prone        ]
;; [ operation of finding out if an idendifying number from one list is in     ]
;; [ another list.  The idendifying numbers exist, or can be made to exist     ]
;; [ through appropriate exporting, in a text file, with one number per line   ]
;; [ in the file.  This module reads such a file, and, for each line, trims    ]
;; [ off trailing blanks and adds each trimmed string to a block.              ]
;; [ The resulting block can be searched with the "find" function to see       ]
;; [ if something is in it.  The block can be put on disk with the "save"      ]
;; [ function and used later with the "load" function.                         ]
;; [---------------------------------------------------------------------------]

LOOKUPLIST: make object! [
    SAVE-ID: %LookupList.txt  ;; For output, in case we want to save the list
    ID-LIST: []               ;; The list we will build
    INPUT-ID: none            ;; Source for the list
    RAW-DATA: []              ;; Lines from the input file
    FOUND-FLAG: false         ;; Result of search 
    BUILD-LIST: does [
        ID-LIST: copy []
        RAW-DATA: copy []
        if INPUT-ID: request-file/only [
            RAW-DATA: read/lines INPUT-ID
            foreach LINE RAW-DATA [
                append ID-LIST trim LINE
            ]
        ]
    ]
    SEARCH-LIST: func [
        SEARCH-ITEM
    ] [
        ID-LIST: head ID-LIST
        either find ID-LIST SEARCH-ITEM [
            FOUND-FLAG: true
        ] [
            FOUND-FLAG: false 
        ]
    ]
    SAVE-LIST: does [
        save SAVE-ID ID-LIST
    ]
]

;;Uncomment to test
;TBL: make LOOKUPLIST [
;    SAVE-ID: %testlist.txt
;]
;TBL/BUILD-LIST
;print TBL/SEARCH-LIST "30 116 21 41 0021"
;print TBL/SEARCH-LIST "XXXXX"
;TBL/SAVE-LIST
;halt


