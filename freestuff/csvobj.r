REBOL [
    Title: "CSV file object"
]

;; [---------------------------------------------------------------------------]
;; [ This is an adaptation of csvfile.r that makes a CSV object, so that       ]
;; [ a program can work with more than one csv file at a time by making        ]
;; [ copies of this object.                                                    ]
;; [---------------------------------------------------------------------------]

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
;; [     RECORD/name = "John Smith"                                            ]
;; [     RECORD/address = "1800 W Old Shakopee Rd"                             ]
;; [     RECORD/birtdhdate = 01-JAN-2000                                       ]
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

CSV: make object! [

;; [---------------------------------------------------------------------------]
;; [ These are the data items used to get the csv file into memeory,           ]
;; [ pick off the first record of column headings, and so on.                  ]
;; [---------------------------------------------------------------------------]

    FILE-ID: none       ;; Name of the file, will come from caller 
    FILE-LINES: none    ;; The entire contents of the file
    HEADINGS: none      ;; Words from the first line as strings
    HEADWORDS: none     ;; The words from the first line as words
    WORDCOUNT: 0        ;; Number of heading words 
    RECORD: none        ;; The current data record object, in the READ procedure
    VALUES: none        ;; The parsed values from a single data line
    EOF: false          ;; End-of-file flag when we "read" beyond last "record"
    LENGTH: 0           ;; Number of lines in the file, including heading line
    COUNTER: 0          ;; Record counter as we move through the file
    VAL-COUNTER: 0      ;; For stepping through values in one record
    OUTPUT-LINES: none  ;; Copy of the input file, with modifications 
    OUTPUT-FILE: none   ;; Name of output file
    OUTPUT-REC: none    ;; One output record
    COMMACOUNT: 0       ;; Used to NOT put comma after last field of record 
    IN-FIELD: false     ;; Used in comma-replacement operation
    COMMA-MARKER: "%C%" ;; Will replace comma temporarily before parsing

;; [---------------------------------------------------------------------------]
;; [ We will need a function to clear the above items so that a calling        ]
;; [ program can read more than one file.                                      ]
;; [---------------------------------------------------------------------------]

    CLEAR-WS: does [
        FILE-ID: none     
        FILE-LINES: none    
        HEADINGS: none 
        HEADWORDS: none    
        WORDCOUNT: 0 
        RECORD: none   
        VALUES: none   
        EOF: false     
        LENGTH: 0      
        COUNTER: 0     
        VAL-COUNTER: 0 
        OUTPUT-LINES: copy ""
        OUTPUT-FILE: none
        OUTPUT-REC: none 
        COMMACOUNT: 0 
        IN-FIELD: false
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

    CSVOPEN: func [
        FILE-TO-OPEN      
    ] [
        CLEAR-WS
        FILE-ID: FILE-TO-OPEN
        FILE-LINES: read/lines FILE-ID
        LENGTH: length? FILE-LINES
        append OUTPUT-LINES first FILE-LINES   ;; preparation for possible writing 
        append OUTPUT-LINES newline
        HEADINGS: parse/all first FILE-LINES ","
        HEADWORDS: copy []
        foreach HEADING HEADINGS [  ;; put all words from line 1 into a block
            if not-equal? "" trim HEADING [
                append HEADWORDS to-word trim HEADING
                WORDCOUNT: WORDCOUNT + 1
            ] 
        ]
        COUNTER: 1 
        EOF: false
        return EOF 
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

    CSVCLOSE: func [
        FILE-TO-CLOSE
    ] [ 
        OUTPUT-FILE: FILE-TO-CLOSE
        write/lines OUTPUT-FILE OUTPUT-LINES
    ] 

;; [---------------------------------------------------------------------------]
;; [ Procedure to "read" the file.  What does this mean?                       ]
;; [ Obtain the next line.  This is determined by "picking" based on the       ]
;; [ record counter.  If the counter becomes bigger than the file size,        ]
;; [ that means we have reached the end of the file.                           ]
;; [ Parse the line into a block of strings.                                   ]
;; [ For each word in the block of column headings, set that word to the       ]
;; [ corresponding item parsed from the data.                                  ]
;; [ We have to be sure to return the value of EOF so any calling              ]
;; [ procedure can use EOF to decide when to quit processing.                  ]
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
;; [ As for getting the data out to the caller, it is not quite a simple as    ]
;; [ setting words to values.  We will make an object, called RECORD,          ]
;; [ and load it up with repetitions of:                                       ]
;; [     <word><colon> <parsed-value>                                          ]
;; [ and the caller will refer to CSV/RECORD/<word>                            ]
;; [---------------------------------------------------------------------------]

    REPLACE-EMBEDDED-COMMAS: does [
        IN-FIELD: false
        foreach CHARACTER RECORD [
            either equal? CHARACTER {"} [
                either IN-FIELD [
                    IN-FIELD: false
                ] [
                    IN-FIELD: true
                ]
            ] [
                if IN-FIELD [
                    replace CHARACTER "," COMMA-MARKER
                ] 
            ]
        ]
    ]
    
    CSVREAD: does [
        COUNTER: COUNTER + 1
        if (COUNTER > LENGTH) [
            EOF: true
            return EOF 
        ]
        RECORD: pick FILE-LINES COUNTER
        REPLACE-EMBEDDED-COMMAS
        VALUES: parse/all RECORD ","
        VAL-COUNTER: 0
        RECORD: make object! [] ;; make an empty object
        foreach WORD HEADWORDS [
            VAL-COUNTER: VAL-COUNTER + 1 ;; point to next value
            TEMP-VAL: pick VALUES VAL-COUNTER ;; get next value
            if not TEMP-VAL [   ;; don't want to crash if no value found
                TEMP-VAL: copy ""
            ]
            if equal? string! type? TEMP-VAL [ ;; put back commas we removed
                replace/all TEMP-VAL COMMA-MARKER ","
            ] 
            RECORD: make RECORD compose [ ;; re-make RECORD adding to previous
                (to-set-word WORD) TEMP-VAL
            ]
        ]
        return EOF 
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
;; [ perform READ to read a record.                                            ]
;; [---------------------------------------------------------------------------]

    CSVWRITE: does [
        OUTPUT-REC: copy ""
        COMMACOUNT: 0 
        foreach WORD HEADWORDS [
            append OUTPUT-REC mold RECORD/:WORD ;; mold adds quotes
            COMMACOUNT: COMMACOUNT + 1              ;; in case value has commas
            if (COMMACOUNT < WORDCOUNT) [
                append OUTPUT-REC ","
            ]    
        ]
        append OUTPUT-LINES OUTPUT-REC
        append OUTPUT-LINES newline
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

    REPORT-HTML: ""
    
    REPORT-HEAD: func [
        REPORT-COL-NAMES
    ] [
        REPORT-HTML: copy ""
        append REPORT-HTML rejoin [
            {<table width="100%" border="1">}
            newline
            "<tr>"
            newline
        ]
        foreach REPORT-COL REPORT-COL-NAMES [
            append REPORT-HTML rejoin [
                "<th>"
                to-string REPORT-COL
                "</th>"
                newline
            ]
        ]
        append REPORT-HTML rejoin [
            "</tr>"
            newline
        ]
    ]

;; [---------------------------------------------------------------------------]
;; [ This function must be performed to close the table that we use for        ]
;; [ the report.  Note that the html string we are creating is only a table    ]
;; [ and not a full html page.  This is by design.                             ]
;; [---------------------------------------------------------------------------]

    REPORT-FOOT: does [
        append REPORT-HTML rejoin [
            "</table>"
            newline
        ]
    ] 

;; [---------------------------------------------------------------------------]
;; [ This function accepts a block of words which MUST BE words from the file. ]
;; [ It puts the values of those words into td elements and appends them to    ]
;; [ the html string.                                                          ]
;; [---------------------------------------------------------------------------]

    REPORT-LINE: func [
        REPORT-COL-NAMES
    ] [
        append REPORT-HTML rejoin [
            "<tr>"
            newline
        ]
        foreach REPORT-COL REPORT-COL-NAMES [
            append REPORT-HTML rejoin [
                "<td>"
                RECORD/:REPORT-COL
                "</td>"
                newline
            ]
        ]    
        append REPORT-HTML rejoin [
            "</tr>"
            newline
        ]
    ]
]

