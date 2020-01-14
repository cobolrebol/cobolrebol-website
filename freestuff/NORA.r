REBOL [
    Title: "NORA: NOte Recording Assistant"
]

;; [---------------------------------------------------------------------------]
;; [ This program was created for a customer base of one person, SWW.          ]
;; [ It is a replacement for all the quarter-sheets of paper scattered         ]
;; [ around his desk.  It also is a learning tool for REBOL, and a demo        ]
;; [ for the office of what a REBOL program looks like.                        ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ The code below was at one time a separate module created for the          ]
;; [ recording of little notes.  It has been pasted in here to make this       ]
;; [ program one file instead of several.  The code below could be extracted   ]
;; [ and put back into a separate module if one had a use for it elsewhere.    ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Note management module.                                                   ]
;; [---------------------------------------------------------------------------]

NOTE-FILE-ID: %lsop.txt

;; [---------------------------------------------------------------------------]
;; [ When we create an empty file, we will write it out as text, instead of    ]
;; [ saving it as a block.  The reason for this is so that we can control      ]
;; [ the look of the file, so it can be examined visually with greater ease.   ]
;; [---------------------------------------------------------------------------]

NOTE-EMPTY-FILE: "[]"
NOTE-HIGHEST-ID: 0
NOTE-NOTES: []
NOTE-CREATE-FILE: does [
    write NOTE-FILE-ID NOTE-EMPTY-FILE
]

;; [---------------------------------------------------------------------------]
;; [ The file, on disk, is going to look like this:                            ]
;; [                                                                           ]
;; [ <scrap-number-1> [ <update-date-1> <scrap-title-1> <scrap-text-1> ]       ]
;; [ <scrap-number-2> [ <update-date-2> <scrap-title-2> <scrap-text-2> ]       ]
;; [ ...                                                                       ] 
;; [ <scrap-number-n> [ <update-date-n> <scrap-title-n> <scrap-text-n> ]       ]
;; [ ]                                                                         ]
;; [                                                                           ]
;; [ Notice how the ID numbers are outside the brackets that hold the          ]
;; [ data for each scrap.  This is so the scrap numbers are items in the       ]
;; [ NOTE-NOTES block and we can search for them.                              ]
;; [                                                                           ]
;; [ Below are holding areas for the data for one scrap, either one            ]
;; [ we have read or one we are about to create.  This is like the             ]
;; [ "record area" for the file.                                               ]
;; [ The item called REC-ID will do double duty.                               ]
;; [ It will be the scrap number of an item we have read, or, if it is         ]
;; [ zero, it will indicate that this is a new record.                         ]
;; [---------------------------------------------------------------------------]

NOTE-REC-ID: 0
NOTE-REC-DATE: none
NOTE-REC-TITLE: ""
NOTE-REC-TEXT: ""

;; [---------------------------------------------------------------------------]
;; [ This is where we will build the block that goes after a NOTE-ID.          ]
;; [---------------------------------------------------------------------------]

NOTE-REC-BLOCK: []

;; [---------------------------------------------------------------------------]
;; [ This procedure "opens" the file by bringing it into memory.               ]
;; [ Because the data is stored in a REBOL-recognizable format,                ]
;; [ we use the "load" command.                                                ]
;; [ When we store a note, we give it a number ID so we can identify it.       ]
;; [ We store notes so that the most recent is first.                          ]
;; [ Therefore, we can grab the number of the first one and store it as        ]
;; [ the highest-assigned number.  If we happen to delete the top note,        ]
;; [ we will end up re-using the number, which is OK.                          ]
;; [---------------------------------------------------------------------------]

NOTE-OPEN: does [
    NOTE-NOTES: copy []
    NOTE-NOTES: load NOTE-FILE-ID
    either (0 = length? NOTE-NOTES) [
        NOTE-HIGHEST-ID: 0
    ] [
        NOTE-HIGHEST-ID: first NOTE-NOTES
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "closes" the file by formatting the data into a            ]
;; [ somewhat-nice-looking form and writing it to disk.                        ]
;; [---------------------------------------------------------------------------]

NOTE-FILE: ""
NOTE-CLOSE: does [
    NOTE-FILE: copy ""
    NOTE-NOTES: head NOTE-NOTES
    forskip NOTE-NOTES 2 [
        append NOTE-FILE first NOTE-NOTES
        append NOTE-FILE " "
        append/only NOTE-FILE mold second NOTE-NOTES
        append NOTE-FILE newline
    ]
    write NOTE-FILE-ID NOTE-FILE
]

;; [---------------------------------------------------------------------------]
;; [ This is a common procedure to format the block that contains the          ]
;; [ note data.                                                                ]
;; [ The note data is a block.                                                 ]
;; [---------------------------------------------------------------------------]

NOTE-FORMAT-BLOCK: does [
    NOTE-REC-DATE: now/date
    NOTE-REC-BLOCK: copy []
    append NOTE-REC-BLOCK NOTE-REC-DATE
    append NOTE-REC-BLOCK NOTE-REC-TITLE
    append NOTE-REC-BLOCK NOTE-REC-TEXT
]   

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to add a new record.                                ]
;; [ The caller should fill in the items in the "record area" noted above.     ]
;; [ Do not bother with the record ID because a new one will be generated,     ]
;; [ one greater than the highest used.                                        ]
;; [ Do not bother either with the date, since that is generated also.         ]
;; [ Note that we add data to the front of the NOTE-NOTES block, so that       ]
;; [ when we show a list of existing notes, the most recent will be on the     ]
;; [ top.                                                                      ] 
;; [---------------------------------------------------------------------------]

NOTE-ADD-RECORD: does [
    NOTE-HIGHEST-ID: NOTE-HIGHEST-ID + 1
    NOTE-REC-ID: NOTE-HIGHEST-ID
    NOTE-FORMAT-BLOCK
    NOTE-NOTES: head NOTE-NOTES
    insert/only NOTE-NOTES NOTE-REC-BLOCK
    NOTE-NOTES: head NOTE-NOTES
    insert NOTE-NOTES NOTE-REC-ID
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure for updating an existing record.                    ]
;; [ The caller should fill in the record area as for ADD-RECORD, but          ]
;; [ this time DO fill in a record ID.  Normally the record ID will be         ]
;; [ filled in from a "read" operation.                                        ]
;; [ This procedure will find the record with the given ID and update the      ]
;; [ data block for that ID.                                                   ]
;; [---------------------------------------------------------------------------]

NOTE-STORE-OK: false
NOTE-STORE-RECORD: does [
    NOTE-NOTES: head NOTE-NOTES
    NOTE-TEMP: select NOTE-NOTES NOTE-REC-ID
    either NOTE-TEMP [
        NOTE-STORE-OK: true
        NOTE-FORMAT-BLOCK
        change NOTE-TEMP NOTE-REC-BLOCK
    ] [
        NOTE-STORE-OK: false
    ]
]
    
;; [---------------------------------------------------------------------------]
;; [ This procedure deletes a record identified by the contents of             ]
;; [ NOTE-REC-ID.                                                              ]
;; [---------------------------------------------------------------------------]

NOTE-DELETE-OK: false
NOTE-DELETE-RECORD: does [
    NOTE-NOTES: head NOTE-NOTES
    NOTE-TEMP: find NOTE-NOTES NOTE-REC-ID
    either NOTE-TEMP [
        NOTE-DELETE-OK: true
        remove NOTE-TEMP   ; Delete the record number     
        remove NOTE-TEMP   ; Delete the data block
    ] [
        NOTE-DELETE-OK: false
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure reads a record identified by the NOTE-REC-ID.              ]
;; [---------------------------------------------------------------------------]

NOTE-READ-OK: false
NOTE-READ-RECORD: does [
    NOTE-NOTES: head NOTE-NOTES
    NOTE-FOUND: find NOTE-NOTES NOTE-REC-ID
    either NOTE-FOUND [
        NOTE-READ-OK: true
        NOTE-UNLOAD-RECORD
    ] [ 
        NOTE-READ-OK: false
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure unloads the data from NOTE-NOTES, pointed to by the        ]
;; [ word NOTES-FOUND, into the "record area."                                 ]
;; [ In normal use, after you read a record, you would NOT ALTER the           ]
;; [ NOTE-REC-ID field, because you might later want to update the             ]
;; [ record identified by that field.                                          ]
;; [---------------------------------------------------------------------------]

NOTE-UNLOAD-RECORD: does [
    NOTE-REC-ID: 0
    NOTE-REC-DATE: none
    NOTE-REC-TITLE: copy ""
    NOTE-REC-TEXT: copy ""
    NOTE-REC-ID: first NOTE-FOUND
    NOTE-REC-DATE: first second NOTE-FOUND
    NOTE-REC-TITLE: second second NOTE-FOUND
    NOTE-REC-TEXT: third second NOTE-FOUND
]

;; [---------------------------------------------------------------------------]
;; [ This procedure builds a list of note titles, each in a string             ]
;; [ consisting of the ID, date, and title, seperated by colons.               ]
;; [ The purpose of this list is to provide data for a screen, in some other   ]
;; [ program or module.                                                        ]
;; [---------------------------------------------------------------------------]

NOTE-ID-ENTRY: ""
NOTE-ID-LIST: []
NOTE-BUILD-INDEX: does [
    NOTE-NOTES: head NOTE-NOTES
    NOTE-ID-LIST: copy []
    forskip NOTE-NOTES 2 [
        NOTE-ID-ENTRY: copy ""
        append NOTE-ID-ENTRY first NOTE-NOTES
        append NOTE-ID-ENTRY ":"
        append NOTE-ID-ENTRY first second NOTE-NOTES
        append NOTE-ID-ENTRY ":"
        append NOTE-ID-ENTRY second second NOTE-NOTES
        append NOTE-ID-LIST NOTE-ID-ENTRY
    ]   
]       
    
;; [---------------------------------------------------------------------------]
;; [ End of note management module.                                            ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Beginning of main program.                                                ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These are values that an operator might want to change to                 ]
;; [ tailor the program for personal use.  These items are kept here so that   ]
;; [ there is only one place to find such items.                               ]
;; [---------------------------------------------------------------------------]

LITTLENOTE-DEFAULT-DIR: %.                 
LITTLENOTE-FILE-NAME: "NORA.txt"

if not dir? LITTLENOTE-DEFAULT-DIR [
    make-dir LITTLENOTE-DEFAULT-DIR
]
change-dir LITTLENOTE-DEFAULT-DIR

LITTLENOTE-FILE-ID: rejoin [
    LITTLENOTE-DEFAULT-DIR 
    "/"
    LITTLENOTE-FILE-NAME
]
NOTE-FILE-ID: LITTLENOTE-FILE-ID

;; [---------------------------------------------------------------------------]
;; [ We set a flag when we update something, so we can skip writing the file   ]
;; [ if we do NOT update something.                                            ]
;; [---------------------------------------------------------------------------]

FILE-WAS-UPDATED: false

;; [---------------------------------------------------------------------------]
;; [ This procedure is executed when we click on an item in the text-list      ]
;; [ that holds the list of note titles.                                       ]
;; [ It reads the note, fills in the screen, and displays the screen,          ]
;; [ so the note can be read, updated, or deleted.                             ]
;; [---------------------------------------------------------------------------]

SELECTED-ID: ""
SELECTED-LINE: ""
SELECT-NOTE: does [
    SELECTED-ID: copy ""
    SELECTED-LINE: copy ""
    SELECTED-LINE: first MAIN-LIST/picked
    SELECTED-ID: first parse/all SELECTED-LINE ":"
    either (SELECTED-ID = "") [
        alert "No note was selected from the list"  ;; should be impossible
    ] [
        NOTE-REC-ID: to-integer SELECTED-ID
        NOTE-READ-RECORD
        either NOTE-READ-OK [
            SHOW-NOTE-FIELDS
        ] [
            alert rejoin ["Note " NOTE-REC-ID " not in file"]  ;; also impossible
        ]
    ]
]

SHOW-NOTE-FIELDS: does [
    MAIN-ID/text: to-string NOTE-REC-ID
    MAIN-TITLE/text: NOTE-REC-TITLE
    MAIN-DATE/text: to-string NOTE-REC-DATE
    MAIN-TEXT/text: NOTE-REC-TEXT
    show [
        MAIN-TITLE
        MAIN-ID
        MAIN-DATE
        MAIN-TEXT
    ]
]    

;; [---------------------------------------------------------------------------]
;; [ This procedure is executed by the "Save" button.                          ]
;; [ It either adds a new note or updates an existing.                         ]
;; [ If a note has been read, NOTE-REC-ID will be non-zero and we will         ]
;; [ update the current note.  If NOTE-REC-ID is zero, then either no          ]
;; [ record has been read or we have used the "New button to clear the         ]
;; [ screen, which also zeros NOTE-REC-ID.                                     ]
;; [---------------------------------------------------------------------------]

SAVE-BUTTON: does [
    either (0 = NOTE-REC-ID) [
        ADD-NEW-RECORD
    ] [
        UPDATE-CURRENT-RECORD
    ]
]

ADD-NEW-RECORD: does [
    either (MAIN-TITLE/text = "") [
        alert "You can't blank out the title area"
    ] [
        NOTE-REC-TITLE: copy ""
        NOTE-REC-TITLE: MAIN-TITLE/text
        NOTE-REC-TEXT: copy ""
        NOTE-REC-TEXT: MAIN-TEXT/text
        NOTE-ADD-RECORD
        FILE-WAS-UPDATED: true
        SHOW-FRESH-SCREEN
    ]
]

UPDATE-CURRENT-RECORD: does [
    either (MAIN-TITLE/text = "") [
        alert "You can't blank out the title area"
    ] [
        NOTE-REC-TITLE: copy ""
        NOTE-REC-TITLE: MAIN-TITLE/text
        NOTE-REC-TEXT: copy ""
        NOTE-REC-TEXT: MAIN-TEXT/text
        NOTE-STORE-RECORD
        FILE-WAS-UPDATED: true
        SHOW-FRESH-SCREEN
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is run by the "Delete" button.                             ]
;; [---------------------------------------------------------------------------]

DELETE-BUTTON: does [
    either (0 = NOTE-REC-ID) [
        alert "You must select a note before you can delete it"
    ] [
        NOTE-DELETE-RECORD
        FILE-WAS-UPDATED: true
        SHOW-FRESH-SCREEN
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is executed by the "New" button.                           ]
;; [ It shows a blank screen, but it also clears the note record area          ]
;; [ so that if we click the "Save" button we will add a new record, and       ]
;; [ not accidentally use any old data.                                        ]
;; [---------------------------------------------------------------------------]

NEW-BUTTON: does [
    SHOW-FRESH-SCREEN
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is executed by the "Quit" button.                          ]
;; [ It will save the file if the file was updated.                            ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    if FILE-WAS-UPDATED [
        NOTE-CLOSE
    ]
    quit
]

;; [---------------------------------------------------------------------------]
;; [ The response to any update is going to be a blank screen, ready for       ]
;; [ adding a new note.                                                        ]
;; [ That "work flow" is going to be the most common, so we will optimize      ]
;; [ for it.                                                                   ]
;; [---------------------------------------------------------------------------]

SHOW-FRESH-SCREEN: does [
    NOTE-REC-ID: 0
    NOTE-REC-DATE: none
    NOTE-REC-TITLE: copy ""
    NOTE-REC-TEXT: copy ""
    NOTE-BUILD-INDEX
    MAIN-LIST/data: NOTE-ID-LIST
    MAIN-TITLE/text: copy ""
    MAIN-ID/text: "Note ID number"
    MAIN-DATE/text: "Last update date"
    MAIN-TEXT/text: copy ""
    show [
        MAIN-LIST
        MAIN-TITLE
        MAIN-ID
        MAIN-DATE
        MAIN-TEXT
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Begin.                                                                    ]
;; [                                                                           ]
;; [ I think we have to build the note index before we run the VID code        ]
;; [ through the "layout" function, so there is data available for the         ]
;; [ text list.                                                                ]
;; [---------------------------------------------------------------------------]

either exists? NOTE-FILE-ID [
    NOTE-OPEN
] [
    GO?: alert [
        rejoin ["OK to create " NOTE-FILE-ID "?"]
        "Yes"
        "No"
    ]
    either GO? [
        NOTE-CREATE-FILE
        NOTE-OPEN
    ] [
        quit
    ]
]
NOTE-BUILD-INDEX

MAIN-WINDOW: [
    across
    VH1 "NOte Recording Assistant"
    return
    MAIN-LIST: text-list 400 data NOTE-ID-LIST [SELECT-NOTE]
    return
    MAIN-TITLE: field 400X25
    return
    label "Note ID"
    MAIN-ID: text "Note ID number"
    label "Last updated on"
    MAIN-DATE: text "Last update date"
    return
    MAIN-TEXT: area 400x400
    return
    across
    button 60x24 "New" [NEW-BUTTON]
    button 60x24 "Save" [SAVE-BUTTON]
    button 60x24 "Delete" [DELETE-BUTTON]
    button 60x24 "Quit" [QUIT-BUTTON]
]

view center-face layout MAIN-WINDOW

