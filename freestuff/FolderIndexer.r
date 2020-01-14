REBOL [
    Title: "List all keywords and their folders"
    Purpose: {List all keywords entered with the FolderLabeler
    program, in a text list.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a companion program to FolderLabeler.r.  It goes through all      ]
;; [ the folders in a selected directory and locates the "_WHAT-IS-THIS"       ]
;; [ folders, then pulls out the keywords file and builds a data structure.    ]
;; [ This data structure is a block, containing all the unique keywords        ]
;; [ and, for each keyword, a sub-block of all the folders with that keyword.  ]
;; [ Something like this:                                                      ]
;; [     keyword-1 [folder-1-1 folder-1-2...]                                  ]
;; [     keyword-2 [folder-2-1 folder-2-2...]                                  ]
;; [ The keywords in this data structure are used to build one text list,      ]
;; [ and the sub-blocks are used to build a second text list when a keyword    ]
;; [ is selected from the first text list.  Selecting a directory from         ]
;; [ the second text list will open the folder with Windows Explorer.          ]
;; [---------------------------------------------------------------------------]

STARTING-FOLDER: %/C/
LABEL-FOLDER: %_WHAT-IS-THIS/
README-FILE: %readme.txt
TITLE-FILE: %title.txt
DESCRIPTION-FILE: %description.txt
KEYWORDS-FILE: %keywords.txt 
OUTPUT-FILE: %FolderList.html

KEYWORDLIST: []     ;; keywords from one file 
KEYS-FOLDERS: []    ;; keyword-folder pairs 
DATABLOCK: []       ;; final data block for filling in text lists

;; -- For a given folder, find its keyword list and add the
;; -- keywords to our intermediate list of keywords and folder names.
CHECK-FOLDER: func [
    DIRNAME
] [
    KEYWORDLIST: copy []
    change-dir DIRNAME
    if exists? LABEL-FOLDER [
        change-dir LABEL-FOLDER
        if exists? KEYWORDS-FILE [
            KEYWORDLIST: copy []                
            KEYWORDLIST: read/lines KEYWORDS-FILE
            foreach LINE KEYWORDLIST [
                append KEYS-FOLDERS trim LINE
                append KEYS-FOLDERS to-string DIRNAME
            ]
        ]
    ]
    change-dir TARGET-DIR
]

;; -- Step 1.  Assemble all keywords and their associated files
;; -- into a temporary block.  Sort the block by keyword.
change-dir STARTING-FOLDER
if not TARGET-DIR: request-dir [
    alert "No folder selected"
    quit
]
change-dir TARGET-DIR
FILE-LIST: read TARGET-DIR/.
foreach FILE-OR-DIR FILE-LIST [
    if dir? FILE-OR-DIR [
        CHECK-FOLDER FILE-OR-DIR
    ]
]
sort/skip KEYS-FOLDERS 2 

;; -- Step 2. Build the data structure of unique keywords, each with 
;; -- a list of folders where it occurs.
CURRENTKEYWORD: ""
FOLDERBLOCK: []
foreach [KEYWORD FOLDERNAME] KEYS-FOLDERS [
    either not-equal? KEYWORD CURRENTKEYWORD [
        either not-equal? "" CURRENTKEYWORD [
            append DATABLOCK CURRENTKEYWORD
            append/only DATABLOCK FOLDERBLOCK
            CURRENTKEYWORD: copy KEYWORD
            FOLDERBLOCK: copy []
            append FOLDERBLOCK FOLDERNAME 
        ] [
            CURRENTKEYWORD: copy KEYWORD
            append FOLDERBLOCK FOLDERNAME
        ]
    ] [
        append FOLDERBLOCK FOLDERNAME
    ]
]
append DATABLOCK CURRENTKEYWORD
append/only DATABLOCK FOLDERBLOCK 

;; -- Step 3. Create a window with two text lists.
;; -- One list will be a list of the keywords.
;; -- The other will be a list of folders associated with
;; -- a keyword chosen from the first list.
SHOW-FOLDERS-FOR-KEYWORD: func [
    KEYWORD
] [
    MAIN-FOLDERS/data: select DATABLOCK KEYWORD
    show MAIN-FOLDERS
] 

OPEN-FOLDER: func [
    FOLDER
] [
    CALL-CMD: rejoin [
        "%windir%\explorer.exe "
        to-local-file rejoin [
            TARGET-DIR
            FOLDER
        ]
    ]
    call CALL-CMD
]

view center-face layout [
    across
    banner "Keyword folder index" font [shadow: none]
    return
    text 200 "Pick keyword to show folders"
    text 200 "Pick folder to open"
    return
    MAIN-KEYWORDS: text-list 200x500 data (extract DATABLOCK 2)
        [SHOW-FOLDERS-FOR-KEYWORD MAIN-KEYWORDS/picked]
    MAIN-FOLDERS: text-list 200x500 [OPEN-FOLDER MAIN-FOLDERS/picked]
    return
    button "Quit" [quit]
    button "Debug" [halt]
]


