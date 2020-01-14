REBOL [
    Title: "PRTTXT: Format print lines for a text file"
]

;; [---------------------------------------------------------------------------]
;; [ This is an object that can be used to define a fixed-format "report"      ]
;; [ that is basically a text file of fixed-format lines, which when           ]
;; [ completed may be printed through any text editor.                         ]
;; [ This is a solution for making basic columnar reports.  It works as it     ]
;; [ is, but may be used as an example or as a starting point for something    ]
;; [ tailored to your own situation.                                           ]
;; [                                                                           ]
;; [ The object provides basic functions that you would expect to perform      ]
;; [ when printing a basic report.  You will "open" the print file which       ]
;; [ means to generate heading lines and provide instructions about where      ]
;; [ to put data on a fixed-format print line.  You will "close" the print     ]
;; [ file when you are done which means to write your "print lines" to a       ]
;; [ text file.  Between opening and closing, you will "print" lines of        ]
;; [ fixed-format text which means to format those lines based on data         ]
;; [ you have submitted and then add those lines to a block of text that       ]
;; [ represents the whole printed report.                                      ]
;; [                                                                           ]
;; [ To use:                                                                   ]
;; [                                                                           ]
;; [ Make an instance of the object with:                                      ]
;; [     MYPRINTFILE: make PRTTXT []                                           ]
;; [ By using objects, this module lets you put several reports into the       ]
;; [ same program.  Optionally, you can set a line of text at the very         ]
;; [ top of the report, and a line below that, this way:                       ]
;; [     MYPRINTFILE: make PRTTXT [                                            ]
;; [         SITE-NAME: "My Installation Name"                                 ]
;; [         REPORT-TITLE: "Title of this report"                              ]
;; [     ]                                                                     ]
;; [                                                                           ]
;; [ Before you can "print" to the report, you must "open" it.                 ]
;; [ This is just a way to get you to perform a procedure that does some       ]
;; [ setup for you.  You must provide two things to the "open" function.       ]
;; [ You must provide a file name that will be used when you "close" the       ]
;; [ report to write it to disk.  You must provide a block that contains       ]
;; [ repetitions of a word and a pair.  The word will become a word that       ]
;; [ you may set to a value when printing.  The word also will become          ]
;; [ a column heading on the report.  The pair represents the column           ]
;; [ position and the length, where the value of the word will be placed       ]
;; [ on a fixed-format print line.  This will look something like this:        ]
;; [     MYPRINTFILE/OPEN-OUTPUT                                               ]
;; [         %myprintifileid.txt                                               ]
;; [         [word-1 pair-1                                                    ]
;; [          word-2 pair-2                                                    ]
;; [          ...                                                              ]
;; [          word-n pair-n]                                                   ]
;; [ The result of the above procedure will be that there will be an           ]
;; [ object called MYPRINTFILE/RECORD ("MYPRINTFILE" is a name you choose;     ]
;; [ this is just an example) and that object will have words, specifically,   ]
;; [ the words you specified.  You will set these words to values,             ]
;; [ and when you "print" them they will go on the "print line" at the         ]
;; [ spots indicated by the pairs.                                             ]
;; [                                                                           ]
;; [ When you want to "print" data, you set the words you specified to         ]
;; [ values by referring to them in the RECORD object.  For example:           ]
;; [     MYPRINTFILE/RECORD/word-1: value-1                                    ]
;; [     MYPRINTFILE/RECORD/word-2: value-2                                    ]
;; [ When you have set the values you want to print, you perform the           ]
;; [ procedure to put that data into the file:                                 ]
;; [     MYPRINTFILE/WRITE-RECORD                                              ]
;; [                                                                           ]
;; [ When you are done producing the report, you have to get it into a disk    ]
;; [ file with:                                                                ]
;; [     MYPRINTFILE/CLOSE-OUTPUT                                              ]
;; [---------------------------------------------------------------------------]

PRTTXT: make object! [

;; [---------------------------------------------------------------------------]
;; [ Items the caller may override when creating an instance of this object.   ]
;; [---------------------------------------------------------------------------]

    REPORT-TITLE: "" ;; Text to put at the top of the report
    SITE-NAME: ""    ;; Your installation name at the very top of the report

;; [---------------------------------------------------------------------------]
;; [ Working items                                                             ]
;; [ Note that the SPACEFILL function expects a string.  It is the job of      ]
;; [ the caller to do any necessary conversion.                                ]
;; [---------------------------------------------------------------------------]

    FILE-ID: none         ;; Name of a file we will create
    FIELDS: none          ;; Fields submitted at open time
    FILE-DATA: []         ;; All the data in the above file
    RECORD: none          ;; An object we will create for loading data 
    PRINT-LINE: none      ;; A formatted line to put into FILE-DATA
    HEADING-LINE: none    ;; A line of column headings
    HYPHEN-LINE: none     ;; Hyphens under column headings
    SPACEFILL: func [
        "Left justify a string, pad with spaces to specified length"
        INPUT-STRING 
        FINAL-LENGTH
    ] [
        head insert/dup tail copy/part trim INPUT-STRING FINAL-LENGTH #" " max 0 FINAL-LENGTH - length? INPUT-STRING
    ]
;;  -- Not sure if we want to allow for right-or-left justification. 
    SPACEFILL-LEFT: func [
        "Right justify a string, pad with spaces to specified length"
        INPUT-STRING
        FINAL-LENGTH
    ] [
        trim INPUT-STRING
        either FINAL-LENGTH > length? INPUT-STRING [
            return head insert/dup INPUT-STRING " " FINAL-LENGTH - length? INPUT-STRING
        ] [
            return copy/part INPUT-STRING FINAL-LENGTH
        ]
    ]
    HYPHENS: func [
        "Return a string of a given number of hyphens"
        SPACE-COUNT [integer!]
        /local FILLER 
    ] [
        FILLER: copy ""
        loop SPACE-COUNT [
            append FILLER "-"
        ]
        return FILLER
    ]

;; [---------------------------------------------------------------------------]
;; [ Create the RECORD sub-object from words provided.                         ]
;; [ Create a heading line by converting the words to strings and putting      ]
;; [ them into a heading line at the spots indicated by the pairs associated   ]
;; [ with the words.                                                           ]
;; [ Put the SITE-NAME, REPORT-TITLE, and HEADING-LINE into the first lines    ]
;; [ of the output file.                                                       ]
;; [---------------------------------------------------------------------------]

    OPEN-OUTPUT: func [
        FILEID [file!]
        FIELDLIST [block!]
    ] [
;;  -- Save the data from the caller.
        FILE-ID: FILEID
        FIELDS: copy FIELDLIST
;;  -- Initialize the output area.
        FILE-DATA: copy []
;;  -- Make an object (RECORD) that the caller will load with data.
        RECORD: make object! []
        foreach [FIELDNAME POSITION] FIELDS [
            RECORD: make RECORD compose [
                (to-set-word FIELDNAME) {""}
            ]
        ]
;;  -- Build a heading line out of the words from the caller.
        HEADING-LINE: copy ""
        loop 256 [append HEADING-LINE " "]
        foreach [FIELDNAME POSITION] FIELDS [
            HEADING-LINE: head HEADING-LINE
            HEADING-LINE: skip HEADING-LINE (POSITION/x - 1)
            change/part HEADING-LINE SPACEFILL to-string FIELDNAME POSITION/y POSITION/y 
        ]
        HEADING-LINE: head HEADING-LINE
        HEADING-LINE: trim/tail HEADING-LINE 
;;  -- Make a line of hyphens under each column heading.
        HYPHEN-LINE: copy ""
        loop 256 [append HYPHEN-LINE " "]
        foreach [FIELDNAME POSITION] FIELDS [
            HYPHEN-LINE: head HYPHEN-LINE
            HYPHEN-LINE: skip HYPHEN-LINE (POSITION/x - 1) 
            change/part HYPHEN-LINE HYPHENS POSITION/y POSITION/y
        ]
        HYPHEN-LINE: head HYPHEN-LINE
        HYPHEN-LINE: trim/tail HYPHEN-LINE
;;  -- Put heading lines into data area.
        append FILE-DATA SITE-NAME
        append FILE-DATA ""
        append FILE-DATA REPORT-TITLE
        append FILE-DATA ""
        append FILE-DATA HEADING-LINE
        append FILE-DATA HYPHEN-LINE
        append FILE-DATA "" 
    ]

;; [---------------------------------------------------------------------------]
;; [ Close the file by writing the data block to disk.                         ]
;; [---------------------------------------------------------------------------]

    CLOSE-OUTPUT: does [
        WRITE/LINES FILE-ID FILE-DATA
    ]

;; [---------------------------------------------------------------------------]
;; [ Write a print line.                                                       ]
;; [ The operator has set the words in RECORD to values.                       ]
;; [---------------------------------------------------------------------------]

    WRITE-RECORD: does [
        PRINT-LINE: copy ""
        loop 256 [append PRINT-LINE " "]
        foreach [FIELDNAME POSITION] FIELDS [
            PRINT-LINE: head PRINT-LINE
            PRINT-LINE: skip PRINT-LINE (POSITION/x - 1)
            change/part PRINT-LINE SPACEFILL RECORD/:FIELDNAME POSITION/y POSITION/y
        ]
        PRINT-LINE: head PRINT-LINE
        PRINT-LINE: trim/tail PRINT-LINE
        append FILE-DATA PRINT-LINE
    ]
]

;; -----------------------------------------------------------------------------

