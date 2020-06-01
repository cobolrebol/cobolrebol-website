REBOL [Title: "Run T-SQL SP_TABLES and SP_COLUMNS commands"]

;; [---------------------------------------------------------------------------]
;; [ These are two functions that submit, to an SQL Server ODBC data source,   ]
;; [ the SP_TABLES and SP_COLUMNS commands to get data about tables and        ]
;; [ columns.  This data can be userful if you are trying to generate some     ]
;; [ documentation.  This kind of operation is documented in the               ]
;; [ REBOL/Command documentation, but I couldn't make it work exactly as       ]
;; [ documented there, whereas some trial and error got the following          ]
;; [ operations to work.                                                       ]
;; [                                                                           ]
;; [ The database connection credentials in the two functions below have       ]
;; [ been sanitized, so you will have to supply your own for your own          ]
;; [ situation.                                                                ]
;; [---------------------------------------------------------------------------] 

SQLSERVER-COLUMNS: func [
    TABLENAME
    /local SQLRESULT 
] [
    DB-CON: open odbc://userid:password@datasourcename
    DB-CMD: first DB-CON
    insert DB-CMD rejoin ["SP_COLUMNS " TABLENAME]
    SQLRESULT: copy []
    SQLRESULT: copy DB-CMD
    close DB-CMD
    return SQLRESULT
]

SQLSERVER-TABLES: does [
    DB-CON: open odbc://userid:password@datasourcename
    DB-CMD: first DB-CON
    insert DB-CMD rejoin ["SP_TABLES"]
    SQLRESULT: copy []
    SQLRESULT: copy DB-CMD
    close DB-CMD
    return SQLRESULT
]

;;Uncomment to test
;TBLS: SQLSERVER-TABLES ;; Get all tables
;COLS: SQLSERVER-COLUMNS TBLS/1/3 ;; Get columns for just the first table
;foreach TBL TBLS [
;    probe TBL
;]
;probe first COLS 
;halt

