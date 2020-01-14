REBOL [
    Title: "Get next ID"
    Purpose: {Get a number one higher than the number stored in
    a specified file, and store the new number back in the 
    specified file.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function written for the situation where you are assigning      ]
;; [ ID numbers to things (like data records) and want to keep track of        ]
;; [ the highest number you have assigned.  The highest number assigned is     ]
;; [ kept in a one-line file, and the function reads that number, adds 1 to    ]
;; [ it, saves the new number, and returns the new number so you can           ]
;; [ assign it to some new thing.                                              ]
;; [ This is an operation one wants to do with as few instructions as          ]
;; [ possible.                                                                 ]
;; [ Because the name of the file is passed to the function, this same         ]
;; [ function could be used in a program that has several such ID numbers.     ]
;; [ To save the trouble of initialization, if the specified file does         ]
;; [ not exist, we will assume we are starting with ID number 1 and create     ]
;; [ the file with that number in it.                                          ]
;; [---------------------------------------------------------------------------]

GET-NEXT-ID: func [
    FILE-ID
] [
    either exists? FILE-ID [
        save FILE-ID HIGHEST-OPEN: add 1 load FILE-ID
    ] [
        save FILE-ID HIGHEST-OPEN: 1
    ]
    return HIGHEST-OPEN
]

;;Uncomment to test
;print GET-NEXT-ID %HighestOpen.txt
;print GET-NEXT-ID %HighestOpen.txt
;halt

