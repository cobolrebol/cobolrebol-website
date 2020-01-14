REBOL [
    Title: "De-space all file names in selected directory"
]

;; [---------------------------------------------------------------------------]
;; [ This is a Q&D utility program that locates all file names in a            ]
;; [ selected directory, replaces all spaces with hyphens, and, if the         ]
;; [ resulting "de-spaced" name is different from the original name            ]
;; [ (meaning that the original name actually contained spaces), renames       ]
;; [ the original file with the de-spaced name.                                ]
;; [ The original use of this program was to clean up some file names from     ]
;; [ a folder of save emails, where the emails were saved as text files        ]
;; [ with the subject line as the file name.                                   ]
;; [ The code is arranged in a rather plodding manner so that you can add      ]
;; [ your own replacements depending on your own circumstances.                ]
;; [---------------------------------------------------------------------------]

FOLDER-NAME: request-dir
if not FOLDER-NAME [
    alert "No folder specified."
    quit
]
change-dir FOLDER-NAME

FILENAME-LIST: read %.

foreach FILENAME FILENAME-LIST [
;;  -- Make a string copy of the file name    
    WORKNAME: copy ""
    WORKNAME: copy to-string FILENAME
;;  -- Replace known bad characters with other characters 
    replace/all WORKNAME " - " "-"  
    replace/all WORKNAME "..." ""  
    replace/all WORKNAME " " "-"
    replace/all WORKNAME ";" ""
    replace/all WORKNAME "," ""
    replace/all WORKNAME "'" ""
    replace/all WORKNAME "`" ""
    replace/all WORKNAME "?" ""
    replace/all WORKNAME {"} ""
;;  -- Convert the fixed-up file name to a file datatype
    NEWNAME: to-file WORKNAME  
;;  -- If we actually have changed the name, then rename the file
    if not-equal? FILENAME NEWNAME [
        rename FILENAME NEWNAME
    ]
]

alert "Done."


