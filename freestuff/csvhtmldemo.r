REBOL [
    Title: "Show usage of csvobj.r and htmlrep.r"
]

do %csvobj.r
do %htmlrep.r

if not DEMO-CSV-FILE-ID: request-file/only [
    alert "No file selected"
    quit
] 
DEMO-REPORT-FILE-ID: %csvlisting.html

;; [---------------------------------------------------------------------------]
;; [ Create a CSV object for the above-mentioned file.                         ]
;; [ Bring the file into memory.                                               ]
;; [ Read the first record to prepare for looping through all records.         ]
;; [---------------------------------------------------------------------------]
DEMOCSV: make CSV []
DEMOCSV/CSVOPEN DEMO-CSV-FILE-ID
DEMOCSV/CSVREAD

;; [---------------------------------------------------------------------------]
;; [ Prepare the html report.  Load headings, set file names, etc.             ]
;; [---------------------------------------------------------------------------]
HTMLREP-FILE-ID: DEMO-REPORT-FILE-ID
HTMLREP-TITLE: copy "Quick CSV file listing"
HTMLREP-PROGRAM-NAME: copy "csvhtmldemo.r"
HTMLREP-OPEN
HTMLREP-EMIT-HEAD DEMOCSV/HEADINGS

;; [---------------------------------------------------------------------------]
;; [ Loop until the CSVREAD function returns the EOF marker (End Of File).     ]
;; [ We do have to do a bit of data conversion, as the modules currently       ]
;; [ are written.                                                              ]
;; [ HTML-EMIT-LINE expects a block of values.                                 ]
;; [ The items in DEMOCSV-HEADINGS are strings, and so must be converted to    ]
;; [ words so that they can be evaluated and their values appended to          ]
;; [ VALUE-BLOCK.                                                              ]
;; [ But still, that's not a lot of work.                                      ]
;; [---------------------------------------------------------------------------]
until [
    VALUE-BLOCK: copy []
    foreach WORD DEMOCSV/HEADINGS [
        VALUE-NAME: to-word WORD
        append VALUE-BLOCK DEMOCSV/RECORD/:VALUE-NAME
    ]
    HTMLREP-EMIT-LINE VALUE-BLOCK               
    DEMOCSV/CSVREAD
]

;; [---------------------------------------------------------------------------]
;; [ Put the output file on disk and show it to confirm we are done.           ]
;; [---------------------------------------------------------------------------]
HTMLREP-CLOSE
browse DEMO-REPORT-FILE-ID 

