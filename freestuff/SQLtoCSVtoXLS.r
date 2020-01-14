REBOL [
    Title: "Run SQL script and produce Excel spreadsheet"
    Purpose: {Request the name of an SQL script file, run it
    through an ODBC connection, write the output to a CSV file,
    load the CSV file into Excel, and finally save the spreadsheet.
    This was originally written as a proof of concept.}
]

;; [---------------------------------------------------------------------------]
;; [ This was written originally as part of an idea for a report library.      ]
;; [ Outside of this script, one writes an SQL script to produce data for      ]
;; [ a report.  When the script is debugged and works, it is saved so it       ]
;; [ can be run later.  This script is the way the SQL script is "run later."  ]
;; [ This script asks for the name of an SQL script, runs it through an        ]
;; [ ODBC connection, gets the result, writes it into a CSV file, and then     ]
;; [ generates a powershell script to save the CSV file into an Excel file.    ]
;; [ Note that because this script uses an ODBC connection, and an ODBC        ]
;; [ connection is not generic and must be created for each database,          ]
;; [ this script is not totally general-purpose.  There will have to be a      ]
;; [ version of it for each database that will be used for reporting.          ]
;; [                                                                           ]
;; [ If this program is run with a regular SQL script, it will produce         ]
;; [ an Excel file with one row for each row of data.  Many times,             ]
;; [ what is really wanted is an Excel file with a first row containing        ]
;; [ column names.  We do not know how to automate that.  However, that        ]
;; [ result can be obtained if you are willing to do a little extra work.      ]
;; [ SQL scripts can contain comments delimited by the /* and */ characters.   ]
;; [ If you put such a comment block in your script and, as a comment,         ]
;; [ write something like this:                                                ]
;; [ /*                                                                        ]
;; [ COLUMN-NAMES: {COL-NAME-1,COL-NAME-2,COL-NAME-3,...COL-NAME-N}            ]
;; [ */                                                                        ]
;; [ then the string in the braces will be written to the first line of        ]
;; [ the csv file and will thus be transmitted to the final spreadsheet        ]
;; [ file.  Note the importance of the REBOL-like syntax in the comment        ]
;; [ block.  The comment block will be located by parsing on the /* and */     ]
;; [ and "load"ing what is found there, so that syntax must be correct.        ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These are the items that were sanitized for publishing, and that you      ]
;; [ will have to change for your own installation.                            ]
;; [ Note that the lack of user ID and password on the "open" indicates        ]
;; [ that the odbc connection uses Windows authentication.                     ]
;; [---------------------------------------------------------------------------]

DB-OPEN: does [
    DB-CON: open odbc://odbcname  
    DB-CMD: first DB-CON
    DB-DB-IS-OPEN: true
]
DB-CLOSE: does [
    close DB-CMD
    DB-DB-IS-OPEN: false
]
COB-NORMAL-WORK-DRIVE: %/I/
COB-BACKUP-WORK-DRIVE: %/C/

;; [---------------------------------------------------------------------------]
;; [ We are going to have to make some temporary files, and find a place       ]
;; [ to store the excel file.  Make some folders if they do not exist.         ]
;; [---------------------------------------------------------------------------]

COB-WORK-DRIVE: none
either dir? COB-NORMAL-WORK-DRIVE [
    COB-WORK-DRIVE: COB-NORMAL-WORK-DRIVE
] [
    COB-WORK-DRIVE: COB-BACKUP-WORK-DRIVE
]
COB-DOC-WORKAREA: rejoin [
    COB-WORK-DRIVE
    "IS_Apps_TempFiles/"
]
if not dir? COB-DOC-WORKAREA [
    make-dir COB-DOC-WORKAREA
]
COB-MYREPORTS-DIR: rejoin [
    COB-WORK-DRIVE
    "IS_Apps_MyReports/"
]
if not dir? COB-MYREPORTS-DIR [
    make-dir COB-MYREPORTS-DIR
]  

;; [---------------------------------------------------------------------------]
;; [ Get the SQL file to process.                                              ]
;; [---------------------------------------------------------------------------]

if not SQL-FILE: request-file/only [
    alert "No file requested."
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This is a function not provided (as far as we can tell) to get the        ]
;; [ part of a file that is NOT the suffix.                                    ]
;; [---------------------------------------------------------------------------]

GLB-BASE-FILENAME: func [
    "Returns a file name without the extension"
    INPUT-STRING [series! file!] "File name"
    /local FILE-STRING REVERSED-NAME REVERSED-BASE BASE-FILENAME
] [
    FILE-STRING: copy ""
    FILE-STRING: to-string INPUT-STRING
    REVERSED-NAME: reverse FILE-STRING
    REVERSED-BASE: copy ""
    REVERSED-BASE: next find REVERSED-NAME "."
    BASE-FILENAME: copy ""
    BASE-FILENAME: reverse REVERSED-BASE
    return BASE-FILENAME
]

;; [---------------------------------------------------------------------------]
;; [ We will use the SQL file name to generate the name for a temporary        ]
;; [ csv file and the final excel file.                                        ]
;; [---------------------------------------------------------------------------]

CSV-FILE-ID: to-file rejoin [
    COB-DOC-WORKAREA
    GLB-BASE-FILENAME second split-path SQL-FILE 
    ".csv" 
]
XLSX-FILE-ID: to-file rejoin [
    COB-MYREPORTS-DIR
    GLB-BASE-FILENAME second split-path SQL-FILE 
    ".xlsx" 
]

;; [---------------------------------------------------------------------------]
;; [ Miscellaneous working items.                                              ]
;; [---------------------------------------------------------------------------]

CSV-FILE: ""
CSV-REC: ""
REC-SIZE: 0
FIELD-COUNT: 0

;; [---------------------------------------------------------------------------]
;; [ We are going to use powershell to convert an intermediate csv file to     ]
;; [ an excel file.  The result below is the result of a bit of trial and      ]
;; [ error.                                                                    ]
;; [---------------------------------------------------------------------------]  

;; Unfortunately, I don't know exactly how this works, but it does...
;; In concept it starts Excel, reads the CSV file, saves the CSV file as XLXS,
;; and then kills the Excel process.

;; This makes the output file, but does not kill Excel. 
;POWERSHELL-SCRIPT: rejoin [ 
;    {powershell -command }
;    {$CurrentExcel = Get-Process Excel | Select-Object -ExpandProperty ID }
;    {((New-Object -ComObject 'Excel.Application').workbooks.open('} to-local-file CSV-FILE-ID {')).SaveAs('} to-local-file XLSX-FILE-ID {',51) }
;    {Start-Sleep 1 }
;    {Get-Process Excel | Where-Object {$CurrentExcel -notcontains $_.ID} | Stop-Process -Force }
;]

;; In this attempt, we will write the script to a file and run from there.
PS1-FILE-ID: to-file rejoin [
    COB-DOC-WORKAREA
    GLB-BASE-FILENAME second split-path SQL-FILE 
    ".ps1" 
]
POWERSHELL-SCRIPT: rejoin [ 
    {$CurrentExcel = Get-Process Excel | Select-Object -ExpandProperty ID } newline
    {((New-Object -ComObject 'Excel.Application').workbooks.open('} to-local-file CSV-FILE-ID {')).SaveAs('} to-local-file XLSX-FILE-ID {',51) } newline
    {Start-Sleep 1 } newline
    {Get-Process Excel | Where-Object {$CurrentExcel -notcontains $_.ID} | Stop-Process -Force }
]
POWERSHELL-COMMAND: rejoin [
    {powershell -command }
    to-local-file PS1-FILE-ID
]
RUN-POWERSHELL: does [
    write PS1-FILE-ID POWERSHELL-SCRIPT
    call POWERSHELL-COMMAND
]

;; [---------------------------------------------------------------------------]
;; [ Load the SQL file and parse it for a comment block.                       ]
;; [ If we find a comment block try to find the COLUMN-NAMES word and value.   ]
;; [ If we find the COLUMN-NAMES, write that string to the front of the        ]
;; [ csv file.                                                                 ]
;; [---------------------------------------------------------------------------]

SQL-CMD: read SQL-FILE
COMMENTBLOCK: copy ""
parse/case SQL-CMD [thru "/*" copy COMMENTBLOCK to "*/"]
if greater? (length? COMMENTBLOCK) 0 [
    COLUMN-NAMES: none
    do load COMMENTBLOCK
    if value? COLUMN-NAMES [
        append CSV-FILE rejoin [
            COLUMN-NAMES
            newline
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Send the SQL file to the ODBC connection.                                 ]
;; [ Save the result of the query in a block.                                  ]
;; [---------------------------------------------------------------------------]

DB-OPEN
SQL-RESULT: copy []
insert DB-CMD SQL-CMD
SQL-RESULT: copy DB-CMD
DB-CLOSE

;; [---------------------------------------------------------------------------]
;; [ Go through the result data and write it to a temporary csv file.          ]
;; [---------------------------------------------------------------------------]

foreach DATABLOCK SQL-RESULT [
    CSV-REC: copy ""
    REC-SIZE: length? DATABLOCK
    FIELD-COUNT: 0
    foreach DATAFIELD DATABLOCK [
        FIELD-COUNT: FIELD-COUNT + 1
        append CSV-REC mold to-string DATAFIELD
        if (FIELD-COUNT < REC-SIZE) [      ;; no comma after last column 
            append CSV-REC ","
        ]
    ]    
    append CSV-REC newline
    append CSV-FILE CSV-REC
]

;; [---------------------------------------------------------------------------]
;; [ Write the csv data to disk and then run the powershell script to          ]
;; [ load the csv data into excel and write it to a spreadsheet file.          ]
;; [---------------------------------------------------------------------------]

write CSV-FILE-ID CSV-FILE
RUN-POWERSHELL 

;; [---------------------------------------------------------------------------]
;; [ Optionally, alert that we are done.                                       ]
;; [---------------------------------------------------------------------------]

alert "Done."
;halt


