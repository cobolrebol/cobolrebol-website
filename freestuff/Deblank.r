REBOL [
    Title: "Remove excess blanks"
    Purpose: {This is a little helper for tidying up source code.
    It takes lines on the clipboard, parses each one on blanks
    only, and reassembles the lines so there are no strings of
    multiple blanks.}
] 

;; [---------------------------------------------------------------------------]
;; [ This is a helper program for tidying source code that might have been     ]
;; [ messed up by some find-replace operations.  The input is lines of code    ]
;; [ on the clipboard.  The goal of the program is to eliminate excess         ]
;; [ blanks so that there is only one blank between substrings of nonblanks.   ]
;; [ But there is another requirement in this specific situation.              ]
;; [ We want to preserve any leading spaces to preserve indentation.           ]
;; [ So the way we do this is pick off the leading spaces and save them,       ]
;; [ Then parse the remainder on spaces only and string the parsed words       ]
;; [ back together with one blank between each.  Include the original          ]
;; [ leading spaces at the front of the reassembled words.                     ] 
;; [---------------------------------------------------------------------------]

RAW-LINES: read clipboard://
TEMP-LINES: parse/all RAW-LINES "^/"
CHANGED-LINES: copy "" 
NONBLANK: complement BLANK: charset " "

;; -- Examine each line.  Pick off and save any leading spaces.
;; -- Parse the rest on the blank character, into individual strings.
;; -- Re-string the leading spaces followed by the parsed string. 
;; -- Add the reassembled line to an output area.
foreach LINE TEMP-LINES [
    BLANK-STRING: copy/part LINE (FIRST-NONBLANK: index? find LINE NONBLANK) - 1
    REST-OF-STRING: at LINE FIRST-NONBLANK
    SUBSTRINGS: copy []
    SUBSTRINGS: parse REST-OF-STRING " "
    append CHANGED-LINES BLANK-STRING
    foreach SUBSTRING SUBSTRINGS [
        append CHANGED-LINES rejoin [
            SUBSTRING
            " "
        ]
    ]
    append CHANGED-LINES newline
]

;; -- Put the modified lines back on the clipboard.
write clipboard:// CHANGED-LINES
alert "Clipboard loaded"
;halt

