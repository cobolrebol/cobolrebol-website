REBOL [
    Title: "Dumpall"
]

;; [---------------------------------------------------------------------------]
;; [ This is a program for making a hex dump of any file.                      ]
;; [ It reads the whole file in binary form and prints out the hex values      ]
;; [ of the data.                                                              ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Function to pad strings in various ways.                                  ]
;; [---------------------------------------------------------------------------]
GLB-FILLER: func [
    "Return a string of a given number of spaces"
    SPACE-COUNT [integer!]
    /local FILLER 
] [
    FILLER: copy ""
    loop SPACE-COUNT [
        append FILLER " "
    ]
    return FILLER
]
GLB-ZEROFILL: func [
    "Convert number to string, pad with leading zeros"
    INPUT-STRING
    FINAL-LENGTH
    /local ALL-DIGITS 
           LENGTH-OF-ALL-DIGITS
           NUMER-OF-ZEROS-TO-ADD
           REVERSED-DIGITS 
           FINAL-PADDED-NUMBER
] [
    ALL-DIGITS: copy ""
    ALL-DIGITS: trim/with to-string INPUT-STRING trim/with 
        copy to-string INPUT-STRING "0123456789"
    LENGTH-OF-ALL-DIGITS: length? ALL-DIGITS
    if (LENGTH-OF-ALL-DIGITS <= FINAL-LENGTH) [
        NUMBER-OF-ZEROS-TO-ADD: (FINAL-LENGTH - LENGTH-OF-ALL-DIGITS)
        REVERSED-DIGITS: copy ""
        REVERSED-DIGITS: reverse ALL-DIGITS    
        loop NUMBER-OF-ZEROS-TO-ADD [
            append REVERSED-DIGITS "0"
        ]
        FINAL-PADDED-NUMBER: copy ""
        FINAL-PADDED-NUMBER: GLB-SUBSTRING reverse REVERSED-DIGITS 1 FINAL-LENGTH
    ]
    return FINAL-PADDED-NUMBER
]
GLB-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

;; [---------------------------------------------------------------------------]
;; [ This is the window that will appear as a confirmation that we are done.   ]
;; [ It will show the data in hex format, and have buttons for some options    ]
;; [ for what to do with this now-decoded data.                                ]
;; [---------------------------------------------------------------------------]
TFACE-OUT: center-face layout [
    across
    h3 "Program Output" 
    return
    space 0
    T1: text 800x600 wrap green black font-name font-fixed 
    S1: scroller 16x600 [TFACE-SCROLL T1 S1]
    return
    pad 0x5 
    space 5
    button "Close" [TFACE-CLOSE T1 S1]
    button 150 "Write dump.txt" [TFACE-WRITE]
    button 150 "Write printable" [TFACE-WRITE-CHAR]
]
TFACE-SCROLL: func [TXT BAR][
    TXT/para/scroll/y: negate BAR/data *
        (max 0 TXT/user-data - TXT/size/y)
    show TXT
]
TFACE-SHOW-TEXT: func [TFACE-TEXT-IN][
    T1/text: TFACE-TEXT-IN  
    T1/para/scroll/y: 0
    S1/data: 0
    T1/line-list: none
    T1/user-data: second size-text T1
    S1/redrag T1/size/y / T1/user-data
    view TFACE-OUT
]
TFACE-CLOSE: func [TXT BAR] [
    unview
]
TFACE-WRITE: does [
    DUMP-FILE: %dump.txt
    write DUMP-FILE FULL-DUMP 
    alert "Done" 
] 
TFACE-WRITE-CHAR: does [
    DUMP-FILE: %dump.txt
    write DUMP-FILE PRINTABLE-DUMP
    alert "Done"
]

;; [---------------------------------------------------------------------------]
;; [ Get a file name and read it into memory in binary format.                 ]
;; [---------------------------------------------------------------------------]
FILE-ID: request-file/only
if not FILE-ID [
    alert "No file selected"
    quit
]
BINARY-DATA: read/binary FILE-ID 

;; [---------------------------------------------------------------------------]
;; [ Take a binary value for one byte and produce two bytes that are the       ]
;; [ hex representation, which are printable.                                  ]
;; [---------------------------------------------------------------------------]
HEX-VAL: func [
    BINARY-VAL
] [
    HEX-BYTE: copy ""
    HEX-BYTE: reverse copy/part reverse to-string to-hex BINARY-VAL 2
]

;; [---------------------------------------------------------------------------]
;; [ Take a binary value for one byte and produce one byte that is the         ]
;; [ ascii character for that binary value.  If the result is not a            ]
;; [ printable character, return a dot.                                        ]
;; [---------------------------------------------------------------------------]
CHAR-VAL: func [
    BINARY-VAL
] [
    CHAR-BYTE: copy ""
    either ((BINARY-VAL > 31) and (BINARY-VAL < 127)) [
        CHAR-BYTE: copy to-string to-char BINARY-VAL
    ] [
        CHAR-BYTE: copy "."
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Go through the binary data one byte at a time and convert each byte       ]
;; [ to a two-character hex representation and a one-character printable       ]
;; [ character.                                                                ]
;; [---------------------------------------------------------------------------]
HEX-DATA: copy ""
CHAR-DATA: copy ""
foreach BCHAR BINARY-DATA [
    append HEX-DATA HEX-VAL BCHAR
    append CHAR-DATA CHAR-VAL BCHAR
]

;; [---------------------------------------------------------------------------]
;; [ With the binary data translated into two forms, format those two          ]
;; [ forms into text lines that will look useful when displayed in a           ]
;; [ fixed-format font.  We will display LINE-LENGTH chunks in                 ]
;; [ two-lines, the hex line on top and the printable line beneath.            ]
;; [ The FULL-DUMP is lines of text, a hex line followed by an ascii line,     ]
;; [ and is what we show when we pop up the viewing window.                    ]
;; [ In anticipation of other needs, PRINTABLE-DUMP is just the ascii lines.   ]
;; [ Sometimes a person might want to view the printable characters in a       ]
;; [ binary file if all the non-printable characters can be replaced with      ]
;; [ something printable.                                                      ]
;; [---------------------------------------------------------------------------]
FILE-SIZE: length? CHAR-DATA
START-POS: 1
END-POS: length? CHAR-DATA
CHAR-COUNT: 0 
HEX-PICK-1: 0
HEX-PICK-2: 0  
FULL-DUMP: copy ""
PRINTABLE-DUMP: copy "" 
HEX-LINE: copy ""
CHAR-LINE: copy ""
PRINTABLE-LINE: copy ""
LINE-LENGTH: 50
LINE-COUNT: 0   ;; for counting characters placed on the line so far
LINE-START-COUNT: 1 ;; character number on beginning of current line 
LINE-START-COUNT: START-POS 
for CHAR-COUNT START-POS END-POS 1 [
    LINE-COUNT: LINE-COUNT + 1
    if (LINE-COUNT > LINE-LENGTH) [
        LINE-COUNT: 1
        append FULL-DUMP GLB-ZEROFILL LINE-START-COUNT 6
        append FULL-DUMP ": "
        append FULL-DUMP HEX-LINE
        append FULL-DUMP newline
        HEX-LINE: copy ""
        append FULL-DUMP GLB-FILLER 8
        append FULL-DUMP CHAR-LINE
        append FULL-DUMP newline
        CHAR-LINE: copy ""
        append PRINTABLE-DUMP GLB-ZEROFILL LINE-START-COUNT 6
        append PRINTABLE-DUMP ": "
        append PRINTABLE-DUMP PRINTABLE-LINE
        append PRINTABLE-DUMP newline
        PRINTABLE-LINE: copy ""
        LINE-START-COUNT: CHAR-COUNT
    ]
    append CHAR-LINE CHAR-DATA/:CHAR-COUNT
    append CHAR-LINE " "
    HEX-PICK-1: ((CHAR-COUNT * 2) - 1)
    HEX-PICK-2: HEX-PICK-1 + 1
    append HEX-LINE HEX-DATA/:HEX-PICK-1
    append HEX-LINE HEX-DATA/:HEX-PICK-2
    append PRINTABLE-LINE CHAR-DATA/:CHAR-COUNT
]
if (LINE-COUNT > 0) [
    append FULL-DUMP GLB-ZEROFILL LINE-START-COUNT 6
    append FULL-DUMP ": "
    append FULL-DUMP HEX-LINE
    append FULL-DUMP newline
    append FULL-DUMP GLB-FILLER 8
    append FULL-DUMP CHAR-LINE
    append FULL-DUMP newline
    append PRINTABLE-DUMP GLB-ZEROFILL LINE-START-COUNT 6
    append PRINTABLE-DUMP ": "
    append PRINTABLE-DUMP PRINTABLE-LINE
    append PRINTABLE-DUMP newline
]

;; [---------------------------------------------------------------------------]
;; [ Write the formatted lines to a viewing window.                            ]
;; [ This file will not look right unless viewed in a fixed font.              ]
;; [---------------------------------------------------------------------------]

TFACE-SHOW-TEXT FULL-DUMP 

