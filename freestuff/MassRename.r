REBOL [
    Title: "Mass file renamer"
    Purpose: {Add a prefix to the names of all files in a
    selected directory.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a Q&D program to mass-rename all files in a folder by adding      ]
;; [ a prefix to the file name.  For a bit of generality, the program asks     ]
;; [ for the prefix.                                                           ]
;; [---------------------------------------------------------------------------]

STARTING-DIR: %/C/
change-dir STARTING-DIR

PREFIX: ask "Enter a file name prefix: "

if not FOLDER: request-dir [
    alert "No folder requested"
    quit
]

change-dir FOLDER

FILE-LIST: read FOLDER

foreach FILENAME FILE-LIST [
    NEWNAME: copy ""
    NEWNAME: to-file rejoin [
        PREFIX
        to-string FILENAME
    ]
    RESPONSE: copy ""
    RESPONSE: ask rejoin [
        "Rename "
        to-string FILENAME
        " to "
        to-string NEWNAME
        "? (Y/N)"
    ]
    either equal? RESPONSE "Y" [
        rename FILENAME NEWNAME
        print [FILENAME " now is " NEWNAME]
    ] [
        print [FILENAME " skipped"]
    ]
]

print "Done." 
halt

