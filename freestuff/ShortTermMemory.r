REBOL [
    Title: "Short term memory"
    Purpose: {Another attempt to stop using paper for the last holdout
    use, which is jotting things on a notebook that I might have to
    remember for just a short time.  Notes are kept in a text file
    that can be formatted by the makedoc program.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a personal program that replaces the clutter of little pieces     ]
;; [ of paper that used to inhabit my desk.  It is just another attempt to     ]
;; [ "go paperless."  The program was written for a certain environment,       ]
;; [ so you will have to look it over and modify the various file names and    ]
;; [ folder names for your own environment.                                    ]
;; [---------------------------------------------------------------------------]

PRINT-HEADER: {Short-term memory

    This is a printout of the contents of the short-term memory file.

}

FILE-ID: %ShortTermMemory.txt
PRINT-ID: %ShortTermMemoryPrintable.txt 
if not exists? FILE-ID [
    write FILE-ID rejoin [
        "==="
        now
        " Short-term memory file created."
        newline
    ]
]

WORK-TEXT: ""
TEXT-SAVED: true

REFRESH-WORK: does [
    WORK-TEXT: copy ""
    WORK-TEXT: read FILE-ID
    TEXT-SAVED: true
]

RELOAD-TEXT: does [
    MAIN-TEXT/text: WORK-TEXT
    MAIN-TEXT/line-list: none
    MAIN-TEXT/para/scroll/y: 0
    MAIN-TEXT/user-data: second size-text MAIN-TEXT
    MAIN-SCROLLER/data: 0
    MAIN-SCROLLER/redrag MAIN-TEXT/size/y / MAIN-TEXT/user-data 
    show [MAIN-TEXT MAIN-SCROLLER]   
]

SAVE-PRINTABLE: does [
    write PRINT-ID rejoin [
        PRINT-HEADER
        WORK-TEXT
    ]
]

SAVE-TEXT: does [
    WORK-TEXT: copy ""
    WORK-TEXT: get-face MAIN-TEXT
    write FILE-ID WORK-TEXT
    TEXT-SAVED: true
    SAVE-PRINTABLE
]

QUIT-BUTTON: does [
    if not TEXT-SAVED [
        GO?: alert [
            "Save short-term memory?"
            "Save"
            "Discard"
        ]
        if GO? [
            SAVE-TEXT
        ]
    ]
    quit 
]

NEW-BUTTON: does [
    insert WORK-TEXT rejoin [
        "===Note on "
        now
        newline
        newline
        newline
    ]
    TEXT-SAVED: false
    RELOAD-TEXT
]

SAVE-BUTTON: does [
    SAVE-TEXT 
    alert "Saved." 
]

DISCARD-BUTTON: does [
    REFRESH-WORK
    RELOAD-TEXT
]

REFRESH-WORK ;; before layout so the text gets displayed 

MAIN-WINDOW: layout [
    across
    banner "Short-term memory"
    return
    MAIN-TEXT: area 550x800 WORK-TEXT wrap 
        font [size: 14 style: 'bold]
    MAIN-SCROLLER: scroller 20x800 
        [scroll-para MAIN-TEXT MAIN-SCROLLER]
    return
    button "Quit" [QUIT-BUTTON]
    button "New" [NEW-BUTTON]
    button "Save" [SAVE-BUTTON] 
    button "Discard" [DISCARD-BUTTON]
    button "Paper" ;; open a folder where we keep scanned paper stuff. 
        [call {%windir%\explorer.exe "I:\ShortTermMemory\ScannedPaper\"}]
;;  -- Interesting note.  If I put the above 'call' into a function and
;;  -- then call that function, this does not work.  
]

view MAIN-WINDOW

