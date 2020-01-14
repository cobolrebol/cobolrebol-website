TITLE
Adventureworks global database procedures

SUMMARY
These are the procedures for the Adventureworks database that are needed no
matter what tables are being used.  These are procedures like opening
and closing the database.

DOCUMENTATION
Before using any tables in the Adventureworks database, it is necessary to
make certain connections to it.  This is hidden in procedures that make
using the Adventureworks database, which is in SQL Server, similar to using
a database through COBOL.  You "open" the database before using it and
"close" the database after using it.

To use these procedures:

Before using any of the other procedures that work with specific tables,
"open" the database with the following procedure:

ADVENTUREWORKS-OPEN

Before you exit your script, "close" the database as follows:

ADVENTUREWORKS-CLOSE

And that's all there is to do. 

SCRIPT
REBOL [
    Title:  "Adventureworks database global procedures"
]

;; [---------------------------------------------------------------------------]
;; [ These are procedures for the Adventureworks database that are             ]
;; [ used by the other procedures for the Adventureworks database tables.      ]
;; [ Those are things like opening and closing the database.                   ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ The database might be used once, like in a CGI script, or                 ]
;; [ repeatedly, like in a batch program.                                      ]
;; [ To allow for batch use, the procedures that open and close the            ]
;; [ file set a global flag so that it can be done only once.                  ]
;; [---------------------------------------------------------------------------]

ADVENTUREWORKS-DB-IS-OPEN: false

;; [---------------------------------------------------------------------------]
;; [ This procedure makes the ODBC connection, that is, it basically           ]
;; [ "opens" the database (in COBOL terminology).                              ]
;; [ After the database is open, things are done with/to it by                 ]
;; [ means of SQL scripts.  An SQL script is passed to the database            ]
;; [ by putting it into the command port, thusly:                              ]
;; [     insert ADVENTUREWORKS-CMD SQL-SCRIPT                                  ]
;; [ where SQL-SCRIPT is a string that contains an SQL script.                 ]
;; [                                                                           ]
;; [ The results of the script are in the same command port, and               ]
;; [ are obtained by repeatedly taking off the first item in the               ]
;; [ port, thusly:                                                             ]
;; [     REC-AREA: pick ADVENTUREWORKS-CMD 1                                   ]
;; [ where REC-AREA is a word that can hold the block that you                 ]
;; [ picked.  When you get a result of "none," you are at the                  ]
;; [ end.                                                                      ]
;; [                                                                           ]
;; [ Alternatively, you could get the entire result of the query by copying    ]
;; [ the command port like this:                                               ]
;; [     SQL-RESULT: copy ADVENTUREWORKS-CMD                                   ]
;; [ SQL-RESULT would be a block, and each item in that block would be         ]
;; [ another block that contains one row of the queried data.                  ]
;; [---------------------------------------------------------------------------]

;; -- This method works if you have an ODBC connection called 
;; -- "adventureworksdb" with windows authentication that points to the
;; -- database, whereas...
;ADVENTUREWORKS-OPEN: does [
;    ADVENTUREWORKS-CON: open odbc://adventureworksdb
;    ADVENTUREWORKS-CMD: first ADVENTUREWORKS-CON
;    ADVENTUREWORKS-DB-IS-OPEN: true
;]

;; -- ...this method does not require the ODBC connection.  You would change
;; -- the "xxxxxxxxx" to be the name of the computer onto which you installed
;; -- SQL Express.  That would become clear after you installed SQL Express
;; -- and then tried to run Server Management Studio.  
ADVENTUREWORKS-OPEN: does [
    ADVENTUREWORKS-CON: open [
        scheme: 'odbc
        target: "DRIVER={SQL Server};SERVER={xxxxxxxxx\SQLEXPRESS};DATABASE=AdventureWorks2016CTP3;"
    ]
    ADVENTUREWORKS-CMD: first ADVENTUREWORKS-CON
    ADVENTUREWORKS-DB-IS-OPEN: true
]

;; [---------------------------------------------------------------------------]
;; [ This procedure closes the database.                                       ]
;; [---------------------------------------------------------------------------]

ADVENTUREWORKS-CLOSE: does [
    close ADVENTUREWORKS-CMD
    ADVENTUREWORKS-DB-IS-OPEN: false
]

