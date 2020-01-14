REBOL [
    Title: "Remove in-line comments"
    Purpose: {This is a little helper for tidying up source code.
    It takes lines on the clipboard, locates the start of any
    in-line comment, and deletes characters from that point to
    the end of the line.}
] 

;; [---------------------------------------------------------------------------]
;; [ This is a helper program for tidying source code.                         ]
;; [ It was written for a very specific use, which is to remove any in-line    ]
;; [ comments so that the code can be re-commented.                            ]
;; [ For each line, the program locates the in-line comment character and      ]
;; [ removes characters from that point to the end of the line, and then       ]
;; [ adds the line to an output area which will be written back to the         ]
;; [ clipboard for pasting over the original lines.                            ]
;; [---------------------------------------------------------------------------]

RAW-LINES: read clipboard://
TEMP-LINES: parse/all RAW-LINES "^/"
CHANGED-LINES: copy "" 
DEBUG-CURRENT-LINE: ""
DEBUG-LINE-NUMBER: 0
COMMENT-LOC: 0

;; -- Examine each line.  If it has a comment character,          
;; -- remove everything from that point to the end of the line.        
;; -- Add the modified line to an output area.
foreach LINE TEMP-LINES [
    DEBUG-LINE-NUMBER: DEBUG-LINE-NUMBER + 1
    DEBUG-CURRENT-LINE: copy LINE
    if find LINE ";" [
        COMMENT-LOC: index? find LINE ";"  
        CHARS-TO-REMOVE: (length? LINE) - COMMENT-LOC + 1
        remove/part at LINE COMMENT-LOC CHARS-TO-REMOVE
    ]
    append CHANGED-LINES LINE
    append CHANGED-LINES newline
]

;; -- Put the modified lines back on the clipboard.
write clipboard:// CHANGED-LINES
alert "Clipboard loaded"
;halt

