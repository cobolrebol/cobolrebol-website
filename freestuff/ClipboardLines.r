REBOL [
    Title: "Clipboard lines"
    Purpose: {Read from the clipboard a string of lines delimited by
    cr-lf, and return a block of those lines suitable for examination
    on a line-by-line basis.}
]

;; [---------------------------------------------------------------------------]
;; [ This function assumes that the clipboard contains basically a text        ]
;; [ file of lines and breaks it up into those lines and returns the lines     ]
;; [ in a block.  Why not read the clipboard with read/lines?  That seems      ]
;; [ not to give the desired result.  Reading the clipboard as lines still     ]
;; [ seems to produce a string.                                                ]
;; [---------------------------------------------------------------------------]

CLIPBOARD-LINES: func [
    /local CLIPSTRING LINEBLOCK
] [
    LINEBLOCK: copy []
    CLIPSTRING: copy ""
    CLIPSTRING: read clipboard://
    LINEBLOCK: parse/all CLIPSTRING "^(0D)^(0A)"
    return LINEBLOCK
]

;;Uncomment to test
;CLIPPEDLINES: CLIPBOARD-LINES
;print [length? CLIPPEDLINES " lines"]
;halt

