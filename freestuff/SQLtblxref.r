REBOL [
    Title: "SQL Server table-column cross reference"
    Purpose: {Use some control tables in an SQL database to
    cross reference the tables in the database with the columns
    in those tables.}
]

;; [---------------------------------------------------------------------------]
;; [ This program uses tables in an SQL Server data base to obtain the         ]
;; [ table names and column names from the data, and formats an                ]
;; [ html cross reference of those items.                                      ]
;; [ You will have to set up an ODBC connection to an SQL Server database.     ]
;; [ Functions for "opening" and "closing" a database are provided below       ]
;; [ so you can find them and tailor them for your installation.               ]
;; [---------------------------------------------------------------------------]

DB-OPEN: does [
    DB-CON: open odbc://datasourcename:password@userid
    DB-CMD: first DB-CON
]
DB-CLOSE: does [
    close DB-CMD
]

;; [---------------------------------------------------------------------------]
;; [ These are functions we will use to write the report to an HTML file.      ]
;; [---------------------------------------------------------------------------]

HTMLFILE-PAGE: make string! 5000
HTMLFILE-FILE-ID: %htmlfile.htm

HTMLFILE-OPEN-OUTPUT: does [
    HTMLFILE-PAGE: copy ""
]

HTMLFILE-CLOSE: does [
    write HTMLFILE-FILE-ID HTMLFILE-PAGE
]

HTMLFILE-EMIT: func [
    HTMLFILE-LINE
] [
    append repend HTMLFILE-PAGE HTMLFILE-LINE newline
]

HTMLFILE-EMIT-FILE: func [
    HTMLFILE-TEMPLATE [file!]
] [
    HTMLFILE-EMIT build-markup read HTMLFILE-TEMPLATE
]

;; [---------------------------------------------------------------------------]
;; [ Reassure that the program is working.                                     ]
;; [---------------------------------------------------------------------------]

alert "This will run silently and take a minute."

;; [---------------------------------------------------------------------------]
;; [ These are the SQL commands we will submit, one after the other,           ]
;; [ to make the two parts of the report.                                      ]
;; [---------------------------------------------------------------------------]

SQL-COMMAND-TABLES: {
select
TABLE_NAME 
,COLUMN_NAME
from information_schema.columns
order by TABLE_NAME, ORDINAL_POSITION, COLUMN_NAME 
}

SQL-COMMAND-COLUMNS: {
select 
COLUMN_NAME  
,TABLE_NAME 
from information_schema.columns
order by COLUMN_NAME, TABLE_NAME 
}

;; [---------------------------------------------------------------------------]
;; [ These are the html fragments we will assemble into the final page.        ]
;; [---------------------------------------------------------------------------]

XREF-HEAD: {
<html>
<head>
<title>Table-field cross reference</title>
</head>
<body>
<h1>Table-field cross reference</h1>
}

XREF-FOOT: {
</body>
</html>
}

XREF-TC-HEAD: {
<h2>Tables and their columns</h2>
<table width="100%" border="1">
<tr>
<th width="10%">Table</th>
<th width="90%">Columns</th>
</tr>
}

XREF-TC-FOOT: {
</table>
}

XREF-TC-BODY-HEAD: {
<tr>
<td width="10%" valign="top" bgcolor="#FFFFCC"> 
<a name="tbl-<% trim/all WS-TABLE %>" id="tbl-<% trim/all WS-TABLE %>" >
<% WS-TABLE %> </a> </td>
<td width="90%" bgcolor="#CCFFFF">
}

XREF-TC-BODY-FOOT: {
</td>
</tr>
}

XREF-TC-BODY-COL: {
<a href="#col-<% trim/all WS-COLUMN %>" > 
<% WS-COLUMN %> </a>,
}

;; -----------------------------------------------------------------------------

XREF-CT-HEAD: {
<h2>Columns and their tables</h2>
<table width="100%" border="1">
<tr>
<th width="10%">Column</th>
<th width="90%">Tables</th>
</tr>
}

XREF-CT-FOOT: {
</table>
}

XREF-CT-BODY-HEAD: {
<tr>
<td width="10%" valign="top" bgcolor="#CCFFFF"> 
<a name="col-<% trim/all WS-COLUMN %>" id="col-<% trim/all WS-COLUMN %>" >
<% WS-COLUMN %> </a> </td>
<td width="90%" bgcolor="#FFFFCC">
}

XREF-CT-BODY-FOOT: {
</td>
</tr>
}

XREF-CT-BODY-COL: {
<a href="#tbl-<% trim/all WS-TABLE %>" > 
<% WS-TABLE %> </a>, 
}

;; [---------------------------------------------------------------------------]
;; [ As we get table names and column names from our query, we will store      ]
;; [ them here for the build-markup command.                                   ]
;; [---------------------------------------------------------------------------]

WS-TABLE: ""
WS-COLUMN: ""

;; [---------------------------------------------------------------------------]
;; [ As we read through the output of the query, we will have to do control    ]
;; [ breaks.  For example, when doing the table-column list, when the table    ]
;; [ changes we will have to start a new row.  So we will need places to       ]
;; [ hold the table we are working on so we can check each incoming table      ]
;; [ name against it.                                                          ]
;; [---------------------------------------------------------------------------]

HOLD-TABLE: ""
HOLD-COLUMN: ""

;; [---------------------------------------------------------------------------]
;; [ "Open" the html file.                                                     ]
;; [ Write the headers and such.                                               ]
;; [---------------------------------------------------------------------------]

HTMLFILE-FILE-ID: %table-column-xref.html
HTMLFILE-OPEN-OUTPUT
HTMLFILE-EMIT XREF-HEAD

;; [---------------------------------------------------------------------------]
;; [ Open the database.                                                        ]
;; [---------------------------------------------------------------------------]

DB-OPEN

;; [---------------------------------------------------------------------------]
;; [ Make the table-column part of the page.                                   ]
;; [---------------------------------------------------------------------------]

FORMAT-TABLE-LINE: does [
    WS-TABLE: copy ""
    WS-COLUMN: copy "" 
    WS-TABLE: trim to-string first SQL-RESULT
    WS-COLUMN: trim to-string second SQL-RESULT
    if not-equal? WS-TABLE HOLD-TABLE [
        if not-equal? HOLD-TABLE "" [
            HTMLFILE-EMIT XREF-TC-BODY-FOOT
        ]
        HOLD-TABLE: copy WS-TABLE
        HTMLFILE-EMIT build-markup XREF-TC-BODY-HEAD
    ]
    HTMLFILE-EMIT build-markup XREF-TC-BODY-COL
]

HOLD-TABLE: copy ""
HOLD-COLUMN: copy "" 

HTMLFILE-EMIT XREF-TC-HEAD

SQL-RESULT: copy []
insert DB-CMD SQL-COMMAND-TABLES
while [SQL-RESULT: pick DB-CMD 1] [
    FORMAT-TABLE-LINE
]
HTMLFILE-EMIT XREF-TC-BODY-FOOT

HTMLFILE-EMIT XREF-TC-FOOT

;; [---------------------------------------------------------------------------]
;; [ Make the column-table part of the page.                                   ]
;; [---------------------------------------------------------------------------]

FORMAT-COLUMN-LINE: does [
    WS-TABLE: copy ""
    WS-COLUMN: copy "" 
    WS-COLUMN: trim to-string first SQL-RESULT
    WS-TABLE: trim to-string second SQL-RESULT
    if not-equal? WS-COLUMN HOLD-COLUMN [
        if not-equal? HOLD-COLUMN "" [
            HTMLFILE-EMIT XREF-CT-BODY-FOOT
        ]
        HOLD-COLUMN: copy WS-COLUMN
        HTMLFILE-EMIT build-markup XREF-CT-BODY-HEAD
    ]
    HTMLFILE-EMIT build-markup XREF-CT-BODY-COL
]

HOLD-TABLE: copy ""
HOLD-COLUMN: copy "" 

HTMLFILE-EMIT XREF-CT-HEAD

SQL-RESULT: copy []
insert DB-CMD SQL-COMMAND-COLUMNS
while [SQL-RESULT: pick DB-CMD 1] [
    FORMAT-COLUMN-LINE
]
HTMLFILE-EMIT XREF-CT-BODY-FOOT

HTMLFILE-EMIT XREF-CT-FOOT

;; [---------------------------------------------------------------------------]
;; [ Close the database.                                                       ]
;; [---------------------------------------------------------------------------]

DB-CLOSE 

;; [---------------------------------------------------------------------------]
;; [ Finish the html file.                                                     ]
;; [---------------------------------------------------------------------------]

HTMLFILE-EMIT XREF-FOOT
HTMLFILE-CLOSE 

;; [---------------------------------------------------------------------------]
;; [ Inform when done.                                                         ]
;; [---------------------------------------------------------------------------]

alert "Done."

