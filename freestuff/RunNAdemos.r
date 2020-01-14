REBOL [
    title: "Run the short demos of Nick Antonaccio"
] 

;; [---------------------------------------------------------------------------]
;; [ On the internet there can be found a file of short examples by            ]
;; [ Nick Antonaccio.  He suggests pasting each demo into a REBOL command      ]
;; [ prompt to run them, or pasting each into the REBOL editor.                ]
;; [ This is an alternative method of running them, not much less work,        ]
;; [ but a fun example to write, where this program brings all the demos       ]
;; [ into memory and then creates a text-list menu for running them.           ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This program relies on the file of demos being in the format is was in    ]
;; [ at the time this program was written.  If the format of the demo file     ]
;; [ changes, this program will not work.                                      ]
;; [ The format of the file is:                                                ]
;; [                                                                           ]
;; [     Comment lines starting with a semicolon, which we will filter out     ]
;; [                                                                           ]
;; [     REBOL mini-programs, each starting with a REBOL header that contains  ]
;; [     a title on the header line.                                           ]
;; [                                                                           ]
;; [ This program will take apart the demo file and assemble it into the       ]
;; [ block called DEMOLIST.  That block will contain repetitions of the        ]
;; [ program title as a string, and the program code as a string, that is,     ]
;; [                                                                           ]
;; [     "Title 1" {REBOL code for program 1}                                  ]
;; [     "Title 1" {REBOL code for program 1}                                  ]
;; [     ...etc.                                                               ]
;; [ (I tried to put the code in a block and couldn't make it work.)           ]
;; [                                                                           ]
;; [ The program titles will be put into a text list, and then a person can    ]
;; [ select the title and the program will be executed by "do"ing the          ]
;; [ appropriate block of code.                                                ]
;; [---------------------------------------------------------------------------]

DEMOLIST: copy []   ;; Demo file, reassembled
DEMOCODE: copy ""   ;; Holding area for one block of demo code
DEMOTITLE: copy ""  ;; Holding area for one program title
DEMOID: %demo.r     ;; Temporary file for launching demo 

;; [---------------------------------------------------------------------------]
;; [ Examine a line of text to see if it is a REBOL header.                    ]
;; [ This will be determined by the presence of REBOL as the first five        ]
;; [ non-blank characters on the line.                                         ]
;; [---------------------------------------------------------------------------]

IS-HEADER?: func [
    SOURCELINE
] [
    either equal? "REBOL" copy/part trim/head copy SOURCELINE 5 [
        return true                    
    ] [
        return false   
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Examine a line of text in a very specifi format, like this:               ]
;; [     REBOL [Title: "Test program"]                                         ]
;; [ Note that the word REBOL is the first word on the line, and the           ]
;; [ title is the first item in the title block, and the title block is on     ]
;; [ the same line.                                                            ]
;; [ The result of this function will be the string of characters in the       ]
;; [ title string.                                                             ]
;; [ If for some reason this function is called on a line that is not a        ]
;; [ REBOL header, the returned title string will be empty.                    ]
;; [---------------------------------------------------------------------------]

GET-TITLE: func [
    SOURCELINE
] [
    IN-TITLE: false
    TITLELIT: copy ""
    foreach CHARACTER SOURCELINE [
        either equal? CHARACTER #"^"" [
            either IN-TITLE [
                IN-TITLE: false
            ] [
                IN-TITLE: true
            ]
        ] [
            if IN-TITLE [
                if not-equal? CHARACTER #"^"" [
                    append TITLELIT CHARACTER
                ]
            ]
        ]
    ]
    return TITLELIT
]

;; [---------------------------------------------------------------------------]
;; [ Get the demo file into memory and filter out the comment lines.           ]
;; [---------------------------------------------------------------------------]

DEMOFILE: read/lines http://re-bol.com/short_rebol_examples.r
foreach LINE DEMOFILE [
    if equal? ";" copy/part at trim/head copy LINE 1 1 [
        remove DEMOFILE
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Go through the demo file.                                                 ]
;; [ When we hit a REBOL header, extract the title and prepare to add this     ]
;; [ demo to our file.  Get the title and save it, and then as we read         ]
;; [ through the file, add lines to the code block until we hit the next       ]
;; [ header.  Then when we hit another REBOL header, and the previous one      ]
;; [ that we have been building up to our big block of all demos.              ]
;; [ We will have to account for the scenario where the first demo is          ]
;; [ preceded by blank lines or other lines that are not part of a demo.       ]
;; [ We will know that because we will not have picked off any title string.   ]
;; [ Similarly, when we reach the end of the file, there will be a demo        ]
;; [ that we have not yet added to our list.                                   ]
;; [---------------------------------------------------------------------------]

foreach LINE DEMOFILE [
    either IS-HEADER? LINE [
        if not-equal? "" DEMOTITLE [
;;;;;;;     print rejoin ["Saving " DEMOTITLE] ;; for debugging
            append DEMOLIST DEMOTITLE
            append DEMOLIST DEMOCODE
        ]
        DEMOTITLE: copy ""
        DEMOTITLE: GET-TITLE LINE
        DEMOCODE: copy ""
        append DEMOCODE rejoin [LINE newline]
    ] [
        append DEMOCODE rejoin [LINE newline]
    ]
]

if not-equal? "" DEMOTITLE [
;;  print rejoin ["Saving " DEMOTITLE]  ;; for debugging 
    append DEMOLIST DEMOTITLE
    append DEMOLIST DEMOCODE
]

;; [---------------------------------------------------------------------------]
;; [ At this point, DEMOLIST contains all the demo code, with titles,          ]
;; [ extracted from the source file.                                           ]
;; [ Now we want to build our menu window and display it.                      ]
;; [---------------------------------------------------------------------------]

RUN-DEMO: func [
    CODE
] [
    write/lines DEMOID CODE
    CODE-WINDOW/text: CODE
    show CODE-WINDOW
    launch DEMOID
]

MAIN-WINDOW: layout [
    across
    banner "Select a demo to run it"
    return
    PROGRAM-LIST: text-list 400x700 data (extract DEMOLIST 2)
        [RUN-DEMO select DEMOLIST value]
    CODE-WINDOW: info 500x700 
    return
    button "Quit" [quit] 
]

view center-face MAIN-WINDOW 

