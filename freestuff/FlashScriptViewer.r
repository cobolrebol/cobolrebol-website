REBOL [
    Title: "Flash script viewer"
    Purpose: {Get a list of text files in a selected directory, 
    and then show them in a window with buttons to go from one
    to another.}
]

;; [---------------------------------------------------------------------------]
;; [ This program was written originally for a project of cleaning up some     ]
;; [ old SQL scripts.  It provides that ability to flip through a list of      ]
;; [ scripts to view them, and a button to insert a block of comments at       ]
;; [ the front and then save the script with those added comments.             ]
;; [ It also provides a button to delete a script of a quick viewing indicates ]
;; [ that the script need not be saved.                                        ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ We work on one folder of scripts.  Ask for that folder.                   ]
;; [---------------------------------------------------------------------------]

;DEFAULT-DIR: %/C/
if not DEFAULT-DIR: request-dir [
    alert "No folder requested."
    quit
]
change-dir DEFAULT-DIR

;; [---------------------------------------------------------------------------]
;; [ This is a skeleton comment block that we can attach to the front of       ]
;; [ a script and then fill in.  Note that the comments are in a format        ]
;; [ that REBOL can load.  We could use that in an indexing program if         ]
;; [ we wanted to.                                                             ]
;; [---------------------------------------------------------------------------]

COMMENT-HEADER: rejoin [
{/*
AUTHOR: ""
DATE-WRITTEN: 01-JAN-1900
DATABASE: ""
SEARCH-WORDS: []
REMARKS: } 
"{" newline "}" newline "*/" newline
]

;; [---------------------------------------------------------------------------]
;; [ This is a function we can use to get a true-false answer to the question  ]
;; [ of whether or not a particular file is a kind of file we might want to    ]
;; [ view.                                                                     ]
;; [---------------------------------------------------------------------------]
    
SCRIPT-FILE?: func ["Returns true if file is an script" file] [
    find [%.sql %.SQL %.py %.PY %.r %.txt %.TXT] find/last file "."
]

;; [---------------------------------------------------------------------------]
;; [ This function builds a list of script files in the current directory.     ]
;; [ We have this operation in a function because we could want to use it      ]
;; [ more than once, because we have a button that will refresh the list       ]
;; [ of scripts.  We might want to refresh the list after we have deleted      ]
;; [ some.                                                                     ]
;; [---------------------------------------------------------------------------]

BUILD-FILE-LIST: does [
    FILES: copy []
    FILES: read %.
    while [not tail? FILES] [
        either SCRIPT-FILE? first FILES [FILES: next FILES][remove FILES]
    ]
    FILES: head FILES
    if empty? FILES [
        inform layout [backdrop 140.0.0 text bold "No scripts found"]
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
;; [ This function is execured for the "Debug" button.                         ]
;; [ It halts the script at a command prompt so we can use the "probe"         ]
;; [ command to investigate problems.  The "do-events" command can reactivate  ]
;; [ the window.                                                               ]
;; [---------------------------------------------------------------------------]

DEBUG-BUTTON: does [
    halt
]

;; [---------------------------------------------------------------------------]
;; [ This function is executed when a file name is selecte from the list       ]
;; [ of file names. It reads the selecte file and displays it in the text      ]
;; [ area.                                                                     ]
;; [---------------------------------------------------------------------------] 

CURRENT-FILE: none
FILE-TEXT: ""
FILE-LINECOUNT: 0
NEW-TEXT: ""
SHOW-SCRIPT: does [
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
;; [ This function is executed for the "Comment" button.                       ]
;; [ It adds a comment block to the current file and redisplays it.            ]
;; [---------------------------------------------------------------------------]

COMMENT-BUTTON: does [
    NEW-TEXT: copy ""
    NEW-TEXT: rejoin [
       COMMENT-HEADER
       FILE-TEXT
    ]
    MAIN-FILE/text: NEW-TEXT
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
;; [ This function is executed for the "Save" button.                          ]
;; [ It writes the current file back to disk.                                  ]
;; [---------------------------------------------------------------------------]

SAVE-BUTTON: does [
    NEW-TEXT: copy ""
    NEW-TEXT: MAIN-FILE/text
    write CURRENT-FILE NEW-TEXT
    FILE-TEXT: copy ""
    MAIN-FILE/text: FILE-TEXT
    MAIN-FILE/line-list: none
    show MAIN-FILE
]

;; [---------------------------------------------------------------------------]
;; [ This function is executed for the "Delete" button.                        ]
;; [ It deletes the current file and then blanks out the text window as a      ]
;; [ confirmation.                                                             ]
;; [ On second thought, we will NOT blank out the text window.  This will      ]
;; [ give the operator a last chance to change his mind by using the "save"    ]
;; [ button.                                                                   ]
;; [---------------------------------------------------------------------------]

DELETE-BUTTON: does [
    CURRENT-FILE: to-file MAIN-LIST/picked
    if not exists? CURRENT-FILE [
        alert rejoin ["You deleted " to-string CURRENT-FILE]
        exit
    ]
    FILE-TEXT: copy ""
    delete CURRENT-FILE
;   MAIN-FILE/text: FILE-TEXT
;   MAIN-FILE/line-list: none
;   show MAIN-FILE    
;   CURRENT-FILE: none
    alert rejoin [
        to-string CURRENT-FILE 
        " deleted. Use 'save' button if you have changed your mind."
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

MAIN-WINDOW: layout [
    across
    MAIN-LIST: text-list 200x700 data FILES [SHOW-SCRIPT]
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
    button "Comment" [COMMENT-BUTTON]
    button "Save" [SAVE-BUTTON]
    button "Delete" red [DELETE-BUTTON]
    button "Refresh" [REFRESH-BUTTON]
]

view center-face MAIN-WINDOW

