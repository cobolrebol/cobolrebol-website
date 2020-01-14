REBOL [
    Title: "Trim out all non-letter characters from a string"
    Purpose: {Remove various junk characters from a string that is
    supposed to be a name.}
]

;; [---------------------------------------------------------------------------]
;; [ This little function was written for the specific purpose of cleaning     ]
;; [ up a list of names in which any characters besides letters were not       ]
;; [ allowed.  With the "trim" function we can trim out all letters, but       ]
;; [ it seems there is not a function to INCLUDE all letters and trim out      ]
;; [ everything else.                                                          ]
;; [ Because of its specialized use, you will see some specialized features.   ]
;; [ We want to replace non-letter characters with a space to cover cases      ]
;; [ where a name might be something like "John/Jane" so the result does not   ]
;; [ look like "JohnJane."  But if we do that, then we could end up with       ]
;; [ a situation where the result contained double blanks which would look     ]
;; [ bad.  So to take care of most such situations, we do a final              ]
;; [ replacement of all double-blanks with a single blank.  That should take   ]
;; [ care of most situations, and any exceptions we will let pass.             ]
;; [---------------------------------------------------------------------------]

ALPHAONLY: func [
    TEXTFIELD
    /local LETTERSONLY
] [     
    LETTERSONLY: copy ""
    trim TEXTFIELD
    foreach CHARACTER TEXTFIELD [
        either find " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" CHARACTER [
            append LETTERSONLY CHARACTER
        ] [
            append LETTERSONLY " "
        ]   
    ]
    replace/all LETTERSONLY "  " " "
    return LETTERSONLY
]

;;Uncomment to test
;print ALPHAONLY "This is my name   "
;print ALPHAONLY "3.14149"
;print ALPHAONLY "SMITH, JOHN/JANE"
;halt

