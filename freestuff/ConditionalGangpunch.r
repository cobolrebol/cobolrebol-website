REBOL [
    Title: "Conditional gangpunch"
    Purpose: {Plug text into specific columns of a text file when
    a specified condition is true.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a simple program for performing a single simple operation with    ]
;; [ a little twist.  It reads a text file into memory and then gangpunches    ]
;; [ some specified data into specified columns.  It also provides             ]
;; [ for a condition under which the operation will be done.  The condition    ]
;; [ is specified by entering syntactically correct REBOL code.                ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These words could be first used when they are needed, but putting them    ]
;; [ here is a helpful reminder of what they are.                              ]
;; [---------------------------------------------------------------------------]

TEXT-FILEID: none       ;; Name of file we are fixing.
TEXT-DATA: copy []      ;; Data from the file, in lines.
TEXT-STRING: copy ""    ;; Data from the file, as a sting for showing.
TEXT-LOADED: false      ;; Indicator that a file is available for fixing.
SAVE-FILEID: none       ;; Name of the file for saving the fixed data.
POS: 0                  ;; Start position a line, for changing data.
POS-X: ""               ;; Raw column number.
LGH: 0                  ;; Length of data to change.
LGH-X: ""               ;; Raw field length.
DTA: ""                 ;; Data we will plug in at POS for LGH characters.
DTA-X: ""               ;; Raw data to be loaded.
MAXLGH: 0               ;; Size of first line, assuming all are the same.
CONDITION: ""           ;; Condition test from window.
TESTLINE:               ;; Work area for evaluating condition.
TESTRESULT:             ;; True or false after evaluating condtion. 

;; [---------------------------------------------------------------------------]
;; [ This function loads the display area on the main window and resets        ]
;; [ the scroller.  It is a function because it is called from more than       ]
;; [ one place.                                                                ]
;; [---------------------------------------------------------------------------]

LOAD-TEXT-DATA: does [
    MAIN-FILEDATA/text: TEXT-STRING
    MAIN-FILEDATA/para/scroll/y: 0
    MAIN-FILEDATA/line-list: none
    MAIN-FILEDATA/user-data: second size-text MAIN-FILEDATA
    MAIN-SCROLLER/data: 0
    MAIN-SCROLLER/redrag MAIN-FILEDATA/size/y / MAIN-FILEDATA/user-data
    show MAIN-FILEDATA
    show MAIN-SCROLLER 
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the button for loading the text file.           ]
;; [ It also displays the file name on the window for reference.               ]
;; [ It seems that there is an incompatibility between our need to have the    ]
;; [ text as lines so we can go through it a line at a time, and our need      ]
;; [ to have the text as a string so we can display it.  Since we are not      ]
;; [ so handy with REBOL, we will read the file as lines and then convert it   ]
;; [ to a displayable string, thus keeping two copies.  We will make changes   ]
;; [ to TEXT-DATA and display TEXT-STRING.  If we ever have to re-display      ]
;; [ after modifications, we will re-convert.                                  ]
;; [---------------------------------------------------------------------------]

LOAD-TEXT-FILE: does [
    if not TEXT-FILEID: request-file/only [
        alert "No file specified."
        TEXT-LOADED: false
        exit
    ]
;;  For modifying: 
    TEXT-DATA: copy ""
    TEXT-DATA: read/lines TEXT-FILEID

;;  For displaying:
    TEXT-STRING: copy ""
    foreach LINE TEXT-DATA [
        append TEXT-STRING rejoin [LINE newline]
    ]

    LOAD-TEXT-DATA
    MAIN-FILENAME/text: to-string TEXT-FILEID 
    show MAIN-FILENAME
    TEXT-LOADED: true
    MAXLGH: length? first TEXT-DATA  
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the scroller.                                   ]
;; [---------------------------------------------------------------------------]

SCROLL-TEXT: does [
    MAIN-FILEDATA/para/scroll/y: negate MAIN-SCROLLER/data *
        (max 0 MAIN-FILEDATA/user-data - MAIN-FILEDATA/size/y) 
    show MAIN-FILEDATA
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Save as" button.                           ]
;; [---------------------------------------------------------------------------]

SAVE-TEXT: does [
    if not SAVE-FILEID: request-file/only/save [
        alert "No file name specified."
        exit
    ]
    write/lines SAVE-FILEID TEXT-DATA
    alert "Modified data saved."
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Reshow" button.                            ]
;; [ The changed data is in TEXT-DATA.  Re-convert it to a string in           ]
;; [ TEXT-STRING, reload it into the display area, and reshow it.              ]
;; [---------------------------------------------------------------------------]

RESHOW: does [
    TEXT-STRING: copy ""
    foreach LINE TEXT-DATA [
        append TEXT-STRING rejoin [LINE newline]
    ]
    LOAD-TEXT-DATA
] 

;; [---------------------------------------------------------------------------]
;; [ This function does the actual job.                                        ]
;; [ We do have to check all the input items to make sure they are valid,      ]
;; [ or the program will crash.                                                ]
;; [---------------------------------------------------------------------------]

EXECUTE: does [
;; -- A file must have been loaded.
    if not TEXT-LOADED [
        alert "No file loaded."
        exit
    ]
;; -- Starting column must be specified.
    trim/all POS-X: get-face MAIN-START
    if equal? POS-X "" [
        alert "No starting position specified."
        exit
    ]
;; -- Starting column must be a number.
    if not attempt [POS: to-integer POS-X] [
        alert "Start column is not a number."
        exit
    ]
;; -- Field length must be specified.
    trim/all LGH-X: get-face MAIN-LENGTH
    if equal? LGH-X "" [
        alert "No field ength specified."
        exit
    ]
;; -- Field length must be a number.
    if not attempt [LGH: to-integer LGH-X] [
        alert "Field length is not a number."
        exit
    ]
;; -- Program will not crash if we "change" beyond the end, but check anyway.
    if greater? (POS + LGH) MAXLGH [
        alert "Length takes us off the end."
        exit
    ]
;; -- Data can be anything.
    DTA-X: get-face MAIN-NEWDATA
    DTA: attempt [load DTA-X]
    if not DTA [
        alert "Invalid data format."
        exit
    ]
;; -- Condition can be anything, but better be correct.   
    CONDITION: MAIN-CONDITION/text
;; -- Apply the operation to each line.
    foreach LINE TEXT-DATA [
        TESTLINE: copy LINE

;; -- What do we code in MAIN-CONDITION so we can evaluate it 
;; -- to true or false? We code what we would code after the
;; -- "if" function, but not word "if." For example:
;; -- equal? copy/part skip TESTLINE 22 1 "E"
;; -- Would test the one character at position 23 for the letter "E."
      
        either equal? CONDITION "" [
            TESTRESULT: true
        ] [
            either do load CONDITION [
                TESTRESULT: true
            ] [
                TESTRESULT: false
            ]
        ]

        if TESTRESULT [
            LINE: head LINE
            LINE: skip LINE (POS - 1)
            change/part LINE DTA LGH
        ]
    ]
;; -- To confirm, should we just alert, or should we refresh the data window?
;   alert "Done."
    RESHOW
]

;; [---------------------------------------------------------------------------]
;; [ Main window.                                                              ]
;; [ Interesting note:  We must use "wrap" on MAIN-FILEDATA or scrolling       ]
;; [ the text therein will also scroll the text on the buttons.  But, if we    ]
;; [ use "wrap" on text read from a file, the text will not show as lines.     ]
;; [ That is why we read the text file as lines (so we can edit lines) and     ]
;; [ then convert it to a string with line-feeds so it will display as lines   ]
;; [ in MAIN-FILEDATA.                                                         ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    banner "Conditional Gangpunch"
    return
    MAIN-FILEDATA: text 800x600 wrap black white font-name font-fixed
    MAIN-SCROLLER: scroller 20x600 [SCROLL-TEXT]
    return
    button 150 "Load text file" [LOAD-TEXT-FILE]
    MAIN-FILENAME: info 500
    return
    label "Start column"
    MAIN-START: field 40
    label "Field length"
    MAIN-LENGTH: field 40
    label "New data"
    MAIN-NEWDATA: field 200
    return
    label "Conditional code"
    MAIN-CONDITION: area 500x50
    return
    button "Execute" [EXECUTE]
    button "Reshow" [RESHOW]
    button "Save as" [SAVE-TEXT]
    button "Quit" [quit]
    button "Debug" [halt] 
]

;; [---------------------------------------------------------------------------]
;; [ Run the program.                                                          ]
;; [---------------------------------------------------------------------------]

view center-face main-window

