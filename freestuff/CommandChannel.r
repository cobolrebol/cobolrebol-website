REBOL [
    Title: "Command Channel GUI"
    Purpose: {FTP-based chat room with GUI front end,
    inspired by a similar program from Nick Antonaccio.}
]

;; [---------------------------------------------------------------------------]
;; [ This is another basic ftp-based chat client but with a GUI front end.     ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Items to be configured for your specific site.                            ]
;; [---------------------------------------------------------------------------]

;CHATFILE: ftp://userid:password@ftp.yourftpsite/chat.txt
CHATFILE: %chat.txt              ;; Local name for testing and debugging 
CHATCODENAMES: [
    "Adam" blue
    "Brenda" red
    "Chris" green
]

;; [---------------------------------------------------------------------------]
;; [ Start by asking for a code name.                                          ]
;; [---------------------------------------------------------------------------]

CODE-NAME: request-text/title "Code in please."

;; [---------------------------------------------------------------------------]
;; [ The chat file is a text file, with some structure.                        ]
;; [ Each entry is a line, formatted as a REBOL block.                         ]
;; [ The block contains these items:                                           ]
;; [ 1.  Date-time stamp                                                       ]
;; [ 2.  Name of author, as a string                                           ]
;; [ 3.  Chat text, as a long string.                                          ]
;; [ The program shows a window with a text area for data entry.               ]
;; [ Above that is box with the prior chat entries, in a scrollable pane.      ]
;; [ The scrollable pane consists of variable-size text fields,                ]
;; [ each containing one chat entry.  How do we make variable-size texts?      ]
;; [ We estimate based on the size of the text.  The details could change,     ]
;; [ so you should examine the code.  In summary, we guess how many            ]
;; [ characters fit in a single line of X pixels, we guess how many Y pixels   ]
;; [ we need for one line, then we calculate how many lines the text will      ]
;; [ take on the screen.  The text box then will be X pixels wide, and the     ]
;; [ height will be the Y size of one line times the estimated number of       ]
;; [ lines.                                                                    ]
;; [---------------------------------------------------------------------------]

STORE-MESSAGE: func [
    CHAT-MSG
] [
    CHAT-BLOCK: copy ""
    append CHAT-BLOCK rejoin [
        "["
        now " "
        mold CODE-NAME " "
        mold CHAT-MSG " "
        "]" 
    ]
    write/append CHATFILE CHAT-BLOCK
]
STORE-MESSAGE "I am here" 

;; [---------------------------------------------------------------------------]
;; [ Data items for generating the layout of text entries.                     ]
;; [---------------------------------------------------------------------------]

WS-CHARS-PER-LINE: 72   ;; about 72 per 500 pixels
WS-LINE-HEIGHT: 18      ;; about 20 pixels high for a line
WS-LINES: 0             ;; how many lines will an entry take?
WS-BOX-X: 500           ;; X dimension of a chat entry box
WS-BOX-Y: 0             ;; Calculated Y dimenstion of chat entry box

;; [---------------------------------------------------------------------------]
;; [ This is a key function in the program.  It takes a line of text and       ]
;; [ returns a string which is the VID code for a text style that has the      ]
;; [ text as the text facet of the.  This function will be performed           ]
;; [ for each chat entry in the whole chat file, and then all that VID code    ]
;; [ will be run through the layout function and put into a scrolling face     ]
;; [ on the main window.                                                       ]
;; [---------------------------------------------------------------------------]

GEN-BOX-VID: func [
    CHAT-TEXT
] [
    BOX-VID: copy []
    WS-LINES: (length? CHAT-TEXT) / WS-CHARS-PER-LINE
	WS-BOX-Y: max (WS-LINES * WS-LINE-HEIGHT) WS-LINE-HEIGHT
	append BOX-VID compose [
            text (as-pair WS-BOX-X WS-BOX-Y) wrap (CHAT-TEXT)
            font [size: 12 color: black shadow: none style: 'bold]
	]
	return BOX-VID
]

;; [---------------------------------------------------------------------------]
;; [ Load the chat file to be sure we have the lastest version.                ]
;; [ Generate VID code for a text style for each chat entry.                   ]
;; [ Put them all together into a block of layout code.                        ]
;; [ Run the generated code through the layout function.                       ]
;; [ The generated layout will be put into the main window.                    ]
;; [---------------------------------------------------------------------------]

CHAT-ENTRIES: []
CHAT-LAYOUT-CODE: []
CHAT-LAYOUT: none
CHAT-COLOR: ""

GEN-CHAT-LAYOUT: does [
;;  Without load/all, program crashes if it started with an empty chat file.
    CHAT-ENTRIES: load/all CHATFILE
    CHAT-LAYOUT-CODE: copy [across space 0x0]
    foreach ENTRY CHAT-ENTRIES [
        if not CHAT-COLOR: select CHATCODENAMES ENTRY/2 [
            CHAT-COLOR: "black"
        ]
        append CHAT-LAYOUT-CODE compose/deep [
            text (as-pair 170 WS-LINE-HEIGHT) (to-string ENTRY/1)
            font [color: (CHAT-COLOR)]
            text (as-pair 100 WS-LINE-HEIGHT) (ENTRY/2)
            font [color: (CHAT-COLOR)]
            (GEN-BOX-VID ENTRY/3) return bar 770 return
        ]
    ]
    CHAT-LAYOUT: layout/tight CHAT-LAYOUT-CODE
]

;; [---------------------------------------------------------------------------]
;; [ Functions for the buttons on the window.                                  ]
;; [---------------------------------------------------------------------------]

REFRESH-CHAT: does [
    GEN-CHAT-LAYOUT
    MAIN-HISTORY/pane: CHAT-LAYOUT
;;  Start showing the pane far down enough so that the last entry
;;  is at the bottom of the box
    MAIN-HISTORY/pane/offset/y: min 0 (MAIN-HISTORY/size/y - MAIN-HISTORY/pane/size/y)
;;  Set the initial position of the scroller at the end, to match the
;;  text that is showing.
    MAIN-SCROLLER/data: 1
    show MAIN-HISTORY
    MAIN-ENTRY/text: copy ""
    MAIN-ENTRY/line-list: none
    show MAIN-ENTRY 
]

SEND-CHAT: does [
    STORE-MESSAGE trim MAIN-ENTRY/text
    REFRESH-CHAT
]

SCROLL-CHAT: does [
    NEW-OFFSET: negate MAIN-SCROLLER/DATA *
        (max 0 MAIN-HISTORY/pane/size/y - MAIN-HISTORY/size/y)
    MAIN-HISTORY/pane/offset/y: NEW-OFFSET
    show MAIN-HISTORY
]

;; [---------------------------------------------------------------------------]
;; [ Main window.                                                              ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    banner "Command channel"
    return
    MAIN-HISTORY: box 770x500 edge [size: 1x1]
    MAIN-SCROLLER: scroller 20x500 [SCROLL-CHAT]
    return
    label 270 "Type a message here and click the Send button"
    MAIN-ENTRY: area 500x100 wrap
    return
    button "Send" [SEND-CHAT]
    button "Refresh" [REFRESH-CHAT]
    button "Quit" [quit]   
    button "Debug" [halt]       
]

GEN-CHAT-LAYOUT
MAIN-HISTORY/pane: CHAT-LAYOUT 
MAIN-HISTORY/pane/offset/y: min 0 (MAIN-HISTORY/size/y - MAIN-HISTORY/pane/size/y)
MAIN-SCROLLER/data: 1
view MAIN-WINDOW



