REBOL [
    Title: "Check a string of characters for being a valid file ID"
    Purpose: {Encapuslate some checks to make sure a string of
    characters is a valid file ID.  Trim out special characters and
    and spaces and then check for a suffix.  If it has a suffix,  
    return the trimed name, otherwise return false.}             
]

;; [---------------------------------------------------------------------------]
;; [ The characters I trim out are ones I don't personally like.               ]
;; [ Really, it probably is OK to use them.                                    ]
;; [ Note that this will not return a false if the last character is a dot.    ]
;; [ This was written for fixing obvious bad names but not everything          ]
;; [ that anyone could throw at it.                                            ]
;; [---------------------------------------------------------------------------]

VALIDATE-FILENAME: func [
    FILENAME
] [
    trim/all/with FILENAME { ,()/@"}
    either find/last FILENAME "." [
        return FILENAME
    ] [
        return false
    ]
]

;;Uncomment to test
;print VALIDATE-FILENAME ""
;print VALIDATE-FILENAME "TEST.TXT"
;print VALIDATE-FILENAME "Me and Dog (in truck).jpg"
;print VALIDATE-FILENAME "48P38()!@"
;print VALIDATE-FILENAME "."
;halt

