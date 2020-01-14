REBOL [
    Title: "COBOL source file cross reference"
    Purpose: {This program makes a cross reference of data names in
    a COBOL source file, with the line numbers that contain those
    data names.}
]

;; [---------------------------------------------------------------------------]
;; [ This is mainly a demo program, although it would be useful if one         ]
;; [ still used COBOL.  It parses each line, and for each token it tests       ]
;; [ to see if it is COBOL data name, and if it is, it notes the data name     ]
;; [ and the line number (the actual line number, not the line number in       ]
;; [ columns 1-6), and eventually produces a report of all the lines on        ]
;; [ which each data name appears.                                             ]
;; [ Because of its "demo" nature, it has some flaws/features.                 ]
;; [ A literal will be parsed into individual words, and those words will      ]
;; [ show up in the final report.  No effort is being made to fix that         ]
;; [ because the program served its purpose as it is.                          ]
;; [ The formatting of the report is primitive but adequate.                   ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ We will use other modules to check tokens to decide if they are           ]
;; [ data names, and to assemble them into an intermediate format for          ]
;; [ building the cross reference.                                             ]
;; [ We also use a separate module for formatting the cross reference          ]
;; [ report.                                                                   ]
;; [---------------------------------------------------------------------------]

do %COBreserved.r
do %COBword.r 
do %DupCheck.r
do %glb.r

;; [---------------------------------------------------------------------------]
;; [ Here is an easy way to turn on/off the debugging displays.                ]
;; [---------------------------------------------------------------------------]

DEBUG: false 
DEBUG-FILE: %COBxref-trace.txt
if DEBUG [
    if exists? DEBUG-FILE [
        delete DEBUG-FILE
    ]
    write/append DEBUG-FILE rejoin [
        "Trace for COBxref.r"
        newline
    ]
]


;; [---------------------------------------------------------------------------]
;; [ Request the name of a COBOL source file, and quit if none is supplied.    ]
;; [---------------------------------------------------------------------------]
if not COBOLSOURCE: request-file/only [
    alert "No file selected"
    quit
] 

;; [---------------------------------------------------------------------------]
;; [ Bring the whole file into memory as a block of lines.                     ]
;; [---------------------------------------------------------------------------]

SOURCELINES: read/lines COBOLSOURCE
LINENO: 0

;; [---------------------------------------------------------------------------]
;; [ Process each line.  Some newer COBOL compilers don't expect the           ]
;; [ old-style fixed-format lines, so we won't worry about that.               ]
;; [ All we care about is finding paragraph names and data names,              ]
;; [ so we will just parse each line and pick off those items that ARE         ]
;; [ paragraph names or data names.  The rest we can ignore.                   ]
;; [ We will use the DupCheck module to assemble the data names and their      ]
;; [ line numbers into an intermediate format for reporting.                   ]
;; [---------------------------------------------------------------------------]

foreach LINE SOURCELINES [
    LINENO: LINENO + 1
    if DEBUG [
        write/append DEBUG-FILE reduce [LINENO ":" LINE newline]
    ]
    LINESIZE: length? LINE
    COL1: copy ""
    COL7: copy ""
    if (LINESIZE > 0) [
        COL1: GLB-SUBSTRING LINE 1 1
    ]
    if (LINESIZE > 7) [
        COL7: GLB-SUBSTRING LINE 7 7
    ]
    if (COL1 <> "*") and (COL7 <> "*") [     
        TOKENS: copy []
        TOKENS: parse LINE " ,."
        foreach TOKEN TOKENS [
            if DEBUG [
                write/append DEBUG-FILE reduce ["Checking " TOKEN newline]   
            ]
            if not COBRESERVED/RESERVED? TOKEN [
                if DEBUG [
                    write/append DEBUG-FILE reduce [TOKEN " is not reserved" newline]
                ]
                if COBWORD/DATANAME? TOKEN [
                    if DEBUG [
                        write/append DEBUG-FILE reduce [TOKEN " is a data name" newline]
                    ]
                    append DUPCHECK/INBLOCK TOKEN
                    append DUPCHECK/INBLOCK LINENO
                ] 
            ]
        ]
    ]
]
DUPCHECK/LIMIT: 0
DUPCHECK/FIND-DUPLICATES
if DEBUG [
    save %COBxref-debug.txt DUPCHECK/OUTBLOCK  ;; for debugging 
]

;; [---------------------------------------------------------------------------]
;; [ At this point the cross reference is basically built and it in            ]
;; [ DUPCHECK/OUTBLOCK.  Now we just have to produce some nice output.         ]
;; [ This will crash if the source file name lacks a dot-extension, but this   ]
;; [ is a demo so we let it go.                                                ]
;; [---------------------------------------------------------------------------]

REP-FILE-ID: to-file rejoin [
    GLB-BASE-FILENAME second split-path COBOLSOURCE
    "-xref.txt"
]
REP-DATA: ""
REP-LINE: ""
    
foreach [TOKEN LINENUMS] DUPCHECK/OUTBLOCK [
    REP-LINE: copy ""
    append REP-LINE rejoin [
        GLB-SPACEFILL TOKEN 30
        GLB-FILLER 5
        LINENUMS
        newline
    ]
    append REP-DATA REP-LINE
]
write REP-FILE-ID REP-DATA

either DEBUG [
    print "Done."
    halt
] [
    alert "Done."
]

