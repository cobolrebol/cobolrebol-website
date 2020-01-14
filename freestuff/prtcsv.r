REBOL [
    Title: "PRTCSV: Format print lines for a csv file"
]

;; [---------------------------------------------------------------------------]
;; [ This is an object that can be used to define a csv file that will be      ]
;; [ used as a "report."  The general plan of action is that a program can     ]
;; [ use this module to put reportable data into a csv file, and the           ]
;; [ operator of the program then will use a popular spreadsheet program       ]
;; [ to view the file and optionally put it on paper with the spreadsheet      ]
;; [ programs own "print" feature.  In other words, this module is a way to    ]
;; [ handle "printing" in REBOL by ignoring the problem and letting            ]
;; [ someone else (the spreadsheet program) do the work.                       ]
;; [                                                                           ]
;; [ To use:                                                                   ]
;; [                                                                           ]
;; [ Make an instance of this object with:                                     ]
;; [     MYCSVREPORT: make PRTCSV [                                            ]
;; [         FILEID: file-name                                                 ]
;; [         COLUMNS: [column-name-list] ]                                     ]
;; [     ]                                                                     ]
;; [ The reason we make an instance of an object is so that we can use this    ]
;; [ one module to produce more than one report in a single program.           ]
;; [ The column-name-list is a block of words that will become the column      ]
;; [ headings of the csv file as well as words that you may set to values      ]
;; [ to get those values into the output file.                                 ]
;; [                                                                           ]
;; [ For example, say you want to produce a csv file with columns for          ]
;; [ NAME, ADDRESS, and PHONE.  You also want those words to be column         ]
;; [ headings.  (Note that a common way to use a spreadsheet is a little       ]
;; [ "data file" where each row is a record, each column is a field, and       ]
;; [ the first row contains the "field names.")  You also want to create an    ]
;; [ output file called csvreport.csv.                                         ] 
;; [ You would code this:                                                      ]
;; [     CSVREPORT: make PRTCSV [                                              ]
;; [         FILEID: %csvreport.csv                                            ]
;; [         COLUMNS: [                                                        ]
;; [             NAME                                                          ]
;; [             ADDRESS                                                       ]
;; [             PHONE                                                         ]
;; [         ]                                                                 ]
;; [     ]                                                                     ]
;; [ Note that CSVREPORT is a name that you make up, NAME, ADDRESS, and PHONE  ]
;; [ are names that you make up, but PRTCSV is the name of the model           ]
;; [ object, COLUMNS is the name of a data item in that model object,          ]
;; [ and FILEID is a word that specifies the name of the file,                 ]
;; [ so PRTCSV, COLUMNS, and FILEID are words that must be use as they are;    ]
;; [ they are not words that you would make up.  By the way, make sure         ]
;; [ the FILEID is a REBOL file name with the percent sigh in front.           ]
;; [                                                                           ]
;; [ After you have done the above, you must perform a procedure before you    ]
;; [ can "print" anything.  You must call the function:                        ]
;; [     CSVREPORT/OPEN-OUTPUT                                                 ]
;; [ What this procedure will do is initialize some areas, plus create a       ]
;; [ sub-object called RECORD, and inside RECORD will be words that you        ]
;; [ may set to values.  These words are the ones you specified when you       ]
;; [ created the instance of the object.  Using the above example, you will    ]
;; [ have available the following data items:                                  ]
;; [     CSVREPORT/RECORD/NAME                                                 ]
;; [     CSVREPORT/RECORD/ADDRESS                                              ]
;; [     CSVREPORT/RECORD/PHONE                                                ]
;; [ The above words are words you will set to values, for each row that       ]
;; [ you want to put into the output file.                                     ]
;; [                                                                           ]
;; [ When you want to "print" some data, you set the words you created to      ]
;; [ values, and perform a procedure to create a row in the output file.       ]
;; [ That procedure is called:                                                 ]
;; [     CSVREPORT/WRITE-RECORD                                                ]
;; [ Now the obvious question is, what is the data type of each of those       ]
;; [ words, so that I know what kind of values to set them to.                 ]
;; [ The answer is that they all are strings.  Why is that?                    ]
;; [ Reason number one is that this is a basic module and it is easiest to     ]
;; [ just use strings.  There also is another reason.  If we had some          ]
;; [ method of assigning types at the time the words are created, then we      ]
;; [ might end up with some situation where some sort of conversion was        ]
;; [ being done at a low level, and something might not work, and one could    ]
;; [ end up wrestling with this module to make it work.  Generally, we like    ]
;; [ to follow the principle of moving decisions up and moving work down,      ]
;; [ which in practice means that this module will just "do what it is told    ]
;; [ and not ask questions."                                                   ]
;; [                                                                           ]
;; [ When you are done "printing," the data you have "printed" will be in      ]
;; [ memory, so you must put it on disk.  You perform the procedure:           ]
;; [     CSVREPORT/CLOSE-OUTPUT                                                ]
;; [ The result will be that a file called csvreport.csv will come into        ]
;; [ existence.  The first line of the file will contain:                      ]
;; [     NAME,ADDRESS,PHONE                                                    ]
;; [ and the following lines will contain whatever data you specified for      ]
;; [ those fields as many times as you specified it.  The data fields          ]
;; [ will be quoted and separated by commas.                                   ]
;; [                                                                           ]
;; [ Remember that the purpose of this module is NOT to create a data file     ]
;; [ for some sort of data manipulation, but rather to make a report.          ]
;; [---------------------------------------------------------------------------]

PRTCSV: make object! [

;; [---------------------------------------------------------------------------]
;; [ Items the caller must set.                                                ]
;; [---------------------------------------------------------------------------]

    FILEID: %csvreport.csv
    COLUMNS: []

;; [---------------------------------------------------------------------------]
;; [ Working items.                                                            ]
;; [---------------------------------------------------------------------------]

    FILE-DATA: []
    RECORD: none
    COLUMN-COUNT: 0 
    COLUMN-NUMBER: 0

;; [---------------------------------------------------------------------------]
;; [ Open the file.                                                            ]
;; [ Using the supplied column names, construct the first line of the          ]
;; [ output file, and create a record with words that the caller can set       ]
;; [ to values.                                                                ]
;; [---------------------------------------------------------------------------]

    OPEN-OUTPUT: does [  
        COLUMN-NUMBER: length? COLUMNS   
        FILE-DATA: copy []
        HEADING-LINE: copy ""
        COLUMN-COUNT: 0
        RECORD: make object! []
        foreach COLUMN-NAME COLUMNS [
            COLUMN-COUNT: COLUMN-COUNT + 1
            append HEADING-LINE to-string COLUMN-NAME
            if lesser? COLUMN-COUNT COLUMN-NUMBER [
                append HEADING-LINE ","
            ]
            RECORD: make RECORD compose [
                (to-set-word COLUMN-NAME) {""}  
            ]
        ]
        append FILE-DATA HEADING-LINE
    ]

;; [---------------------------------------------------------------------------]
;; [ Close the file.                                                           ]
;; [ Write to disk the lines we have been generating.                          ]
;; [---------------------------------------------------------------------------]

    CLOSE-OUTPUT: does [
        write/lines FILEID FILE-DATA
    ]

;; [---------------------------------------------------------------------------]
;; [ Write a record.                                                           ]
;; [ Generate a text line from the words supplied by the caller.               ]
;; [---------------------------------------------------------------------------]

    WRITE-RECORD: does [
        COLUMN-COUNT: 0
        DATA-LINE: copy ""
        foreach COLUMN-NAME COLUMNS [
            append DATA-LINE mold RECORD/:COLUMN-NAME ;; mold adds quotes
            COLUMN-COUNT: COLUMN-COUNT + 1
            if lesser? COLUMN-COUNT COLUMN-NUMBER [
                append DATA-LINE ","
            ]
        ]
        append FILE-DATA DATA-LINE
    ]

]  ;; End of object. 

