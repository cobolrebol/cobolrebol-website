REBOL [
    Title: "Create file/folder index card"
    Purpose: {Create an index card for a specified file and store
    the index card in a well-known place.}
]

;; [---------------------------------------------------------------------------]
;; [ This program is part of an idea for indexing personal files.              ]
;; [ It creates an "index card" for a selected file or folder and stores it    ]
;; [ in a central location.  Other programs could provide capabilities for     ]
;; [ searching the index cards.                                                ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is an object that can be included in other programs and be used      ]
;; [ to create an "index card" for a file or directory.                        ]
;; [ To use it, assign values to the words below, and call the function        ]
;; [ CREATE-CARD.  The needed values for the index card are:                   ]
;; [                                                                           ]
;; [ ICVERSION: This is a hard-coded literal that might be used in some        ]
;; [     future plan for multiple versions of the index card.                  ]
;; [ ITEM-ID: The actual name of the file or folder being indexed.             ]
;; [     This should be a REBOL "file" data type.                              ]
;; [ ITEM-TYPE: The string "File" or "Folder."                                 ]
;; [ ITEM-LOC:  The full path, in REBOL format, to the ITEM-ID.                ]
;; [ ITEM-TITLE: A one-line string of any descriptive title-like text.         ]
;; [ KEWORDS: A block of strings which are keywords for searching.             ]
;; [ DESCRIPTION:  Multi-line string of any useful descriptive text.           ]
;; [                                                                           ]
;; [ Another needed value to make the function work is:                        ]
;; [                                                                           ]
;; [ ITEM-ID-BASE:  This is any string that will be used as part of the        ]
;; [     name of the index card. Usually, this would be the name of the file   ]
;; [     or folder being indexed, so it would be the same as ITEM-ID.          ]
;; [     However, this should be a string and not a "file" data type.          ]
;; [---------------------------------------------------------------------------]

INDEXCARD: make object! [

;; Home of the catalog.
    CARD-CATALOG: %/C/PersonalCardCatalog/
    INDEXITEM-ID: none

;; Items we put in an index card.
    ICVERSION: "ICV201801"
    ITEM-ID: none
    ITEM-TYPE: none
    ITEM-LOC: none
    ITEM-TITLE: none
    KEYWORDS: none
    DESCRIPTION: none
    ITEM-ID-BASE: none 

;; Template for an index card.
;; Don't know why but the "INDEXCARD/" seems to be required.
CARD-TEMPLATE: {ICVERSION: <% mold INDEXCARD/ICVERSION %>
ITEM-ID: <% mold INDEXCARD/ITEM-ID %>
ITEM-TYPE: <% mold INDEXCARD/ITEM-TYPE %>
ITEM-LOC: <% mold INDEXCARD/ITEM-LOC %> 
ITEM-TITLE: <% mold INDEXCARD/ITEM-TITLE %>
KEYWORDS: <% mold INDEXCARD/KEYWORDS %>
DESCRIPTION: <% mold INDEXCARD/DESCRIPTION %>
}
    
    CREATE-CARD: does [
        INDEXITEM-ID: to-file rejoin [
            CARD-CATALOG
            ITEM-ID-BASE
            ".indexcard"
        ] 
        write INDEXITEM-ID build-markup copy CARD-TEMPLATE 
    ]
]

;; ----------------------------------------------------------------------------

;; Starting folder for picking file.
STARTING-FOLDER: %/C/
CURRENT-FILE: none

if not exists? INDEXCARD/CARD-CATALOG [
    make-dir INDEXCARD/CARD-CATALOG
]

PICK-FILE: does [
    CURRENT-FILE: request-file/only 
    if not CURRENT-FILE [
        alert "No file requested"
        exit
    ]
    INDEXCARD/ITEM-TYPE: "File"
;;  set [INDEXCARD/ITEM-LOC INDEXCARD/ITEM-ID] split-path CURRENT-FILE 
    INDEXCARD/ITEM-LOC: first split-path CURRENT-FILE
    INDEXCARD/ITEM-ID: second split-path CURRENT-FILE
    INDEXCARD/ITEM-ID-BASE: INDEXCARD/ITEM-ID
    MAIN-FILE/text: to-string CURRENT-FILE
    show MAIN-FILE
    MAIN-CARDID/text: INDEXCARD/ITEM-ID-BASE
    show MAIN-CARDID 
;;  -- Clear rest of form for data entry
    MAIN-TITLE/text: copy ""
    show MAIN-TITLE
    MAIN-DESCRIPTION/text: copy ""
    MAIN-DESCRIPTION/line-list: none
    show MAIN-DESCRIPTION
    MAIN-KEYWORDS/text: copy ""
    MAIN-KEYWORDS/line-list: none
    show MAIN-KEYWORDS
]

PICK-FOLDER: does [
    CURRENT-FILE: request-dir
    if not CURRENT-FILE [
        alert "No folder requested"
        exit
    ]
    INDEXCARD/ITEM-TYPE: "Folder"
;;  set [INDEXCARD/ITEM-LOC INDEXCARD/ITEM-ID] split-path CURRENT-FILE
    INDEXCARD/ITEM-LOC: first split-path CURRENT-FILE
    INDEXCARD/ITEM-ID: second split-path CURRENT-FILE
    INDEXCARD/ITEM-ID-BASE: copy INDEXCARD/ITEM-ID
    replace INDEXCARD/ITEM-ID-BASE "/" "" 
    MAIN-FILE/text: to-string CURRENT-FILE
    show MAIN-FILE
    MAIN-CARDID/text: INDEXCARD/ITEM-ID-BASE
    show MAIN-CARDID 
;;  -- Clear rest of form for data entry
    MAIN-TITLE/text: copy ""
    show MAIN-TITLE
    MAIN-DESCRIPTION/text: copy ""
    MAIN-DESCRIPTION/line-list: none
    show MAIN-DESCRIPTION
    MAIN-KEYWORDS/text: copy ""
    MAIN-KEYWORDS/line-list: none
    show MAIN-KEYWORDS
] 

MAKE-CARD: does [
    if not CURRENT-FILE [
        alert "No file requested"
        exit
    ]
    INDEXCARD/ITEM-TITLE: get-face MAIN-TITLE
    INDEXCARD/KEYWORDS: parse MAIN-KEYWORDS/text none
    INDEXCARD/DESCRIPTION: MAIN-DESCRIPTION/text
    INDEXCARD/CREATE-CARD
    alert "Done." 
]

COPY-CARD: does [
    if not INDEXCARD/INDEXITEM-ID [
        alert "No card created"
        exit
    ]
    write clipboard:// read INDEXCARD/INDEXITEM-ID 
] 

MAIN-WINDOW: layout [
    across
    label 100 "File ID"
    MAIN-FILE: info 400 font [style: 'bold]
    return
    label 100 "Card ID" 
    MAIN-CARDID: field 400 font [style: 'bold]
    return
    label 100 "Title"
    MAIN-TITLE: field 400 font [style: 'bold]
    return
    label 100 "Description"
    MAIN-DESCRIPTION: area 400x180 wrap font [style: 'bold]
    return
    label 100 "Keywords"
    MAIN-KEYWORDS: area 200x180 as-is font [style: 'bold]
    return
    button 100 "Pick a file" [PICK-FILE] 
    button 100 "Pick a folder" [PICK-FOLDER]
    button 100 "Make card" [MAKE-CARD]
    button 100 "Copy" [COPY-CARD]
    button "Quit" [quit]  
    return
    button "Debug" [halt] 
]

change-dir STARTING-FOLDER
view center-face MAIN-WINDOW 

