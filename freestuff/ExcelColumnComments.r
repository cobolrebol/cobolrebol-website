REBOL [
    Title: "Add spreadsheet column names as comments"
    Purpose: {This is a little helper for tidying up source code.
    It takes lines on the clipboard, and scans each to find the    
    length of the longest.  Then it adds a comment to each line     
    which is a spreadsheet column name, that is, A, B, ... Z, 
    AA, AB... up to some reasonable length}
] 

;; [---------------------------------------------------------------------------]
;; [ This is a helper program for a very specific situation.                   ]
;; [ The situation is one of creating a csv file that is to be loaded into     ]
;; [ a popular spreadsheet program.  In the source code, we have lines of      ]
;; [ code for the data items going into the columns, and these data items      ]
;; [ occur in the source code in the same order as we want them in the         ]
;; [ spreadsheet.  To help keep track of what is going in which columns,       ]
;; [ we want to label the source code lines with in-line comments to mark      ]
;; [ the column number where each data item is expected to go, so that         ]
;; [ when we test the program and find that the data items are not in the      ]
;; [ expected columns because we made a mistake, we can find that mistake      ]
;; [ more easily.  In other words, the column number will be like this:        ]
;; [   A, B, C,...Z, AA, AB,...AZ, BA, BB, BC...BZ... and so on to a           ]
;; [ reasonable limit.  Our resulting source code will look like this:         ]
;; [   <word-01>: <value-01>     ;; A                                          ]
;; [   <word-02>: <value-01>     ;; B                                          ]
;; [   ...                                                                     ]
;; [   <word-26>: <value-01>     ;; Z                                          ]
;; [   <word-27>: <value-01>     ;; AA                                         ]
;; [   <word-28>: <value-01>     ;; AB                                         ]
;; [   ...                                                                     ]
;; [   <word-52>: <value-01>     ;; AZ                                         ]
;; [   <word-53>: <value-01>     ;; BA                                         ]
;; [   <word-54>: <value-01>     ;; BB                                         ]
;; [   ...                                                                     ]
;; [---------------------------------------------------------------------------]

LONGEST-LINE: 0   ;; Length of longest line found on clipboard. 

COLS: rejoin [
    "A B C D E F G H I J K L M N O P Q R S T U B W X Y Z "
    "AAABACADAEAFAGAHAIAJAKALAMANAOAPAQARASATAUAVAWAXAYAZ"
    "BABBBCBDBEBFBGBHBIBJBKBLBMBNBOBPBQBRBSBTBUBVBWBXBYBZ"
    "CACBCCCDCECFCGCHCICJCKCLCMCNCOCPCQCRCSCTCUCVCWCXCYCZ"
]

COL-PICKER: 0

RAW-LINES: read clipboard://
TEMP-LINES: parse/all RAW-LINES "^/"
CHANGED-LINES: copy "" 

;; -- Examine each line and find the longest. 
foreach LINE TEMP-LINES [
    LINESIZE: length? LINE           
    if greater? LINESIZE LONGEST-LINE [
        LONGEST-LINE: LINESIZE
    ]
]

;; -- Pad each line out to the size of the longest and
;; -- add a comment with the column heading. 
foreach LINE TEMP-LINES [
    BLANKS-TO-ADD: (LONGEST-LINE - (length? LINE) + 1)
;;; print ["Add " BLANKS-TO-ADD " to " LINE]
    insert/dup tail LINE " " BLANKS-TO-ADD
    insert tail LINE ";; "
    insert tail LINE copy/part skip COLS COL-PICKER 2
    COL-PICKER: COL-PICKER + 2
]

;; -- Put the modified lines back on the clipboard.
foreach LINE TEMP-LINES [
    append CHANGED-LINES rejoin [
        LINE
        newline
    ]
]
write clipboard:// CHANGED-LINES
alert "Clipboard loaded"
;halt

