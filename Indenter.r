REBOL [
    Title: "Clipboard indenter" 
]

;; [---------------------------------------------------------------------------]
;; [ This is a handy little utility that does just one thing.                  ]
;; [ It assumes that the Windows clipboard is loaded with lines of text,       ]
;; [ and it inserts four spaces in the front of each line.                     ]
;; [ The reason this is handy is that when coding, sometimes a person wants    ]
;; [ to indent a bunch of lines and doesn't want to hit the space bar four     ]
;; [ times for each line, not to mention the down-arrow and four backspaces.   ]
;; [ To use, highlight a block of lines, cut it to the clipboard, run this     ]
;; [ program, then paste the clipboard back into the place from which you      ]
;; [ cut the lines.                                                            ]
;; [---------------------------------------------------------------------------]

TEMP-LINES: read clipboard://
insert/dup TEMP-LINES " " 4
replace/all TEMP-LINES newline rejoin [newline "    "]
write clipboard:// TEMP-LINES
alert "Clipboard loaded"

