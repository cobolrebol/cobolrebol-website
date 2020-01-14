REBOL [
    Title: "Wav Demo Assistant"
]

;; [---------------------------------------------------------------------------]
;; [ This is a helper program for quickly running through a list of wav files  ]
;; [ to see what they sound like.  It asks for a folder name, finds all the    ]
;; [ wav file in it, displays a list, and then plays each when clicked.        ]
;; [ This operation also is done easily with a file manager and a music        ]
;; [ player, but this is a little faster if your goal is just to check some    ]
;; [ files to see what they sound like.  This is not a replacement for a       ]
;; [ general music player.                                                     ]
;; [---------------------------------------------------------------------------]

;;  -- Function to check if we have a wav file, based on file name.
SOUND-FILE?: func ["Returns true if file is a wav file" file] [
    find [%.wav %.WAV] find/last file "."
]

;;  -- Function to play a sound.
;;  -- The sound port is opened before the first call to this
;;  -- function, and it appears that we must close the port before
;;  -- opening it again.  Why do we close it at the end of this
;;  -- function and then close it again the next time the function
;;  -- is called.  At this time I do not know.  This works, thanks
;;  -- to the helpful REBOL community. 
SOUND-LAUNCH: does [
    close SOUND-PORT
    OPEN SOUND-PORT
    wait 0
    insert SOUND-PORT load to-file SOUND-LIST/picked
    wait SOUND-PORT
    close SOUND-PORT
]

;;  -- Get folder name, go there, find all files, filter out wav files.
if not SOUNDS-DIR: request-dir [
    alert "No folder selected"
    quit
]
change-dir SOUNDS-DIR
SOUND-NAMES: []
SOUND-NAMES: read %.

while [not tail? SOUND-NAMES] [
    either SOUND-FILE? first SOUND-NAMES 
        [SOUND-NAMES: next SOUND-NAMES]
        [remove SOUND-NAMES]
]
SOUND-NAMES: head SOUND-NAMES
if empty? SOUND-NAMES [
    alert "No wav found" 
    quit
]

;;  -- It seems that we must open a sound port in this manner
;;  -- before we can play anything.  
;;  -- By the way, SOUND-PORT is not a reseverd word.  It is just
;;  -- a word we made up for the sound port.
SOUND-PORT: open sound://

;;  -- Build and view main window. 
MAIN-WINDOW: layout [
    across
    banner "Wav Demo Assistant" font [shadow: none]
    return 
    SOUND-LIST: text-list 300x700 data (SOUND-NAMES)
        [SOUND-LAUNCH]
    return
    button "Quit" [quit] 
]
view MAIN-WINDOW

