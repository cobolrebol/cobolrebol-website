REBOL [
    Title: "Make directory list"
    Purpose: {Given a starting directory, recursively locate all
    the subdirectories and return them in a block.}
]

;; [---------------------------------------------------------------------------]
;; [ This function was created as part of a larger project to double-check     ]
;; [ a massive transfer of one folder of files to a new location.              ]
;; [ The function takes a starting folder, and then locates, recursively,      ]
;; [ all the sub-folders, and returns them in a block that would be used       ]
;; [ for other processing.                                                     ]
;; [ Note that the result of the function is not returned from the function,   ]
;; [ but is an item outside the function.  The reason for this is that the     ]
;; [ function is recurseive and if we initialized the result inside the        ]
;; [ function we would erase the results of previous calls.  So, it would      ]
;; [ be your job to clear DIRECTORY-LIST if your application required you      ]
;; [ to call this function several times.                                      ]
;; [---------------------------------------------------------------------------]

DIRECTORY-LIST: []

MAKE-DIRECTORY-LIST: func [
    SOURCE
] [
    foreach DIR-OR-FILE read SOURCE [
        if find DIR-OR-FILE "/" [
;;          print ["Located " SOURCE/:DIR-OR-FILE]  ;; for debugging
            append DIRECTORY-LIST SOURCE/:DIR-OR-FILE
            MAKE-DIRECTORY-LIST SOURCE/:DIR-OR-FILE
        ]
    ]
]

;;Uncomment to test
;DIRECTORY-LIST: copy [] ;; Do this if you call several times
;MAKE-DIRECTORY-LIST what-dir
;print DIRECTORY-LIST/1
;print DIRECTORY-LIST/2
;print DIRECTORY-LIST/3
;print DIRECTORY-LIST/4
;print DIRECTORY-LIST/5
;print [length? DIRECTORY-LIST " folders in total"]
;halt

