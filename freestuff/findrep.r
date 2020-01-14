REBOL [
    Title: "Quick and dirty find-and-replace"
    Purpose: {Mass-change all files in a specified folder by
    replacing specified text with other specified text, in a
    hard-coded block in this script itself.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a quick-and-dirty program for mass-changing all source code       ]
;; [ files in a specified folder.  "Quick and dirty" means that a lot of       ]
;; [ things are hard-coded into this program rather than obtained at run time  ]
;; [ in a more generalized manner.                                             ]
;; [ To use the program, modify the function below to detect the correct       ]
;; [ file type.  Then modify the block of find-replace text strings.           ]
;; [ The values below are just samples.  You will replace them with your       ]
;; [ own values.                                                               ]
;; [---------------------------------------------------------------------------] 

;; Helper function to check a given file name to see if it ends
;; with a suffix that indicates it is the type of file we want.
correct-type?: func ["Returns true if file is a specified kind" file] [
    find [%.sql] find/last file "."
]

;; The text to find, and the text to replace it with,
;; hard-coded in the script.
FIND-REPLACE-TEXT: [
    "DATEWRITTEN" "DATE-WRITTEN"
    "SYSTEM" "DATABASE"
    "SEARCHWORDS" "SEARCH-WORDS"
    "Description" "REMARKS"
]

;; Ask the operator for the folder containing the files to check.
;; Go into the requested folder
if not dir? STARTING-FOLDER: request-dir [
    alert "No folder specified"
    quit
]
change-dir STARTING-FOLDER

;; Obtain a list of all files and folders in the requested folder. 
FILE-LIST: read %.

;; Loop through the list of file names obtained above.
;; For each item that is NOT a folder and IS a correct file type,
;; replace all occurrences of the "find text" with the "replace text"
;; and write the file back to disk. 
foreach FILE-NAME FILE-LIST [
    if not dir? FILE-NAME [
        if correct-type? FILE-NAME [
            print ["Fixing file " FILE-NAME]
            FILE-TEXT: copy ""
            FILE-TEXT: read/binary FILE-NAME
            foreach [FIND-TEXT REPLACE-TEXT] FIND-REPLACE-TEXT [
                replace/all FILE-TEXT FIND-TEXT REPLACE-TEXT
            ]
            write/binary FILE-NAME FILE-TEXT
        ]
    ]
]

;; Report that we are done.
print "Done"

;; Halt at a command prompt so all the displayed messages remain visible.
halt


