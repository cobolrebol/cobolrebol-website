REBOL [
    Title: "Function to get all names of certain file types"
    Purpose: {Generalized version of a function from a program by
    Carl.  Given a block of file types, return a block of all the
    file names in the current directory that are of that type.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function borrowed from Carl's picture viewer program.           ]
;; [ Pass to it a block of file types, and the program will assemble a list    ]
;; [ of all files in the current directory of those types.  Return the list    ]
;; [ in a block.  For example:                                                 ]
;; [     FILE-LIST: FILES-OF-TYPE [%.jpg %.JPG %.png %.PNG]                    ]
;; [ Note how you can make a function within a function.                       ]
;; [ General procedure is to get a list of all files in the current folder.    ]
;; [ Go through the list.  If a file has the desired suffix, go on to the      ]
;; [ next file.  Otherwise remove it from the list.  At the end, reposition    ]
;; [ to the head of the list and return it to the caller.                      ]
;; [---------------------------------------------------------------------------]

FILES-OF-TYPE: func [
    TYPE-LIST
    /local FILE-ID-LIST
] [
    OF-TYPE?: func [
        FILE-ID 
    ] [
        find TYPE-LIST find/last FILE-ID "."
    ]
    FILE-ID-LIST: copy []
    FILE-ID-LIST: read %.
    while [not tail? FILE-ID-LIST] [
        either OF-TYPE? first FILE-ID-LIST [
            FILE-ID-LIST: next FILE-ID-LIST
        ] [
            remove FILE-ID-LIST
        ]
    ]
    FILE-ID-LIST: head FILE-ID-LIST
    return FILE-ID-LIST
]

;;Uncomment to test
;probe FILES-OF-TYPE [%.txt %.TXT]
;print "-------------------------------"
;probe FILES-OF-TYPE [%.png %.jpg]
;halt

