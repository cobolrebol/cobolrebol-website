REBOL [
    Title: "Card catalog browser"
    Purpose:  {Primitive searching of SWW's indexcard collection.}
]

;; [---------------------------------------------------------------------------]
;; [ SWW has a "card catalog" if items of importance.  The catalog is on the   ]
;; [ COB-ISAPPS server.  The subjects of the card catalog can be anywhere.     ]
;; [ This program lists the index cards by file name and also provided a       ]
;; [ keyword list for finding cards by keyword.                                ]
;; [ The window has three parts.  The left part is the keyword list built      ]
;; [ at BOJ.  The middle part is file names.  Initially, it is all file        ]
;; [ names.  If a keyword is selected, the list of file names changes to       ]
;; [ only those with that keyword.  The right-side part is a text area that    ]
;; [ contains the text of the index card if one is selected from the middle    ]
;; [ part.  No further features are provided since this is not expected to     ]
;; [ get heavy use.                                                            ]
;; [---------------------------------------------------------------------------]

do %FilesOfType.r
do %FileKeywordIndex.r

;; -- Go to where the index cares are
CARD-LOC: %/C/PersonalCardCatalog/
change-dir CARD-LOC 

;; -- Get the names of all the index cards
FILE-LIST: FILES-OF-TYPE [%.indexcard]

;; -- Load each card and build a keyword index
ICVERSION: ""
ITEM-ID: ""
ITEM-TYPE: ""
ITEM-LOC: ""
ITEM-TITLE: ""
KEYWORDS: []
DESCRIPTION: ""
foreach FILENAME FILE-LIST [
    ICVERSION: copy ""
    ITEM-ID: copy ""
    ITEM-TYPE: copy ""
    ITEM-TITLE; copy ""
    KEYWORDS: copy []
    DESCRIPTION: copy ""
    if attempt [do load FILENAME] [
        KIX/LOAD-KEYWORDS KEYWORDS FILENAME 
    ]
]
KIX/BUILD-INDEX

REFRESH-ALL-FILES: does [
    MAIN-FILES/data: FILE-LIST
    show MAIN-FILES
]

SHOW-CARD: does [
    MAIN-CARD/text: read to-file MAIN-FILES/picked 
    MAIN-CARD/line-list: none
    show MAIN-CARD 
]

SHOW-FILES: does [
    MAIN-FILES/data: select KIX/DATABLOCK MAIN-KEYWORDS/picked
    show MAIN-FILES
] 

MAIN-WINDOW: layout [
    across
    banner "SWW card catalog browser"
    return
    MAIN-KEYWORDS: text-list 200x600 data (extract KIX/DATABLOCK 2) 
        [SHOW-FILES]
    MAIN-FILES: text-list 400x600 data FILE-LIST [SHOW-CARD]
    MAIN-CARD: area 500x600 wrap 
    return
    button "Quit" [quit]
    button "Debug" [halt]
    button "All files" [REFRESH-ALL-FILES]
]

view center-face MAIN-WINDOW


