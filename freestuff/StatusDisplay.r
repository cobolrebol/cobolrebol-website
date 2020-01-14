REBOL [
    Title: "Status display"
    Purpose: {Show a reassuring status box indicating what a program
    is doing and how far along it is.}
]

;; [---------------------------------------------------------------------------]
;; [ This module is a few functions you can use to show a status display       ]
;; [ for a running program.  You have to use them properly, because they       ]
;; [ don't do any checking.                                                    ]
;; [                                                                           ]
;; [ SHOW-STATUS-WINDOW: Do this first, to get a the status window showing.    ]
;; [     The view/new function shows the status box but lets your program      ]
;; [     continue.                                                             ]
;; [ SHOW-PHASE (phase-literal): Display one line of text indicating what      ]
;; [     the program is doing.  Every time you call this function, the         ]
;; [     previous phase gets put into a history display above the current.     ]
;; [ SHOW-PROGRESS: (total-to-do amount-done): This function modifies the      ]
;; [     progress bar with a fraction calculated as the amount done divided    ]
;; [     by the total that must be done.  Usually these are record counts,     ]
;; [     as in 500 records processed out of a total of 20000.                  ]
;; [     That would look like this: STATUS-BAR/SHOW-PROGRESS 20000 500         ]
;; [     It is your job to keep track of those numbers.                        ]
;; [ RESET-PROGRESS: Reset the progress bar to zero.  This function exists     ]
;; [     in case you want to show several progress bars, one after another.    ]
;; [ CLOSE-STATUS-WINDOW: This just executes the unview function to make       ]
;; [     the status window disappear.                                          ]
;; [---------------------------------------------------------------------------]

STATUS-BOX: context [
    MAIN-WINDOW: layout [
        MAIN-BANNER: banner "Program status"
        MAIN-HISTORY: text 200x50 wrap
        label 200 "Current phase:"
        MAIN-PHASE: info 200
        label 200 "Progress on this phase"
        MAIN-PROGRESS: progress 200
;;;;    button "Cancel" [alert "Operation canceled" quit]  ;;; Does not work. 
    ]
    SHOW-STATUS-WINDOW: does [
        view/new center-face MAIN-WINDOW
    ]
    SHOW-PHASE: func [
        PHASE
    ] [
        append MAIN-HISTORY/TEXT rejoin [
            MAIN-PHASE/text
            newline
        ] 
        MAIN-HISTORY/line-list: none
        MAIN-HISTORY/para/scroll/y: negate
            (max 0 (second size-text MAIN-HISTORY) - (MAIN-HISTORY/size/y))
        show MAIN-HISTORY
        MAIN-PHASE/text: copy PHASE
        show MAIN-PHASE
    ]
    SHOW-PROGRESS: func [
        FULL-SIZE
        AMOUNT-DONE
    ] [
        set-face MAIN-PROGRESS (AMOUNT-DONE / FULL-SIZE)
    ]
    RESET-PROGRESS: does [
        set-face MAIN-PROGRESS 0
    ]
    CLOSE-STATUS-WINDOW: does [
        unview
    ]
]

;; Uncomment to test
;STATUS-BOX/SHOW-STATUS-WINDOW
;wait 2
;STATUS-BOX/SHOW-PHASE "Initializing"
;wait 2
;STATUS-BOX/SHOW-PHASE "Phase 1"
;wait 2
;STATUS-BOX/SHOW-PHASE "Extracting data"
;CNT: 0
;TOT: 100
;loop 100 [CNT: CNT + 1 STATUS-BOX/SHOW-PROGRESS TOT CNT wait 0.1]
;wait 2
;STATUS-BOX/SHOW-PHASE "Processing data"
;STATUS-BOX/RESET-PROGRESS
;CNT: 0
;TOT: 100
;loop 100 [CNT: CNT + 1 STATUS-BOX/SHOW-PROGRESS TOT CNT wait 0.1]
;wait 2
;STATUS-BOX/SHOW-PHASE "Finishing" 
;wait 3
;STATUS-BOX/CLOSE-STATUS-WINDOW 

