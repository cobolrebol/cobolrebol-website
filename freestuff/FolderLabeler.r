REBOL [
    Title: "Label a folder"
    Purpose: {In a select directory, create another folder containing
    information about the parent directory.}
]

;; [---------------------------------------------------------------------------]
;; [ This is another idea for labeling folders so we can remember why we       ]
;; [ have them.                                                                ]
;; [ This plan is to have each folder contain a folder called                  ]
;; [ "_WHAT-IS-THIS" which is named in this manner (with the                   ]
;; [ special characters) so that it floats up to the top of the list of        ]
;; [ contents.  Inside that folder will be whatever documentation we want      ]
;; [ to put there, but what this program puts there is some text files         ]
;; [ of basic information.  This basic information is in text files            ]
;; [ because text files are the simplest data format.                          ]
;; [ The files in this folder are:                                             ]
;; [     title.txt:       One line of title information.                       ]
;; [     description.txt: Free-format notes entered on a data-entry window.    ]
;; [     readme.txt:      Expanded free-format notes from data-entry window.   ]
;; [     keywords.txt:    keywords, one per line for searching.                ]
;; [ So when you run this program, it asks for a directory.  Then, it looks    ]
;; [ for the above-named sub-folder.  If it does not find it, it creates it.   ]
;; [ Then it goes down into that folder makes the above files if they          ]
;; [ do not already exist.                                                     ]
;; [---------------------------------------------------------------------------]

STARTING-FOLDER: %/C/
LABEL-FOLDER: %_WHAT-IS-THIS/
README-FILE: %readme.txt
TITLE-FILE: %title.txt
DESCRIPTION-FILE: %description.txt
KEYWORDS-FILE: %keywords.txt 
README-FIRST-LINE: rejoin [
    "Created on "
    now
    newline 
]

MAKE-LABELS: does [
    if not exists? LABEL-FOLDER [
        make-dir LABEL-FOLDER
    ]
    change-dir LABEL-FOLDER
    if not exists? README-FILE [
        write README-FILE README-FIRST-LINE
    ]
    if not exists? TITLE-FILE [
        write TITLE-FILE MAIN-TITLE/text
    ]
    if not exists? KEYWORDS-FILE [
        write KEYWORDS-FILE MAIN-KEYWORDS/text
    ]
    if not exists? DESCRIPTION-FILE [
        write DESCRIPTION-FILE MAIN-DESCRIPTION/text
    ]
]

MAKE-AND-EDIT: does [
    MAKE-LABELS
    editor README-FILE
]

PICK-FOLDER: does [
    change-dir STARTING-FOLDER
    DIR-NAME: request-dir
    if not DIR-NAME [
        alert "No directory requested"
        exit
    ]
    change-dir DIR-NAME
    MAIN-FOLDER/text: to-string DIR-NAME
    show MAIN-FOLDER
    MAIN-TITLE/text: copy ""
    show MAIN-TITLE
    MAIN-DESCRIPTION/text: copy ""
    MAIN-DESCRIPTION/line-list: none
    show MAIN-DESCRIPTION
    MAIN-KEYWORDS/text: copy ""
    MAIN-KEYWORDS/line-list: none
    show MAIN-KEYWORDS
] 

MAIN-WINDOW: layout [
    across
    banner "Folder labeler" font [shadow: none]
    return
    label "Title" 
    tab
    MAIN-TITLE: field 400
    return
    label "Description"
    tab
    MAIN-DESCRIPTION: area 400x200 as-is
    return
    label "Keywords"
    tab MAIN-KEYWORDS: area 200x400 as-is
    return
    button 160 "Pick a folder" [PICK-FOLDER]
    MAIN-FOLDER: info 300
    return
    button "Quit" [quit]
    button 150 "Make labels only" [MAKE-LABELS]
    button 200 "Make labels and edit readme" [MAKE-AND-EDIT]
]

view center-face MAIN-WINDOW 

