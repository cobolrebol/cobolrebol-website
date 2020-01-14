REBOL [
    Title: "Fixed-format text file editor"
    Purpose: {Provide a tightly-controlled environment for editing
    a fixed-format text file, for someone with little text editor
    experience.}
]

;; [---------------------------------------------------------------------------]
;; [ The is a general program that can edit a fixed-format text file           ]
;; [ where different data fields are present at fixed positions.               ]
;; [ This was a common operation in the unit-record days of what was called    ]
;; [ "data processing" but is less common now.                                 ]
;; [ To provide generality, the program reads a specification file that        ]
;; [ contains the name of the file being edited plus a block of field names    ]
;; [ and positions, something like this:                                       ]
;; [     %testfile.txt [field-1 1x2 field-2 5x10...]                           ]
;; [ Note that the file name is a REBOL-style name.  The field block is        ]
;; [ repetitions of a field name and a pair, where the pair indicates the      ]
;; [ starting position of the field (x) and the length (y).                    ]
;; [ After the program reads the specifications, it will generate a data       ]
;; [ window to be run through the "layout" function.                           ]
;; [---------------------------------------------------------------------------]

;; #############################################################################
;; # The code below came from a self-contained module for working with
;; # fixed-format text files.  It was hard-coded into this program so that
;; # this program would be complete.
;; #############################################################################

;; [---------------------------------------------------------------------------]
;; [ This is a bunch of functions for working with a file of fixed-format      ]
;; [ text lines.  It was created originally as the base for a program to       ]
;; [ provide minimal, carefully controlled, editing of such a file by those    ]
;; [ not familiary with text editors.                                          ]
;; [ There will be procedures to open a file, read the next or previous        ]
;; [ record, delete a record, add a new record at the end, and save the        ]
;; [ file under its same name or a new name.                                   ]
;; [ This module is not an independent program.  It will be called by a        ]
;; [ controlling program.                                                      ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Items we will use in processing the file.                                 ]
;; [---------------------------------------------------------------------------]

FFTF-FILE-ID: none      ;; File name we will be working on
FFTF-FILE-ID-SAVE: none ;; File name for save-as operation
FFTF-FIELDS: none       ;; Field names and locations in a record
FFTF-DATA: []           ;; Whole file in memory as a block of lines
FFTF-RECORD: ""         ;; One line of the file, the one we are working with
FFTF-RECNO: 0           ;; Index of the record we are positioned at
FFTF-FILE-SIZE: 0       ;; Number of lines in DATA
FFTF-EOF: false         ;; Set to true if we try to read past end
FFTF-FOUND: false       ;; Returned when searching

;; [---------------------------------------------------------------------------]
;; [ Open an existing file.                                                    ]
;; [ This function requires two items.  The first is the name of the file.     ]
;; [ The second is a block.  The block will contain repetitions of a word      ]
;; [ and a pair.  The word will the the name of a field in the fixed-format    ]
;; [ record.  The pair will the the one-relative starting position of the      ]
;; [ field (x) and the length of the field (y).                                ]
;; [ The "open" function will bring the whole file into memory and set up      ]
;; [ various pointers and such for working with the lines in the file.         ]
;; [---------------------------------------------------------------------------]

FFTF-OPEN-INPUT: func [
    FILEID [file!]
    FIELDLIST [block!]
] [
;;  -- Save what was passed to us.
    FFTF-FILE-ID: FILEID
    FFTF-FIELDS: FIELDLIST
;;  -- Read the entire file into memory.  Set various working items.
    FFTF-DATA: copy []
    FFTF-DATA: read/lines FFTF-FILE-ID
    FFTF-FILE-SIZE: length? FFTF-DATA
    FFTF-RECNO: 0
    FFTF-EOF: false
]

;; [---------------------------------------------------------------------------]
;; [ Read a record indicated by FFTF-RECNO.                                    ]
;; [ "Read" means to copy the specified line into the record area and then     ]
;; [ use the field list to set the words in the field list to the data         ]
;; [ indicated by the position-length pair.                                    ]
;; [---------------------------------------------------------------------------]

FFTF-READ-SPECIFIC: does [
    FFTF-EOF: false
    FFTF-RECORD: pick FFTF-DATA FFTF-RECNO
    foreach [FIELDNAME POSITION] FFTF-FIELDS [
        FFTF-RECORD: head FFTF-RECORD
        FFTF-RECORD: skip FFTF-RECORD (POSITION/x - 1)
        set FIELDNAME copy/part FFTF-RECORD POSITION/y
    ]
]

;; [---------------------------------------------------------------------------]
;; [ To read the first/next/previous/last record, we will just adjust the      ]
;; [ RECNO and use the above READ-SPECIFIC function.                           ]
;; [ Notice that we don't let RECNO get out of bounds, just in case we         ]
;; [ misuse these procedures and try to read out of bounds.                    ]
;; [---------------------------------------------------------------------------]

FFTF-READ-FIRST: does [
    FFTF-RECNO: 1
    either (FFTF-RECNO > FFTF-FILE-SIZE) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-NEXT: does [
    FFTF-RECNO: FFTF-RECNO + 1
    either (FFTF-RECNO > FFTF-FILE-SIZE) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-PREV: does [
    FFTF-RECNO: FFTF-RECNO - 1
    either (FFTF-RECNO < 1) [
        FFTF-RECNO: 1
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

FFTF-READ-LAST: does [
    FFTF-RECNO: FFTF-FILE-SIZE
    either (FFTF-RECNO < 1) [
        FFTF-RECNO: FFTF-FILE-SIZE
        FFTF-EOF: true
        return FFTF-EOF
    ] [
        FFTF-READ-SPECIFIC
        return FFTF-EOF
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Operations for saving the data or making a new file.                      ]
;; [---------------------------------------------------------------------------]

FFTF-SAVE-FILE: does [
    write/lines FFTF-FILE-ID FFTF-DATA
]

FFTF-SAVE-FILE-AS: does [
    FFTF-FILE-ID-SAVE: request-file/only/save
    either FFTF-FILE-ID-SAVE [
        write/lines FFTF-FILE-ID-SAVE FFTF-DATA
    ] [
        alert "No save-as ID requested"
    ]
]

;; [---------------------------------------------------------------------------]
;; [ We are going to have to be able to delete records, and also to update     ]
;; [ them if the values of the fields are changed by some calling program.     ]
;; [---------------------------------------------------------------------------]

;;  -- Build a record using current values of the field names.
FFTF-BUILD-RECORD: does [
    FFTF-RECORD: copy ""
    loop 1024 [append FFTF-RECORD " "]
    foreach [FIELDNAME POSITION] FFTF-FIELDS [
        FFTF-RECORD: head FFTF-RECORD
        FFTF-RECORD: skip FFTF-RECORD (POSITION/x - 1)
        change/part FFTF-RECORD (get FIELDNAME) POSITION/y
    ]    
    FFTF-RECORD: head FFTF-RECORD
    FFTF-RECORD: trim/tail FFTF-RECORD
]

;;  -- Delete the line pointed to by RECNO.
FFTF-DELETE-RECORD: does [
    remove at FFTF-DATA FFTF-RECNO
    FFTF-FILE-SIZE: FFTF-FILE-SIZE - 1
]

;;  -- Add a new record at the end of the file.
FFTF-ADD-RECORD: does [
    FFTF-BUILD-RECORD
    append FFTF-DATA FFTF-RECORD
    FFTF-FILE-SIZE: FFTF-FILE-SIZE + 1 
] 

;;  -- Change the record pointed to by RECNO using the field name values.
FFTF-CHANGE-RECORD: does [
    FFTF-BUILD-RECORD
    poke FFTF-DATA FFTF-RECNO FFTF-RECORD
]

;;  -- Search for the record where the value of a given word is equal
;;  -- to a given value.  Return true or false.
FFTF-SEARCH: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-FIRST
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-NEXT
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;;  -- Search ahead from where we are.
FFTF-SEARCH-NEXT: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-NEXT
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-NEXT
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;;  -- Search backwards from where we are.
FFTF-SEARCH-PREV: func [
    SEARCH-WORD
    SEARCH-VALUE
] [
    FFTF-READ-PREV
    until [
        if equal? SEARCH-VALUE (get SEARCH-WORD) [
            FFTF-FOUND: true
            return FFTF-FOUND
        ]
        FFTF-READ-PREV
    ]
    FFTF-FOUND: false
    return FFTF-FOUND
]

;; #############################################################################
;; # End of fixed-format file module.
;; #############################################################################

;; [---------------------------------------------------------------------------]
;; [ Get the name of the specification file and load it.                       ]
;; [ Pass its contents to the FFTF module and load the data.                   ]
;; [---------------------------------------------------------------------------]

if not SPEC-FILE: request-file/only [
    alert "No specification file selected"
    quit
]
SPEC-DATA: load SPEC-FILE
FFTF-OPEN-INPUT first SPEC-DATA second SPEC-DATA

;; [---------------------------------------------------------------------------]
;; [ Use the field name list to generate some REBOL code.                      ]
;; [ We will need blocks of code to:                                           ]
;; [ 1.  Generate the data entry window pane.                                  ]
;; [ 2.  Load all the fields to the entry window.                              ]
;; [ 3.  Move the entry fields back to the data fields.                        ]
;; [---------------------------------------------------------------------------]

LAYOUT-CODE: copy ""
LOAD-WINDOW-CODE: copy ""
STORE-DATA-CODE: copy ""
UPDATE-FORM: none    
LOAD-WINDOW-BLOCK: copy []
STORE-DATA-BLOCK: []

append LAYOUT-CODE rejoin [
    "across"
    newline
]

foreach [FIELDNAME POSITION] FFTF-FIELDS [

;; -- Generate a field on the layout
    append LAYOUT-CODE rejoin [
        {label 100 "} FIELDNAME {" } 
        {label 50 "} to-string POSITION {" }
        "WIN-" FIELDNAME ": "
        "field 400 font [name: font-fixed style: 'bold]"
        "return"
        newline
    ]

    append STORE-DATA-CODE rejoin [
        FIELDNAME ":"
        " copy "
        "WIN-" FIELDNAME "/text"
        newline
    ]

    append LOAD-WINDOW-CODE rejoin [
        "set-face "
        "WIN-" FIELDNAME " "
        FIELDNAME
        newline
    ]
]

;; Uncomment to test
;write %debug-layout.txt LAYOUT-CODE
;write %debug-store.txt STORE-DATA-CODE
;write %debug-load.txt LOAD-WINDOW-CODE
;halt

UPDATE-FORM: layout/tight load LAYOUT-CODE
LOAD-WINDOW-BLOCK: load LOAD-WINDOW-CODE
STORE-DATA-BLOCK: load STORE-DATA-CODE

;; [---------------------------------------------------------------------------]
;; [ The box of update fields could end up longer than the box set up to       ]
;; [ hold them.  The scroller will allow us to scroll the update fields.       ]
;; [---------------------------------------------------------------------------]

SCROLL-FORM: does [
    NEW-OFFSET: negate MAIN-UPDATE-SCROLLER/data * 
        (max 0 (MAIN-UPDATE-FORM/pane/size/y - MAIN-UPDATE-FORM/size/y))
    MAIN-UPDATE-FORM/pane/offset/y: NEW-OFFSET
    show MAIN-UPDATE-FORM
]

;; [---------------------------------------------------------------------------]
;; [ This function updates the loaded file with the date in the fields         ]
;; [ on the update window.                                                     ]
;; [---------------------------------------------------------------------------]

UPDATE-DATA: does [
    do STORE-DATA-BLOCK
    FFTF-CHANGE-RECORD
    alert "Data stored." 
]

;; [---------------------------------------------------------------------------]
;; [ Navigation buttons.                                                       ]
;; [---------------------------------------------------------------------------]

NEXT-BUTTON: does [
    FFTF-READ-NEXT
    either FFTF-EOF [
        alert "At end."
    ] [
        do LOAD-WINDOW-BLOCK
        set-face MAIN-LINE to-string FFTF-RECNO
    ]
]

PREV-BUTTON: does [
    FFTF-READ-PREV
    either FFTF-EOF [
        alert "At beginning."
    ] [
        do LOAD-WINDOW-BLOCK
        set-face MAIN-LINE to-string FFTF-RECNO
    ]
]

FIRST-BUTTON: does [
    FFTF-READ-FIRST
    do LOAD-WINDOW-BLOCK
    set-face MAIN-LINE to-string FFTF-RECNO
]

LAST-BUTTON: does [
    FFTF-READ-LAST
    do LOAD-WINDOW-BLOCK
    set-face MAIN-LINE to-string FFTF-RECNO
]

;; [---------------------------------------------------------------------------]
;; [ Search buttons.                                                           ]
;; [---------------------------------------------------------------------------]

SEARCH-WORD: none
SEARCH-VALUE: none

SEARCH-BUTTON: does [
    if not MAIN-SEARCH-ITEMS/text [
        alert "No search column selected."
        exit
    ]
    SEARCH-WORD: to-word get-face MAIN-SEARCH-ITEMS
    SEARCH-VALUE: get-face MAIN-SEARCH-VALUE
    either FFTF-SEARCH SEARCH-WORD SEARCH-VALUE [
        do LOAD-WINDOW-BLOCK
        set-face MAIN-LINE to-string FFTF-RECNO
    ] [
        alert "Not found."
    ]
]

SEARCH-AHEAD-BUTTON: does [
    if not MAIN-SEARCH-ITEMS/text [
        alert "No search column selected."
        exit
    ]
    SEARCH-WORD: to-word get-face MAIN-SEARCH-ITEMS
    SEARCH-VALUE: get-face MAIN-SEARCH-VALUE
    either FFTF-SEARCH-NEXT SEARCH-WORD SEARCH-VALUE [
        do LOAD-WINDOW-BLOCK
        set-face MAIN-LINE to-string FFTF-RECNO
    ] [
        alert "Not found."
    ]
]

SEARCH-BACK-BUTTON: does [
    if not MAIN-SEARCH-ITEMS/text [
        alert "No search column selected."
        exit
    ]
    SEARCH-WORD: to-word get-face MAIN-SEARCH-ITEMS
    SEARCH-VALUE: get-face MAIN-SEARCH-VALUE
    either FFTF-SEARCH-PREV SEARCH-WORD SEARCH-VALUE [
        do LOAD-WINDOW-BLOCK
        set-face MAIN-LINE to-string FFTF-RECNO
    ] [
        alert "Not found."
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Options to add and delete lines.                                          ]
;; [---------------------------------------------------------------------------]

DELETE-LINE: does [
    FFTF-DELETE-RECORD
    FFTF-READ-SPECIFIC ;; Whatever RECNO points to...
    do LOAD-WINDOW-BLOCK
    alert "Line deleted."
]

ADD-LINE: does [
    do STORE-DATA-BLOCK
    FFTF-ADD-RECORD
    FFTF-READ-LAST
    do LOAD-WINDOW-BLOCK
    set-face MAIN-LINE to-string FFTF-RECNO
    alert "Line added at end."
]

;; [---------------------------------------------------------------------------]
;; [ Save options.  Overwrite current file (bad) or save as new file (good).   ]
;; [---------------------------------------------------------------------------]

SAVE-FILE: does [
    FFTF-SAVE-FILE
    alert "File saved."
]

SAVE-FILE-AS: does [
    FFTF-SAVE-FILE-AS
    if FFTF-FILE-ID-SAVE [
        alert rejoin [
            "Data saved in "
            FFTF-FILE-ID-SAVE
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ The main window.                                                          ]
;; [ The data entry area was generated above from the field list.              ]
;; [ It will be put into the "pane" of the data entry area.                    ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    banner "Fixed-format file editor"
    return
    MAIN-UPDATE-FORM: box 600x300
    MAIN-UPDATE-SCROLLER: scroller 20x300 [SCROLL-FORM] 
    return
    label "Editing file: "
    MAIN-FID: info 400
    label "at line"
    MAIN-LINE: info 50
    return
    button 600 "Update the current record with the above data" [UPDATE-DATA]
    return
    box 624x4 red
    return
    button "Next" [NEXT-BUTTON]
    button "Prev" [PREV-BUTTON]
    button "First" [FIRST-BUTTON]
    button "Last" [LAST-BUTTON]
    return
    text 80 "Search" font [size: 14 style 'bold] 
    MAIN-SEARCH-ITEMS: drop-down 200 data (extract FFTF-FIELDS 2) 
    text 40 "for" font [size: 14 style 'bold']
    MAIN-SEARCH-VALUE: field 300
    return
    button 150 "Search" [SEARCH-BUTTON]
    button 150 "Search ahead" [SEARCH-AHEAD-BUTTON]
    button 150 "Search back" [SEARCH-BACK-BUTTON]     
    return
    button 300 orange "Delete the one line currently showing" [DELETE-LINE]
    button 300 "Make new line at end using data shown in form" [ADD-LINE]
    return 
    button 300 red "Write updated data over current file" [SAVE-FILE]
    button 300 "Save updated data to a new file" [SAVE-FILE-AS]
    return
    button "Quit" [quit]
    button "Debug" [halt] 
]

;; [---------------------------------------------------------------------------]
;; [ Before we can display the main window, we have to plug in the update      ]
;; [ form that we generated from the field list.                               ]
;; [---------------------------------------------------------------------------]

MAIN-UPDATE-FORM/pane: UPDATE-FORM
FFTF-READ-FIRST
do LOAD-WINDOW-BLOCK
set-face MAIN-FID to-string FFTF-FILE-ID
set-face MAIN-LINE to-string FFTF-RECNO

;; [---------------------------------------------------------------------------]
;; [ Now display the main window and respond to its controls.                  ]
;; [---------------------------------------------------------------------------]

view center-face MAIN-WINDOW


