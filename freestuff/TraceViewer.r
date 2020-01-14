REBOL [
    Title: "Flash log viewer"
    Purpose: {Get a list of text files in a selected directory, 
    and then show them in a scrolling text area.}
]

;; [---------------------------------------------------------------------------]
;; [ It is a common practice to have a program log its activity in a text      ]
;; [ file for later debugging.  This is a simple program to obtain the names   ]
;; [ of all the text files in a given folder, display the names, the then      ]
;; [ display the contents of the file when the name is selected.               ]
;; [ The folder name is hard-coded because the expected use of this program    ]
;; [ would be to make a quick-viewer of all text files in a known location,    ]
;; [ and asking for the file location would be an extra step.                  ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ We work on one folder of scripts.  The folder name is hard-coded.         ]
;; [---------------------------------------------------------------------------]

DEFAULT-DIR: %/C/
change-dir DEFAULT-DIR

;; [---------------------------------------------------------------------------]
;; [ This is a function we can use to get a true-false answer to the question  ]
;; [ of whether or not a particular file is a kind of file we might want to    ]
;; [ view.                                                                     ]
;; [---------------------------------------------------------------------------]
    
LOG-FILE?: func ["Returns true if file is an script" file] [
    find [%.txt %.TXT] find/last file "."
]

;; [---------------------------------------------------------------------------]
;; [ This function builds a list of log files in the current directory.        ]
;; [ We have this operation in a function because we could want to use it      ]
;; [ more than once, because we have a button that will refresh the list       ]
;; [ of files.  We might want to refresh the list if a new file appears.       ]
;; [---------------------------------------------------------------------------]

BUILD-FILE-LIST: does [
    FILES: copy []
    FILES: read %.
    while [not tail? FILES] [
        either LOG-FILE? first FILES [FILES: next FILES][remove FILES]
    ]
    FILES: head FILES
    if empty? FILES [
        inform layout [backdrop 140.0.0 text bold "No trace files found"]
        quit  
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function is executed for the "Quit" button.                          ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This function is executed for the "Debug" button.                         ]
;; [ It halts the script at a command prompt so we can use the "probe"         ]
;; [ command to investigate problems.  The "do-events" command can reactivate  ]
;; [ the window.                                                               ]
;; [---------------------------------------------------------------------------]

DEBUG-BUTTON: does [
    halt
]

;; [---------------------------------------------------------------------------]
;; [ This function is executed when a file name is selected from the list      ]
;; [ of file names. It reads the selected file and displays it in the text     ]
;; [ area.                                                                     ]
;; [---------------------------------------------------------------------------] 

CURRENT-FILE: none
FILE-TEXT: ""
FILE-LINECOUNT: 0
NEW-TEXT: ""
SHOW-FILE: does [
    CURRENT-FILE: to-file MAIN-LIST/picked
    if not exists? CURRENT-FILE [
        alert rejoin ["You deleted " to-string CURRENT-FILE]
        exit
    ]
    FILE-TEXT: copy ""
    FILE-TEXT: read CURRENT-FILE
    MAIN-FILE/text: FILE-TEXT
    MAIN-FILE/line-list: none
    MAIN-FILE/para/scroll/y: 0
    MAIN-FILE/user-data: second size-text MAIN-FILE
    MAIN-SCROLLER/data: 0
    MAIN-SCROLLER/redrag MAIN-FILE/size/y / MAIN-FILE/user-data
    show MAIN-FILE
    show MAIN-SCROLLER
    MAIN-FILENAME/text: to-string CURRENT-FILE
    MAIN-CHARACTERS/text: to-string length? FILE-TEXT
    show MAIN-FILENAME
    show MAIN-CHARACTERS
    FILE-LINES: copy []
    FILE-LINES: read/lines CURRENT-FILE
    FILE-LINECOUNT: length? read/lines CURRENT-FILE
    MAIN-LINES/text: to-string FILE-LINECOUNT
    show MAIN-LINES 
]

;; [---------------------------------------------------------------------------]
;; [ This function is called whenever the scroller is moved.                   ]
;; [ The text area and the scroller are passed to this function.               ]
;; [---------------------------------------------------------------------------]

SCROLL-AREA: func [TXT BAR] [
;;  -- The program will crash if we try to scroll before data is present.
    if CURRENT-FILE [
        TXT/para/scroll/y: negate BAR/data *
            (max 0 TXT/user-data - TXT/size/y)
        show TXT
    ]
]    

;; [---------------------------------------------------------------------------]
;; [ This function is executed for the "Refresh" button.                       ]
;; [ It re-reads the list of file names in the current directory and           ]
;; [ rebuilds the file name list in the main window.                           ]
;; [---------------------------------------------------------------------------]

REFRESH-BUTTON: does [
    BUILD-FILE-LIST
    MAIN-LIST/data: FILES
    show MAIN-LIST
]

;; [---------------------------------------------------------------------------]
;; [ Begin.                                                                    ]
;; [ Build the list of files before we create the main window because          ]
;; [ that list of file names is the data for the list in the main window.      ]
;; [---------------------------------------------------------------------------]

BUILD-FILE-LIST

;; [---------------------------------------------------------------------------]
;; [ Build and display the main window.                                        ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    MAIN-LIST: text-list 300x700 data FILES [SHOW-FILE]
    MAIN-FILE: area 800x700 font [name: font-fixed]
    MAIN-SCROLLER: scroller 24x700 [SCROLL-AREA MAIN-FILE MAIN-SCROLLER] 
    return
    text "Current file: "
    MAIN-FILENAME: text 200 
    text "Lines: "
    MAIN-LINES: text 40
    text "Characters: "
    MAIN-CHARACTERS: text 40
    return
    button "Quit" [QUIT-BUTTON]
    button "Debug" [DEBUG-BUTTON]
    button "Refresh" [REFRESH-BUTTON]
]

view center-face MAIN-WINDOW

