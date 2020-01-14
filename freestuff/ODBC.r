REBOL [
    Title:  "General ODBC functions"
    Purpose: {Isolate ODBC connection strings for easy maintenance.
    Store them in a format such that they can be a Python module
    and still be used by a REBOL program.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a generalized module for reading data from databases by ODBC.     ]
;; [ It seems that ODBC needs a "connection string" that identifies the        ]
;; [ server, the database, and a user ID and password.  This string is         ]
;; [ not specific to REBOL but applies to other languages, such as Python.     ]
;; [ It also seems that the Python syntax to define a variable with a value    ]
;; [ of a connection string can be put into a format that is parsable by       ]
;; [ REBOL.  Therefore, if one worked at an installation with several          ]
;; [ databases and wanted to streamline the ODBC access to them, one could     ]
;; [ gather all the connection strings for all the databases into a file,      ]
;; [ code them in a Python syntax, and use that file of connection strings     ]
;; [ in Python and REBOL programs.  There is an example of what those          ]
;; [ strings could be like:                                                    ]
;; [                                                                           ]
;; [ DB1="DRIVER={SQL Server};SERVER={SERVER1};DATABASE=DB1;UID=user1;PWD=pwd1"]
;; [ DB2="DRIVER={SQL Server};SERVER={SERVER2};DATABASE=DB2;UID=user2;PWD=pwd2"]
;; [ DB3="DRIVER={SQL Server};SERVER={SERVER3};DATABASE=DB3;UID=user3;PWD=pwd3"]
;; [ DB4="DRIVER={SQL Server};SERVER={SERVER4};DATABASE=DB4;UID=user4;PWD=pwd4"]
;; [ DB5="DRIVER={SQL Server};SERVER={SERVER5};DATABASE=DB5;UID=user5;PWD=pwd5"]
;; [                                                                           ]
;; [ The function below assume that such a file exists, reads it, and          ]
;; [ parses it into a "select" block of database names and connection          ]
;; [ strings.  There is a function to open a database given a name as          ]
;; [ defined in the file, and a function to submit SQL to that opened          ]
;; [ database. Rounding out the services is a function to close the            ]
;; [ database.                                                                 ]
;; [---------------------------------------------------------------------------]

;; -- Connection strings are stored in this file.
ODBC-CONNECTIONS-FILE: %ODBCconnectionstrings.py ;; Pick your own file name.
ODBC-CONNECTIONS: read/lines ODBC-CONNECTIONS-FILE

;; -- Parse each line on the first "equal" sign, dividing each line into two
;; -- parts.  Append the two parts to the accumulation of connection names
;; -- and strings.  
ODBC-CONNECTIONLIST: copy []
foreach ODBC-LINE ODBC-CONNECTIONS [
    ODBC-NME: copy ""
    ODBC-STR: copy ""
    parse/all ODBC-LINE [
        copy ODBC-NME to "="
        skip
        copy ODBC-STR to end
    ]
    append ODBC-CONNECTIONLIST ODBC-NME
    append ODBC-CONNECTIONLIST trim/with ODBC-STR {"}
]

;; -- Given a connection name, get the connection string and open 
;; -- an ODBC connection.
ODBC-OPEN: func [
    ODBC-CONNECTIONNAME
    /local ODBC-CONNECTSTRING
] [
    ODBC-CONNECTIONSTRING: select ODBC-CONNECTIONLIST ODBC-CONNECTIONNAME
    ODBC-CON: open [
        scheme: 'odbc
        target: ODBC-CONNECTIONSTRING
    ]
    ODBC-CMD: first ODBC-CON
]

;; -- Submit an SQL script and return the result set.
ODBC-EXECUTE: func [
    ODBC-SQL
] [
    insert ODBC-CMD ODBC-SQL
    return copy ODBC-CMD
]

;; -- Close the ODBC connection.
ODBC-CLOSE: does [
    close ODBC-CMD
]

;; -- Test the parsing
;foreach [NAME CONSTRING] ODBC-CONNECTIONLIST [
;    print [mold NAME ":" mold CONSTRING]
;]
;halt

