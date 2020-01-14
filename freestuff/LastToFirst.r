REBOL [
    Title: "Move last name to first"
    Purpose: {Given a string that contains more than one word,
    move the last word to the front of the string.  This was
    created originally for transforming a name to the format of
    last name first followed by first name.}
]

;; [---------------------------------------------------------------------------]
;; [ This function was written originally to operate on a string that          ]
;; [ contained two or more words separated by spaces. The string represented   ]
;; [ a person's name, like "John A Smith" and the function would transform it  ]
;; [ to "Smith John A."  The function will work on other strings, in other     ]
;; [ words it will not crash, but using it on other strings might not make     ]
;; [ any sense.                                                                ]
;; [---------------------------------------------------------------------------]

LAST-TO-FIRST: func [
    NAMEFIELD
    /local WRK TESTCHAR
] [
;;  -- Eliminate trailing spaces and abort of nothing is left.
    WRK: trim NAMEFIELD
    if equal? "" WRK [
        return WRK
    ]
    WRK: head WRK
;;  -- Add one blank at the front to separate the word we move
;;  -- to the front from the rest of the string.
    insert WRK " "
;;  -- Move the last character in the string to the front of
;;  -- the string, and delete it from the end of the string,
;;  -- one character at a time until we hit a blank.
    forever [
        WRK: back tail WRK
        TESTCHAR: copy/part WRK 1
;;;;;   print ["Testing '" TESTCHAR "'"]    ;; debug
        if equal? " " TESTCHAR [
            break
        ]
        remove WRK
        WRK: head WRK
        insert WRK TESTCHAR 
;;;;;   print ["WRK = " WRK]                ;; debug
    ]
;;  --  Return the modified string to the caller.
    WRK: head WRK
    return WRK
]    

;;Uncomment to test
;print [LAST-TO-FIRST "John A Smith"]
;print [LAST-TO-FIRST " "]
;print [LAST-TO-FIRST ""]
;print [LAST-TO-FIRST "ABCDEFGHI"]
;print [LAST-TO-FIRST "Trailing blanks   "]
;print [LAST-TO-FIRST "  Leading blanks"]
;halt

