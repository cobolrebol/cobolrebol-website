REBOL [
    Title: "SQL comments"
    Purpose: {Extract structured comments from an SQL script.}
]

;; [---------------------------------------------------------------------------]
;; [ This function is part of a larger project to smooth the running of SQL    ]
;; [ scripts.  It takes an SQL script with a comment block like this:          ]
;; [ /*                                                                        ]
;; [ DATABASE: "database-name"                                                 ]
;; [ AUTHOR: "J Smith"                                                         ]
;; [ DATEWRITTEN: 29-JUN-2017                                                  ]
;; [ KEYWORDS: ["keyword-1" "keyword-2"]                                       ]
;; [ COLUMNS: ["colname-1" "colname-2"]                                        ]
;; [ REMARKS: {Multi-line free-format description of the script.}              ]
;; [ */                                                                        ]
;; [ and returns a block containing the values of DATABASE, AUTHOR,            ]
;; [ DATEWRITTEN, KEYWORDS, COLUMNS, and REMARKS.                              ]
;; [ This comment block must be at the start of the script, where one          ]
;; [ normally would place it.                                                  ]
;; [ The way this is written will cause DATABASE, AUTHOR, DATEWRITTEN,         ]
;; [ KEYWORDS, COLUMNS, and REMARKS to be global words.                        ]
;; [ COLUMNS is an optional list of column name literals that could be used    ]
;; [ by other automated processes to identify the names of the colums          ]
;; [ returned by the SQL.                                                      ]
;; [---------------------------------------------------------------------------]

SQLCOMMENTS: func [
    SCRIPTCODE
    /local COMMENTBLOCK RETURNBLOCK
] [
    COMMENTBLOCK: copy ""
    RETURNBLOCK: none
    parse/case SCRIPTCODE [thru "/*" copy COMMENTBLOCK to "*/"]
    if greater? (length? COMMENTBLOCK) 0 [
        DATABASE: copy ""
        AUTHOR: copy ""
        DATEWRITTEN: none
        KEYWORDS: copy []
        COLUMNS: copy []
        REMARKS: copy ""
        do load COMMENTBLOCK
        RETURNBLOCK: copy []
        append RETURNBLOCK DATABASE
        append RETURNBLOCK AUTHOR
        append RETURNBLOCK DATEWRITTEN
        append/only RETURNBLOCK KEYWORDS
        append/only RETURNBLOCK COLUMNS
        append RETURNBLOCK REMARKS
    ]
    return RETURNBLOCK
]

;;Uncomment to test
;SQL-CMD: {
;/* 
;DATABASE: "database-name"  
;AUTHOR: "J Smith" 
;DATEWRITTEN: 29-JUN-2017 
;KEYWORDS: ["keyword-1" "keyword-2"] 
;COLUMNS: ["col-1" "col-2"]
;REMARKS: {Multi-line free-format description of the script.} 
;*/    
;select * from TABLENAME      
;}
;probe SQLCOMMENTS SQL-CMD 
;halt

