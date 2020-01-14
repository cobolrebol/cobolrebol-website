REBOL [
    Title: "Basic Help Displayer"
    Purpose: {Based on a file name and a topic name passed in a text file,
    load the specified file and display the specified topic, using a window
    that contains a list of all help topics for further browsing.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a program that displays an index and a topic from a primitive     ]
;; [ text-based help file.                                                     ]
;; [ The help file would look like this:                                       ]
;; [     "topic one"                                                           ]
;; [     {Multi-line help text in braces}                                      ]
;; [     "topic two"                                                           ]
;; [     {More multi-line help text in braces}                                 ]
;; [     ... and so on                                                         ]
;; [ The program loads this file entirely into memory and displays a           ]
;; [ window that contains a pickable-list of all topics and the contents       ]
;; [ of one topic.                                                             ]
;; [ This program is launched from some other program, by means of a           ]
;; [ function in the BHLlauncher.r module.  It obtains the name of the         ]
;; [ help file plus an initial topic to display from a text file.              ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ General functions for loading and scrolling any text block.               ]
;; [---------------------------------------------------------------------------]

;;  -- Scroll the text in response to the scroller.
SCRLTXTV-SCROLL: func [TXT BAR] [
    TXT/para/scroll/y: negate BAR/data *
        (max 0 TXT/user-data - TXT/size/y)
    show TXT
]

;;  -- Load the text face with text passed to us in TDATA.
SCRLTXTV-LOAD: func [TXT BAR TDATA] [
    TXT/text: TDATA
    TXT/para/scroll/y: 0
    TXT/line-list: none
    TXT/user-data: second size-text TXT
    BAR/data: 0
    BAR/redrag TXT/size/y / TXT/user-data
;;  show [TXT BAR] ;; Caller must do this, for better generality.
]

;; [---------------------------------------------------------------------------]
;; [ End of text scrolling functions.                                          ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Get the help file name and the initial topic name from the caller,        ]
;; [ by means of a text file.                                                  ]
;; [ Load the help text.                                                       ]
;; [ Make a sorted list of all topics for the text-list in the window.         ]
;; [ Obtain the text of the initial topic.                                     ]
;; [---------------------------------------------------------------------------]

COMMFILE: %BHL-communication-file.txt
COMMLINE: load COMMFILE
HELPFILE: first COMMLINE
HELPTOPIC: second COMMLINE
HELPTEXT: load HELPFILE

TOPICLIST: copy []
foreach [TOPIC TEXT] HELPTEXT [
    append TOPICLIST TOPIC
]
sort TOPICLIST

CURRENTTOPIC: select HELPTEXT HELPTOPIC
if not CURRENTTOPIC [
    alert "No help available." 
    quit
]

;; [---------------------------------------------------------------------------]
;; [ Function that responds to a selection from the topic list, in case the    ]
;; [ operator leaves the help window open and browses topics.                  ]
;; [---------------------------------------------------------------------------]

SWITCH-TOPIC: does [
    HELPTOPIC: MAIN-LIST/picked
    CURRENTTOPIC: select HELPTEXT HELPTOPIC
    if not CURRENTTOPIC [
        alert "No help available." 
        exit
    ]
    SCRLTXTV-LOAD MAIN-HELP-TXT MAIN-HELP-SCR CURRENTTOPIC
    show [MAIN-HELP-TXT MAIN-HELP-SCR]    
]

;; [---------------------------------------------------------------------------]
;; [ Main window.                                                              ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    MAIN-LIST: text-list 200x600 data TOPICLIST [SWITCH-TOPIC]
    MAIN-HELP-TXT: text 400x600
    MAIN-HELP-SCR: scroller 20x600 [SCRLTXTV-SCROLL MAIN-HELP-TXT MAIN-HELP-SCR]
    return
    button "Close" [quit]
]

;; -- Load the initial topic before we show the window for the first time.
SCRLTXTV-LOAD MAIN-HELP-TXT MAIN-HELP-SCR CURRENTTOPIC

view MAIN-WINDOW 


