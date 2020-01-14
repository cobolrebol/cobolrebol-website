REBOL [
    Title: "Functions for viewing a CSV file"
]

;; [---------------------------------------------------------------------------]
;; [ This is a module of functions for browsing any CSV file in a particular   ]
;; [ format, creating words and values from a csv file.                        ]
;; [ to be more specific, we start with a csv file that has a line of          ]
;; [ headings as the first line.  Each word in the line of headings            ]
;; [ is going to be the name of the corresponding item in each following       ]
;; [ record of the csv file.  For example:                                     ]
;; [     name,address,birthdate                                                ]
;; [     "John Smith","1800 W Old Shakopee Rd",01-JAN-2000                     ]
;; [     "Jane Smith","2100 1ST Ave",01-FEB-1995                               ]
;; [     "Jared Smith",3500 2ND St",01-MAR-1998                                ]
;; [ The above text file is like a little data file.                           ]
;; [ We will "open" the file by performing some function, and then we          ]
;; [ will "read" "records" from the file.                                      ]
;; [ Every time we read a record, the words 'name, 'address, 'birthdate        ]
;; [ will have, as values, the values from the record we just read.            ]
;; [ In other words, when we "read" the first record, the following            ]
;; [ situation will exist:                                                     ]
;; [     name = "John Smith"                                                   ]
;; [     address = "1800 W Old Shakopee Rd"                                    ]
;; [     birtdhdate = 01-JAN-2000                                              ]
;; [ Then, when read the next record, those same words of 'name, 'address,     ]
;; [ and 'birthdate will refer to the values from the second record.           ]
;; [ And so on to the end of the file.                                         ]
;; [ Then, when we try to read beyond the end, we will get an indicator        ]
;; [ that we have reached the end of the file.                                 ]
;; [                                                                           ]
;; [ This module was designed as functions for viewing the contents of a file  ]
;; [ in a window, so there is the obvious function to display the window       ]
;; [ plus functions for reading the first, last, next, and previous            ]
;; [ data records.                                                             ]
;; [                                                                           ]
;; [ As an additional service, we want to provide the ability to rewrite       ]
;; [ a csv file after we make changes.  So, when we "open" a file, we also     ]
;; [ will copy the headings to an output area just in case we want to          ]
;; [ rewrite the file.  Then, we will provide a "write" procedure that will    ]
;; [ make a csv record out of the current data and append it to the output     ]
;; [ area.  A "close" procedure will write the output area to disk.            ] 
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These are the data items used to get the csv file into memeory,           ]
;; [ pick off the first record of column headings, and so on.                  ]
;; [---------------------------------------------------------------------------]

CSV-FILE: none          ;; Name of the file, will come from caller 
CSV-LINES: none         ;; The entire contents of the file
CSV-HEADINGS: none      ;; Words from the first line as strings
CSV-WORDS: none         ;; The words from the first line as words
CSV-WORDCOUNT: 0        ;; Number of heading words 
CSV-RECORD: none        ;; The current data record, in the CSV-READ procedure
CSV-VALUES: none        ;; The parsed values from a single data line
CSV-EOF: false          ;; End-of-file flag when we "read" beyond last "record"
CSV-LENGTH: 0           ;; Number of lines in the file, including heading line
CSV-COUNTER: 0          ;; Record counter as we move through the file
CSV-VAL-COUNTER: 0      ;; For stepping through values in one record
CSV-OUTPUT-LINES: none  ;; Copy of the input file, with modifications 
CSV-OUTPUT-FILE: none   ;; Name of output file
CSV-OUTPUT-REC: none    ;; One output record
CSV-COMMACOUNT: 0       ;; Used to NOT put comma after last field of record 
CSV-IN-FIELD: false     ;; Used in comma-replacement operation
CSV-COMMA-MARKER: "%C%" ;; Will replace comma temporarily before parsing
CSV-LIST-BLOCK: copy [] ;; Word-value pairs for the display list
CSV-LIST-START: 0       ;; Starting point for list display

;; [---------------------------------------------------------------------------]
;; [ We will need a function to clear the above items so that a calling        ]
;; [ program can read more than one file.                                      ]
;; [---------------------------------------------------------------------------]

CSV-CLEAR-WS: does [
    CSV-FILE: none     
    CSV-LINES: none    
    CSV-HEADINGS: none 
    CSV-WORDS: none    
    CSV-WORDCOUNT: 0 
    CSV-RECORD: none   
    CSV-VALUES: none   
    CSV-EOF: false     
    CSV-LENGTH: 0      
    CSV-COUNTER: 0     
    CSV-VAL-COUNTER: 0 
    CSV-OUTPUT-LINES: copy ""
    CSV-OUTPUT-FILE: none
    CSV-OUTPUT-REC: none 
    CSV-COMMACOUNT: 0 
    CSV-IN-FIELD: false
]

;; [---------------------------------------------------------------------------]
;; [ Procedure to "open" the file.  What does that mean?                       ]
;; [ Read the entire file into memory.  Parse the first line into a block      ]
;; [ of words.  Make a note of the number of lines in the file.                ]
;; [ Set up a counter so we can pick our way through the file and stop         ]
;; [ when we reach the last record.                                            ]
;; [ Since this module is designed for use inside another program,             ]
;; [ this function normally will be called with a file name as argument.       ]
;; [---------------------------------------------------------------------------]

CSV-OPEN: func [
    FILE-TO-OPEN      
] [
    CSV-CLEAR-WS
    CSV-FILE: FILE-TO-OPEN
    CSV-LINES: read/lines CSV-FILE
    CSV-LENGTH: length? CSV-LINES
    append CSV-OUTPUT-LINES first CSV-LINES   ;; preparation for possible writing 
    append CSV-OUTPUT-LINES newline
    CSV-HEADINGS: parse/all first CSV-LINES ","
    CSV-WORDS: copy []
    foreach CSV-HEADING CSV-HEADINGS [
        if not-equal? "" trim CSV-HEADING [
            append CSV-WORDS to-word trim CSV-HEADING
            CSV-WORDCOUNT: CSV-WORDCOUNT + 1
        ] 
    ]
    CSV-COUNTER: 1 
    CSV-EOF: false
    return CSV-EOF 
]

;; [---------------------------------------------------------------------------]
;; [ The (optional) procedure to "close" the file.  What does that mean?       ]
;; [ To mimic the idea of opening a file I-O, meaning that we can rewrite      ]
;; [ a record after we have read it, we can write the data we have read        ]
;; [ into an output area, which will be a copy of the input file (or at        ]
;; [ least those records we have chosen to write).  The "close" procedure      ]
;; [ will write that file to disk.  You have to specify a file name,           ]
;; [ which may be the same (which will be like "saving" the file) or may       ]
;; [ be different (which will be like "saving as."                             ]
;; [---------------------------------------------------------------------------]

CSV-CLOSE: func [
    FILE-TO-CLOSE
] [ 
    CSV-OUTPUT-FILE: FILE-TO-CLOSE
    write/lines CSV-OUTPUT-FILE CSV-OUTPUT-LINES
] 

;; [---------------------------------------------------------------------------]
;; [ Procedure to "read" the file.  What does this mean?                       ]
;; [ Obtain the next line.  This is determined by "picking" based on the       ]
;; [ record counter.  If the counter becomes bigger than the file size,        ]
;; [ that means we have reached the end of the file.                           ]
;; [ Parse the line into a block of strings.                                   ]
;; [ For each word in the block of column headings, set that word to the       ]
;; [ corresponding item parsed from the data.                                  ]
;; [ We have to be sure to return the value of CSV-EOF so any calling          ]
;; [ procedure can use CSV-EOF to decide when to quit processing.              ]
;; [ There is a special little thing we do with each line before parsing it.   ]
;; [ It is possible that the data could contain commas.  It is customary       ]
;; [ that in such situations the field is enclosed in quotes.                  ]
;; [ We will assume that our data follows this custom, and take steps to       ]
;; [ to handle the possibility of commas in the data.                          ]
;; [ Before we parse a line on commas, we will go through the line one         ]
;; [ character at a time.  When we hit the first quote, we will assume that    ]
;; [ we are entering a fields.  From then on, we will replace commas with      ]
;; [ special place holders.  When we hit the next quote, we will assume        ]
;; [ we have left the field and we will stop replacing commas.                 ]
;; [ The next quote takes us into a field, the next one out, next in, etc.     ]
;; [ When we are done replacing embedded commas, we parse the line on          ]
;; [ commas.  Then, as we load each field, for each string field we check      ]
;; [ for our place holder and replace it with a comma.                         ]
;; [---------------------------------------------------------------------------]

CSV-REPLACE-EMBEDDED-COMMAS: does [
    CSV-IN-FIELD: false
    foreach CHARACTER CSV-RECORD [
        either equal? CHARACTER {"} [
            either CSV-IN-FIELD [
                CSV-IN-FIELD: false
            ] [
                CSV-IN-FIELD: true
            ]
        ] [
            if CSV-IN-FIELD [
                replace CHARACTER "," CSV-COMMA-MARKER
            ] 
        ]
    ]
]

;;  -- The reading procedures are not the best REBOL.
;;  -- We assume that CSV-COUNTER contains a valid value for the position 
;;  -- in the file of the desired record.  
;;  -- The read first/next/prev/last procedures adjust the counter and
;;  -- the call CSV-READ-SPECIFIC.
;;  -- CSV-READ-SPECIFIC also will build up CSV-LIST-BLOCK which is the
;;  -- data source for the list in the viewing window.

CSV-READ-SPECIFIC: does [
    CSV-EOF: false
    CSV-RECORD: pick CSV-LINES CSV-COUNTER
    CSV-REPLACE-EMBEDDED-COMMAS
    CSV-VALUES: parse/all CSV-RECORD ","
    CSV-VAL-COUNTER: 0
    foreach CSV-WORD CSV-WORDS [
        CSV-VAL-COUNTER: CSV-VAL-COUNTER + 1
        TEMP-VAL: pick CSV-VALUES CSV-VAL-COUNTER
        if equal? string! type? TEMP-VAL [
            replace/all TEMP-VAL CSV-COMMA-MARKER ","
        ] 
        either TEMP-VAL [
            set CSV-WORD trim TEMP-VAL                            
        ] [
            set CSV-WORD TEMP-VAL
        ]
    ]
;;  -- Must produce a block of blocks for the list style. 
;;  -- The block can contains REBOL words, and these words still will
;;  -- have their values.  This is part of the beauty of REBOL. 
    CSV-LIST-BLOCK: copy []
    foreach CSV-WORD CSV-WORDS [
        CSV-TEMP-BLOCK: copy []
        append CSV-TEMP-BLOCK to-string :CSV-WORD
        append CSV-TEMP-BLOCK get CSV-WORD
        append/only CSV-LIST-BLOCK CSV-TEMP-BLOCK
    ]
    return CSV-EOF 
]

CSV-READ-FIRST: does [
    CSV-COUNTER: 2
    CSV-READ-SPECIFIC
]

CSV-READ-NEXT: does [
    CSV-COUNTER: CSV-COUNTER + 1
    if (CSV-COUNTER > CSV-LENGTH) [
        CSV-COUNTER: CSV-LENGTH
        CSV-EOF: true
        return CSV-EOF 
    ]
    CSV-READ-SPECIFIC
]

CSV-READ-PREV: does [
    CSV-COUNTER: CSV-COUNTER - 1
    if (CSV-COUNTER < 2) [
        CSV-COUNTER: 2
        CSV-EOF: true
        return CSV-EOF
    ]
    CSV-READ-SPECIFIC
]

CSV-READ-LAST: does [
    CSV-COUNTER: CSV-LENGTH
    CSV-READ-SPECIFIC
]

;; [---------------------------------------------------------------------------]
;; [ Procedure to "write" the file.  What does this mean?                      ]
;; [ We are not really writing the file.  We are formatting the current data   ]
;; [ into a csv record and appending it to an output area.                     ]
;; [ If we do a "write" procedure for every "read" procedure, we will,         ]
;; [ in effect, copy the input file.  If we read the input, and then maybe     ]
;; [ or maybe not write to the output file, we will, in effect, filter the     ]
;; [ input file.  This is not quite like the COBOL operation of opening        ]
;; [ a file for input and output.  In COBOL, you could read a record, and      ]
;; [ then maybe or maybe not rewrite it, and at the end, you would have the    ]
;; [ same number of records in the file and maybe some of them would be        ]
;; [ altered.  Here, if you don't write the file, you don't get a record       ]
;; [ into the file, and when you close it you either write over the input      ]
;; [ file if you use the same name, or make a copy if you close under a        ]
;; [ different name.                                                           ]
;; [ Note that performing this procedure makes no sense if you don't first     ]
;; [ perform CSV-READ to read a record.                                        ]
;; [---------------------------------------------------------------------------]

CSV-WRITE: does [
    CSV-OUTPUT-REC: copy ""
    CSV-COMMACOUNT: 0 
    foreach CSV-WORD CSV-WORDS [
        append CSV-OUTPUT-REC mold get CSV-WORD ;; strings might contain commas
        CSV-COMMACOUNT: CSV-COMMACOUNT + 1 
        if (CSV-COMMACOUNT < CSV-WORDCOUNT) [
            append CSV-OUTPUT-REC ","
        ]    
    ]
    append CSV-OUTPUT-LINES CSV-OUTPUT-REC
    append CSV-OUTPUT-LINES newline
] 

;; [---------------------------------------------------------------------------]
;; [ Procedures for the buttons on the viewing window below.                   ]
;; [---------------------------------------------------------------------------]

BUTTON-FIRST: does [
    CSV-READ-FIRST
    show CSV-FIELD-LIST
    set-face CSV-LINE-NO to-string CSV-COUNTER
]

BUTTON-PREV: does [
    CSV-READ-PREV
    either CSV-EOF [
        alert "At the beginning"
        exit
    ] [
        show CSV-FIELD-LIST
        set-face CSV-LINE-NO to-string CSV-COUNTER
    ]
]

BUTTON-NEXT: does [
    CSV-READ-NEXT
    either CSV-EOF [
        alert "At the end"
        exit
    ] [
        show CSV-FIELD-LIST
        set-face CSV-LINE-NO to-string CSV-COUNTER
    ]
]

BUTTON-LAST: does [
    CSV-READ-LAST
    show CSV-FIELD-LIST
    set-face CSV-LINE-NO to-string CSV-COUNTER
]

;;  -- Searching takes advantage of the fact that we can put words
;;  -- in the drop-down, select one of those words, and then use
;;  -- the "get" function to get the value of the selected word. 
;;  -- This is the handiness of an interpreted language.


BUTTON-SEARCH: does [
    if not CSV-SEARCH-ITEMS/text [
        alert "No search column selected"
        exit
    ]
    CSV-READ-FIRST
    until [
        if equal? CSV-SEARCH-VALUE/text (get CSV-SEARCH-ITEMS/text) [
            show CSV-FIELD-LIST
            set-face CSV-LINE-NO to-string CSV-COUNTER
            exit
        ]
        CSV-READ-NEXT
    ]
    alert "Not found" 
]

BUTTON-SEARCH-AHEAD: does [
    if not CSV-SEARCH-ITEMS/text [
        alert "No search column selected"
        exit
    ]
;;  -- Read ahead from where we are. 
    until [
        if equal? CSV-SEARCH-VALUE/text (get CSV-SEARCH-ITEMS/text) [
            show CSV-FIELD-LIST
            set-face CSV-LINE-NO to-string CSV-COUNTER
            exit
        ]
        CSV-READ-NEXT
    ]
    alert "Not found" 
]

BUTTON-SEARCH-BACK: does [
    if not CSV-SEARCH-ITEMS/text [
        alert "No search column selected"
        exit
    ]
;;  -- Read backwards from where we are. 
    until [
        if equal? CSV-SEARCH-VALUE/text (get CSV-SEARCH-ITEMS/text) [
            show CSV-FIELD-LIST
            set-face CSV-LINE-NO to-string CSV-COUNTER
            exit
        ]
        CSV-READ-PREV ;; Returns EOF when we get to the beginning.
    ]
    alert "Not found" 
]

BUTTON-EXPORT-REC: does [
    CSV-WRITE
    alert "OK."
]

BUTTON-SAVE-EXPORTED: does [
    either CSV-SAVE-ID: request-file/only/save/title "Save to this file" "Save as" [
        CSV-CLOSE CSV-SAVE-ID
    ] [
        alert "No save file ID requested."
    ]    
]

;; [---------------------------------------------------------------------------]
;; [ This is the viewing window for the data in the file.                      ]
;; [ Remember, the "supply" function is executed for each "cell" in the list.  ]
;; [ In this example of a list of two columns and any number of rows,          ]
;; [ the supplied variables "count" and "index" will vary this way:            ]
;; [ 1-1, 1-2, 2-1, 2-2, 3-1, 3-2, and so on.                                  ]
;; [---------------------------------------------------------------------------]

CSV-WINDOW: [
    across
    CSV-WIN-FILE: text 600 (to-string CSV-FILE) font [size: 18 shadow: none]
    return
    CSV-FIELD-LIST: list 600x600 [
            across 
            text 200
            text 400
        ]
        supply [
;;;;;;;;;;  either even? count [face/color: white] [face/color: tan] ;; looks bad
            count: count + CSV-LIST-START
            if none? PICKED-ROW: pick CSV-LIST-BLOCK count [face/text: none exit]
            face/text: pick PICKED-ROW index
        ]
    slider 20x600 [
        CSV-LIST-START: (length? CSV-LIST-BLOCK) * value
        show CSV-FIELD-LIST
    ]
    return
    text 150 "File line number" font [size: 16 style 'bold]
    CSV-LINE-NO: text 50 (to-string CSV-COUNTER) font [size: 16 style 'bold]
    return
    text 80 "Search" font [size: 14 style 'bold] 
    CSV-SEARCH-ITEMS: drop-down 200 data CSV-WORDS ;; We can put word in a drop-down.
    text 40 "for" font [size: 14 style 'bold']
    CSV-SEARCH-VALUE: field 300
    return
    button 150 "Search" [BUTTON-SEARCH]
    button 150 "Search ahead" [BUTTON-SEARCH-AHEAD]
    button 150 "Search back" [BUTTON-SEARCH-BACK] 
    return
    button "First" [BUTTON-FIRST]
    button "Prev"  [BUTTON-PREV]
    button "Next"  [BUTTON-NEXT]
    button "Last"  [BUTTON-LAST]
    return
    button 200 "Export current record" [BUTTON-EXPORT-REC]
    button 200 "Save exported records" [BUTTON-SAVE-EXPORTED]
    return
    button "Quit"  [quit] 
    button "Debug" [halt]
]
     
;; Uncomment to test.
;; This shows the order in which the above functions should be used:
;; FIRST open the file, THEN read a record to get some data,
;; THEN create the window with the "layout" function, 
;; THEN view the window.  

;write/lines %testcsv.csv {FIELD1,FIELD2,FIELD3
;VALUE-1-1,VALUE-1-2,VALUE-1-3
;VALUE-2-1,VALUE-2-2,VALUE-2-3
;VALUE-3-1,VALUE-3-2,VALUE-3-3}
;CSV-OPEN %testcsv.csv
;CSV-READ-FIRST
;view layout CSV-WINDOW

