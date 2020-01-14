REBOL [
    Title: "Generate lookup table from csv"
    Purpose: {Request the name of a csv file and create a window
    with which a person can generate a lookup table from the data
    in the file.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a little utility program for solving a problem that is common     ]
;; [ in one area, and that problem is creating a lookup table from data in     ]
;; [ a csv file.                                                               ]
;; [                                                                           ]
;; [ Input data might look something like this:                                ]
;; [                                                                           ]
;; [ DEPT,DIV,EMPNO,EMPNAME,EMPDOB,EMPEXT                                      ]
;; [ 01,02,1111,MR SMITH,01-JAN-2018,101                                       ]
;; [ 01,02,1112,MR JONES,01-FEB-2018,102                                       ]
;; [ 01,02,1113,MR DOBBS,01-MAR-2018,103                                       ]
;; [ 01,02,1114,MR WHITE,01-APR-2018,104                                       ]
;; [                                                                           ]
;; [ Then let us say that we want to generate a lookup table of employee       ]
;; [ number, name, and telephone extension.  We want this table to be in       ]
;; [ a format so that we can "load" it and use the "select" function to        ]
;; [ refer to the items in the table.  In other words, something like this:    ]
;; [                                                                           ]
;; [ EMPTBL: [                                                                 ]
;; [ "1111" [EMPNAME "MR SMITH" EMPEXT "101"]                                  ]
;; [ "1112" [EMPNAME "MR JONES" EMPEXT "102"]                                  ]
;; [ "1113" [EMPNAME "MR DOBBS" EMPEXT "103"]                                  ]
;; [ "1114" [EMPNAME "MR WHITE" EMPEXT "104"]                                  ]
;; [ ]                                                                         ]
;; [                                                                           ]
;; [ With a structure like the above, given an employee number, one could      ]
;; [ do something like this:                                                   ]
;; [                                                                           ]
;; [ EMPREC: select EMPTBL "1112"                                              ]
;; [ print EMPREC/EMPNAME                                                      ]
;; [ print EMPREC/EMPEXT                                                       ]
;; [                                                                           ]
;; [ This program provides a window where one can pick data names from         ]
;; [ the headings of a csv file, and the datatypes one would like those        ]
;; [ data items to be in the lookup table, and generate the table in           ]
;; [ a text file that can be loaded by other programs.                         ]
;; [---------------------------------------------------------------------------]

do %csvfile.r

STATUS-CSV-LOADED: false
STATUS-KEY-SET: false
STATUS-FIELD-SELECTED: false

if not FILE-ID: request-file/only [
    alert "No file requested"
    quit
]

;; -- Request a file name, open the file, read it, and build
;; -- two blocks for the window.  One block is a list of column names.
;; -- The other block is a hard-coded list of data types.
CSV-OPEN FILE-ID
FIELD-LIST: copy []
foreach WRD CSV-WORDS [
    append FIELD-LIST to-string WRD
]
STATUS-CSV-LOADED: true
TYPE-LIST: [
    "string!"
    "integer!"
    "decimal!"
]

;; -- When the operator selects a field to be used as the table key,
;; -- save it, and also display it back to the window. 
KEYNAME: ""
SET-KEY-VAL: does [
    set-face MAIN-KEYNAME MAIN-KEY/text
    KEYNAME: MAIN-KEY/text
    STATUS-KEY-SET: true
]

;; -- After a field name and datatype have been selected on the window,
;; -- add them to a block that we will use later to generate the table. 
ATTRIBUTE-LIST: []
ADD-ATTRIBUTE: does [
;;  print MAIN-DATANAMES/text
;;  print MAIN-DATATYPES/text
;;  halt
    if not MAIN-DATANAMES/text [
        alert "No field selected."
        exit
    ]
    if not MAIN-DATATYPES/text [
        alert "No data type selected."
        exit
    ]
    append MAIN-ATTRIBUTES/text rejoin [
        MAIN-DATANAMES/text
        " "
        MAIN-DATATYPES/text
        newline
    ]
    append ATTRIBUTE-LIST to-word MAIN-DATANAMES/text
    append ATTRIBUTE-LIST to-word MAIN-DATATYPES/text
    show MAIN-ATTRIBUTES 
    STATUS-FIELD-SELECTED: true
]

;; -- After we have selected all the data items we want in the
;; -- lookup table, use that list of data items and go through
;; -- the actual data to build a lookup table. 
LOOKUPTABLE: []
LOOKUPBLOCK: []
GENERATE-TABLE: does [
    if not STATUS-CSV-LOADED [
        alert "No input file loaded"
        exit
    ]
    if not STATUS-KEY-SET [
        alert "No key field set."
        exit
    ]
    if not STATUS-FIELD-SELECTED [
        alert "No attributes selected."
        exit
    ]
    CSV-READ 
    until [
        LOOKUPBLOCK: copy []
        append LOOKUPTABLE get to-word KEYNAME
        foreach [WRD TYP] ATTRIBUTE-LIST [
            if equal? MAIN-WORDOPTION/text "withwords" [
                append LOOKUPBLOCK to-word WRD
            ]
            append LOOKUPBLOCK to get TYP get to-word WRD
        ]
        append/only LOOKUPTABLE LOOKUPBLOCK 
        CSV-READ
    ]
    alert "Generated."
]

;; -- Request a file name and save the lookup table that we
;; -- have constructed. 
SAVE-LOOKUPTABLE: does [
    if not SAVE-ID: request-file/only/save [
        alert "No file requested for saving."
        exit
    ]
    save SAVE-ID LOOKUPTABLE
    alert "Saved."
]  

;; --  Build and display the main window.
MAIN-WINDOW: layout [
    across
    banner "Lookup table generator"
    return
    label "Select item to use as key"
    MAIN-KEY: drop-down 200 rows 10 data FIELD-LIST [SET-KEY-VAL]
    MAIN-KEYNAME: info 200
    return 
    MAIN-DATANAMES: drop-down 200 rows 10 data FIELD-LIST
    MAIN-DATATYPES: drop-down 100 rows 10 data TYPE-LIST
    button "Add" [ADD-ATTRIBUTE] 
    return
    MAIN-ATTRIBUTES: text 400x300 as-is
    return
    button "Quit" [quit]
    button "Debug" [halt]
    MAIN-WORDOPTION: toggle "withwords" "nowords" 
    button "Generate" [GENERATE-TABLE]
    button "Save" [SAVE-LOOKUPTABLE]
]

view center-face MAIN-WINDOW




