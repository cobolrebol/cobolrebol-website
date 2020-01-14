REBOL [
    Title: "Recursive folder and file lists"
    Purpose: {Create a block of all the file names in a specified
    directory, recursively into sub-directories.  Do a similar
    thing for all folders in a specified directory.}
]

;; [---------------------------------------------------------------------------]
;; [ I tried to make this into a function that would return a block of         ]
;; [ file or folder names, but could not.  To make it work, I had to put       ]
;; [ the final results into words not local to the functions.                  ]
;; [ This probably is a fault of my lack of understanding of REBOL.            ]
;; [ If you call this more than once in a program you will have to clear       ]
;; [ out the lists or you will get things doubled-up.                          ]
;; [---------------------------------------------------------------------------]

RECURSIVE-FILE-LIST: []
RECURSIVE-FOLDER-LIST: []

FIND-FILES-RECURSE: func [
    FOLDER
] [
    foreach FILE read FOLDER [
        either find FILE "/" [
            FIND-FILES-RECURSE FOLDER/:FILE 
        ][
            append RECURSIVE-FILE-LIST FOLDER/:FILE
        ]
    ]
]

FIND-FOLDERS-RECURSE: func [
    FOLDER
] [
    foreach FILE read FOLDER [
        if find FILE "/" [
            append RECURSIVE-FOLDER-LIST FOLDER/:FILE
            FIND-FOLDERS-RECURSE FOLDER/:FILE 
        ]
    ]
]

;;Uncomment to test
;RECURSIVE-FILE-LIST: copy []
;RECURSIVE-FOLDER-LIST: copy []
;either FOLDER-NAME: request-dir [
;    FIND-FILES-RECURSE FOLDER-NAME
;    FIND-FOLDERS-RECURSE FOLDER-NAME
;    print "------------------- files:"
;    foreach ITEM RECURSIVE-FILE-LIST [print ITEM]
;    print "------------------- folders:"
;    foreach ITEM RECURSIVE-FOLDER-LIST [print ITEM]
;] [
;    print "No folder selected"
;]
;halt

