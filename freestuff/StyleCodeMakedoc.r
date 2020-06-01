REBOL [
    Title: "Style code makedoc"
    Purpose: {A documentation aid that combines the source code of the VID
    styles into one file, with makedoc headers between the code blocks.}
]

;; [---------------------------------------------------------------------------]
;; [ If you run the following code:                                            ]
;; [                                                                           ]
;; [ foreach [STYLE-WORD STYLE-CODE] svv/vid-styles [                          ]
;; [     CODE-FILENAME: copy ""                                                ]
;; [     CODE-FILENAME: to-file rejoin [                                       ]
;; [         to-string STYLE-WORD                                              ]
;; [         ".txt"                                                            ]
;; [     ]                                                                     ]
;; [     write CODE-FILENAME STYLE-CODE                                        ]
;; [ ]                                                                         ]
;; [                                                                           ]
;; [ you will extract the code for all the VID styles, and, for each style,    ]
;; [ write the code into a text file.  The name of the file will be the        ]
;; [ style name with the dot-txt extension.                                    ]
;; [                                                                           ]
;; [ This program is based on that idea but instead of writing the code        ]
;; [ for each style into its own file, the program writes it all into one      ]
;; [ file with a makedoc "---" header for each.  The output of this program    ]
;; [ would be suitable for pasting into a makedoc document.                    ]
;; [---------------------------------------------------------------------------]

MAKEDOC-FILE-ID: %StyleCode.txt
MAKEDOC-FILE: ""

foreach [STYLE-WORD STYLE-CODE] svv/vid-styles [
    append MAKEDOC-FILE rejoin [
        "---"
        STYLE-WORD
        newline
        newline
    ]
    STR: copy ""
    STR: to-string STYLE-CODE 
    insert/dup STR " " 4
    replace/all STR newline rejoin [newline "    "]
    append MAKEDOC-FILE STR
    append MAKEDOC-FILE newline
]

write MAKEDOC-FILE-ID MAKEDOC-FILE

alert "Done."

