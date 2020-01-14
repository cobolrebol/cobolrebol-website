REBOL [
    Title: "Quick slide show"
    Purpose: {Simple slide show from a folder of pictures.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a quick-and-dirty program written for a holiday part but then     ]
;; [ not used, to cycle through a folder of pictures and display them at       ]
;; [ five-second intervals; a slide show so to speak.                          ]
;; [---------------------------------------------------------------------------]

;; -- Function to get all files in the current folder, then filter out all 
;; -- but those with a specified extension. In practical use, get all the
;; -- pictures in the current directory.
FILES-OF-TYPE: func [
    TYPE-LIST
    /local FILE-ID-LIST
] [
    OF-TYPE?: func [
        FILE-ID 
    ] [
        find TYPE-LIST find/last FILE-ID "."
    ]
    FILE-ID-LIST: copy []
    FILE-ID-LIST: read %.
    while [not tail? FILE-ID-LIST] [
        either OF-TYPE? first FILE-ID-LIST [
            FILE-ID-LIST: next FILE-ID-LIST
        ] [
            remove FILE-ID-LIST
        ]
    ]
    FILE-ID-LIST: head FILE-ID-LIST
    return FILE-ID-LIST
]

;; -- Ask for the folder that contains the pictures.
;; -- Quit if one is not provided.
;; -- If one is provided, go there.
if not FOLDER: request-dir [
    alert "No folder requested."
    quit
]
change-dir FOLDER

;; -- Get all the pictures and get set up for the loop.
FILE-LIST: FILES-OF-TYPE [%.jpg]
FILE-COUNT: length? FILE-LIST
COUNTER: 1

;; -- Function to display the next picture in the list,
;; -- and wrap around to the beginning when we hit the end. 
CYCLE-PICTURE: does [
    COUNTER: COUNTER + 1
    if greater? COUNTER FILE-COUNT [
        COUNTER: 1
    ]
    MAIN-ID/text: to-string pick FILE-LIST COUNTER
    show MAIN-ID
    MAIN-PIC/image: to-image load pick FILE-LIST COUNTER
;; -- It appears we lose the aspect ratio if we don't re-set it.
    MAIN-PIC/effect: [aspect]
    show MAIN-PIC
]

;; -- Main loop.  Display the first picture when we first generate
;; -- the window, so it doesn't come up blank. 
MAIN-WINDOW: layout [
    across
    MAIN-PIC: image 1280x960 first FILE-LIST 'aspect
        rate 00:00:05         
        feel [
            engage: [  
                CYCLE-PICTURE
            ]
        ]
    return
    MAIN-ID: info 500 to-string first FILE-LIST
]

;; -- Begin. 
view center-face MAIN-WINDOW

