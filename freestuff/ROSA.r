REBOL [
    Title: "Run One Script Assistant"
]

;;  -- Hard-code your own default folder. 
PROGRAMS-DIR: %.

PROGRAM-FILE?: func ["Returns true if file is an REBOL program" file] [
    find [%.r] find/last file "."
]

;;  -- Go to the folder, get all file names, filter out REBOL scripts.
change-dir PROGRAMS-DIR
PROGRAM-NAMES: []
PROGRAM-NAMES: read %.

while [not tail? PROGRAM-NAMES] [
    either PROGRAM-FILE? first PROGRAM-NAMES 
        [PROGRAM-NAMES: next PROGRAM-NAMES]
        [remove PROGRAM-NAMES]
]
PROGRAM-NAMES: head PROGRAM-NAMES
if empty? PROGRAM-NAMES [
    alert "No programs found" 
    quit
]

;;  -- Called when a program is picked from the list.
LAUNCH-PROGRAM: does [
    launch to-file PROGRAM-LIST/picked
]

MAIN-WINDOW: layout [
    across
    banner "Run One Script Assistant" font [shadow: none]
    return 
    PROGRAM-LIST: text-list 300x700 data (PROGRAM-NAMES)
        [LAUNCH-PROGRAM]
    return
    button "Quit" [quit] 
]

view MAIN-WINDOW
 
