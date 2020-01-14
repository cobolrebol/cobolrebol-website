REBOL [
    Title: "Generate an SQL in statement from the clipboard" 
]

;; [---------------------------------------------------------------------------]
;; [ This is a handy little utility that does just one thing.                  ]
;; [ It assumes that the Windows clipboard is loaded with lines of text,       ]
;; [ with each line containing one string value that we want to be part of     ]
;; [ an SQL "in" statement.  It adds the delimiting single quotes and          ]
;; [ commas, and makes the "in" statement, and puts it back on the clipboard.  ]
;; [---------------------------------------------------------------------------]

TEMP-LINES: read clipboard://
insert TEMP-LINES "('"
replace/all TEMP-LINES newline rejoin ["'" newline ",'"]
append TEMP-LINES "')"
write clipboard:// TEMP-LINES
alert "Clipboard loaded"
;halt
