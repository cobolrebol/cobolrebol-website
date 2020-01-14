REBOL [
    Title: "Read directory recursively and find FILE names"
    Purpose: {Get all the FILE names in a directory, but also go
    into all subdirectories.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function harvested from the internet that looks through         ]
;; [ a specified directory, recursively, and locates all the files and         ]
;; [ in that directory.  The original was found here:                          ]
;; [https://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Recursion]
;; [---------------------------------------------------------------------------]

READ-DIR-LIST: []
READ-DIR: func [ 
   dir [file!]
][
   foreach FILE read dir [
       FILE: either dir = %./ [FILE][dir/:FILE]
       append READ-DIR-LIST FILE
       if dir? FILE [
           READ-DIR FILE
       ]
    ]
]

;;Uncomment to test
;READ-DIR %./
;new-line/all READ-DIR-LIST on  ;; Insert newline between all block elements.
;print mold READ-DIR-LIST
;halt
