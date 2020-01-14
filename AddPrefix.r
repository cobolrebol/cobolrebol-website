REBOL [
    Title: "Clipboard prefixer" 
]

;; [---------------------------------------------------------------------------]
;; [ This is a handy little utility that does just one thing.                  ]
;; [ It assumes that the Windows clipboard is loaded with lines of text,       ]
;; [ and it adds a prefix to each line, as specified by the user.              ]
;; [ Then it puts the prefixed lines back into the clipboard.                  ]
;; [---------------------------------------------------------------------------]

PREFIX: request-text

TEMP-LINES: read clipboard://
insert TEMP-LINES PREFIX
replace/all TEMP-LINES newline rejoin [newline PREFIX]
write clipboard:// TEMP-LINES
alert "Clipboard loaded"
;halt
