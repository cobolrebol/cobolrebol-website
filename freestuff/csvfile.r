REBOL [
    Title: "Make a csv file easily readable"
]

;; [---------------------------------------------------------------------------]
;; [ This is a module for making it easy to read values in a csv file by       ]
;; [ creating words and values from a csv file.                                ]
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
;; [ will "read" "records" from the file until the end.                        ]
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

CSV-READ: does [
    CSV-COUNTER: CSV-COUNTER + 1
    if (CSV-COUNTER > CSV-LENGTH) [
        CSV-EOF: true
        return CSV-EOF 
    ]
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
    return CSV-EOF 
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
;; [ These are helper functions for reporting selected columns to              ]
;; [ to an html file.                                                          ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This function accepts a block of words, which usually are the column      ]
;; [ names from the file but need not be.  It converts each word to a string   ]
;; [ and emits the beginning of an html table with a row of table headers      ]
;; [ consisting of the supplied words.                                         ]
;; [---------------------------------------------------------------------------]

CSV-REPORT-HTML: ""

CSV-REPORT-HEAD: func [
    CSV-REPORT-COL-NAMES
] [
    CSV-REPORT-HTML: copy ""
    append CSV-REPORT-HTML rejoin [
        {<table width="100%" border="1">}
        newline
        "<tr>"
        newline
    ]
    foreach CSV-REPORT-COL CSV-REPORT-COL-NAMES [
        append CSV-REPORT-HTML rejoin [
            "<th>"
            to-string CSV-REPORT-COL
            "</th>"
            newline
        ]
    ]
    append CSV-REPORT-HTML rejoin [
        "</tr>"
        newline
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function must be performed to close the table that we use for        ]
;; [ the report.  Note that the html string we are creating is only a table    ]
;; [ and not a full html page.  This is by design.                             ]
;; [---------------------------------------------------------------------------]

CSV-REPORT-FOOT: does [
    append CSV-REPORT-HTML rejoin [
        "</table>"
        newline
    ]
] 

;; [---------------------------------------------------------------------------]
;; [ This function accepts a block of words which MUST BE words from the file. ]
;; [ It puts the values of those words into td elements and appends them to    ]
;; [ the html string.                                                          ]
;; [---------------------------------------------------------------------------]

CSV-REPORT-LINE: func [
    CSV-REPORT-COL-NAMES
] [
    append CSV-REPORT-HTML rejoin [
        "<tr>"
        newline
    ]
    foreach CSV-REPORT-COL CSV-REPORT-COL-NAMES [
        append CSV-REPORT-HTML rejoin [
            "<td>"
            get CSV-REPORT-COL
            "</td>"
            newline
        ]
    ]    
    append CSV-REPORT-HTML rejoin [
        "</tr>"
        newline
    ]
]

      
