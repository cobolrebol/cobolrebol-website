REBOL [
    Title: "SQL AS columns"
    Purpose: {Given a carefully-formatted SQL query where all selected
    columns have the "AS" feature specified, extract those column names
    and return them in a block.}
]

;; [---------------------------------------------------------------------------]
;; [ It is possible to do useful things with source code if is is written      ]
;; [ with some discipline.  In this case if on has an SQL query and every      ]
;; [ column in the "select" statement has the "AS" feature specified to        ]
;; [ name the column, then it should be possible to extract the column         ]
;; [ names from the SQL.  Any string after the word "as" is a column name,     ]
;; [ and the word "from" indicates the end of the column names.                ]
;; [ This function will make that scan and return the column names as          ]
;; [ a block of strings.  This function was written as part of a larger        ]
;; [ project to automate the running of SQL queries.                           ]
;; [ Note that this will not work if the "AS" keyword is used in other         ]
;; [ situations before the "FROM" keyword.  For example,                       ]
;; [     select cast(column-1 as int) as column-1                              ]
;; [ will hose things.                                                         ]
;; [---------------------------------------------------------------------------]

SQL-AS-COLUMNS: func [
    SQL-CMD
    /local COLNAMES WORDS LGH POS
] [
    WORDS: parse SQL-CMD none
    LGH: length? WORDS
    POS: 1
    COLNAMES: copy []
    while [POS < LGH] [
        if equal? "from" pick WORDS POS [
            break
        ]
        either equal? "as" pick WORDS POS [
            POS: POS + 1
            append COLNAMES trim/with pick WORDS POS "'"
            POS: POS + 1
        ] [
            POS: POS + 1
        ]
    ]
    return COLNAMES
]

;;Uncomment to test
;SQL-CMD: {
;select 
;COLUMN1 as COLUMN1
;,COLUMN2 as COLUMN2 
;,COLUMN3 as 'COLUMN3'
;,COLUMN4 AS 'COLUMN4'
;from TABLE1 as T1
;inner join TABLE2 AS T2
;on T1.COLUMN1 = T2.COLUMN1
;order by COLUMN1
;}
;probe SQL-AS-COLUMNS SQL-CMD
;halt

