REBOL [
    Title: "Align in-line comments"
    Purpose: {This is a little helper for tidying up source code.
    It takes lines on the clipboard, and scans each for a semicolon
    which would indicate (in REBOL) an in-line comment.  It addes to
    each line the necessary number of spaces to line up those 
    semicolons when displayed in a fixed font.}
] 

;; [---------------------------------------------------------------------------]
;; [ This is a helper program for tidying source code that might have been     ]
;; [ messed up by some find-replace operations.  The input is lines of code    ]
;; [ on the clipboard.  The program checks each line for a semicolon which     ]
;; [ is assumed to mark the start of an in-line comment.  It notes the         ]
;; [ location of the semicolon, and saves the highest location found.          ]
;; [ That hightest location found will become the location of the in-line      ]
;; [ comment on all lines (that have in-line comments).                        ]
;; [ The program inserts spaces into each line so that comments align,         ]
;; [ and then puts the modified lines back on the clipboard.                   ]
;; [---------------------------------------------------------------------------]

HIGHEST-COMMENT-START: 0   ;; Highest comment-starting location on a line

RAW-LINES: read clipboard://
TEMP-LINES: parse/all RAW-LINES "^/"
CHANGED-LINES: copy "" 

;; -- Examine each line and find out where the comment (if any) starts.
;; -- Note the highest starting point so we can align all comments there.
foreach LINE TEMP-LINES [
    if COMMENT-LOC: index? find LINE ";" [
        if greater? COMMENT-LOC HIGHEST-COMMENT-START [
            HIGHEST-COMMENT-START: COMMENT-LOC
        ]
    ]
]

;; -- If any line had a comment, align all comments to the location.
if greater? HIGHEST-COMMENT-START 0 [
    foreach LINE TEMP-LINES [
        if COMMENT-LOC: index? INSERT-POINT: find LINE ";" [
            BLANKS-TO-ADD: HIGHEST-COMMENT-START - COMMENT-LOC
            insert/dup INSERT-POINT " " BLANKS-TO-ADD
        ]
    ]
]

;; -- Put the modified lines back on the clipboard.
foreach LINE TEMP-LINES [
    append CHANGED-LINES rejoin [
        LINE
        newline
    ]
]
write clipboard:// CHANGED-LINES
alert "Clipboard loaded"
;halt

