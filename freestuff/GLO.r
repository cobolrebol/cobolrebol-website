REBOL [
    Title: "Grid layout"
    Purpose: {Take a block of data consisting of sub-blocks
    and return a layout that has a grid of the supplied data
    along with a scroller.}
]

;; [---------------------------------------------------------------------------]
;; [ This is based on an idea in Nick Antonaccio's document for creating       ]
;; [ business applications at:                                                 ]
;; [ http://business-programming.com/business_programming.html                 ]
;; [ The goal is to create a function that could be fed the results of an      ]
;; [ SQL query and poof!...up would pop a grid containing the data items       ]
;; [ from the query.                                                           ]
;; [ The result of an SQL query is a block of blocks, and each sub-block       ]
;; [ contains the data items from one row of the query.                        ]
;; [ The way this works is to generate VID code where each item of the         ]
;; [ input data has its own field on a VID layout.                             ]
;; [ Note the double loop.  For each sub-block of input, we generate a row     ]
;; [ of data fields.  For each item in the sub-block, we generate one info     ]
;; [ field on that row.                                                        ]
;; [ This was designed for quick-and-dirty viewing of small queries.           ]
;; [ It appears that the "info" style has a certain default size,              ]
;; [ and a query that produces many columns could waste a lot of horizontal    ]
;; [ space if every column got the default size.  To "fix" that the            ]
;; [ function takes a second block which is a list of column widths in         ]
;; [ pixels for each column of a data sub-block.  It is the job of the         ]
;; [ caller to make sure this block of columns sizes has the same number       ]
;; [ of items as the data sub-blocks, and the column widths are big enough.    ]
;; [ This module really should be an object, but we had a bit of trouble       ]
;; [ when we had it as an object and used a second similar module for          ]
;; [ a second similar layout.  The scroll bars were not scrolling their        ]
;; [ intended grids.  We left that problem unsolved.                           ]
;; [---------------------------------------------------------------------------]

GLO-BOXHEIGHT: 500 
GLO-BOXWIDTH: 0
GLO-BOXSIZE: none 

GLO-LAYOUT: func [
    GLOBLOCK
    GLOWIDTHS
    /local GLOGRID GLODISP GLOCOL
] [
    GLO-BOXWIDTH: 0
    foreach WIDTH GLOWIDTHS [
        GLO-BOXWIDTH: GLO-BOXWIDTH + WIDTH
    ]
    GLO-BOXSIZE: to-pair reduce [GLO-BOXWIDTH GLO-BOXHEIGHT] 
    GLOGRID: copy [across space 0]
    foreach BLK GLOBLOCK [
        GLOCOL: 0 
        foreach COL BLK [
            GLOCOL: GLOCOL + 1
            append GLOGRID compose [
                info (pick GLOWIDTHS GLOCOL) (form COL) 'bold
            ]
         ]
         append GLOGRID compose [return]
    ]
    GLODISP: layout/tight [
        across
        GLOBOX: box GLO-BOXSIZE with [ ;; "with" lets us get at internals
            pane: layout/tight GLOGRID pane/offset: 0x0
        ]
        scroller to-pair reduce [20 second GLO-BOXSIZE] [
            GLOBOX/pane/offset/y: GLOBOX/size/y - GLOBOX/pane/size/y * value
            show GLOBOX
        ]
    ]
    return GLODISP
]

;;Uncomment to test
;view center-face GLO-LAYOUT [
;    ["01" "AAAA" "1111"]
;    ["02" "BBBB" "2222"]
;    ["03" "CCCC" "3333"]
;    ["04" "DDDD" "4444"]
;    ["05" "EEEE" "5555"]
;    ["06" "FFFF" "6666"]
;    ["07" "GGGG" "7777"]
;    ["08" "HHHH" "8888"]
;    ["09" "IIII" "9999"]
;    ["10" "JJJJ" "1010"]
;    ["11" "KKKK" "1111"]
;    ["12" "LLLL" "1212"]
;    ["13" "MMMM" "1323"]
;    ["14" "NNNN" "1414"]
;    ["15" "OOOO" "1515"]
;    ["16" "PPPP" "1616"]
;    ["17" "QQQQ" "1717"]
;    ["18" "RRRR" "1818"]
;    ["19" "SSSS" "1919"]
;    ["20" "TTTT" "2020"]
;    ["21" "UUUU" "2121"]
;    ["22" "VVVV" "2222"]
;    ["23" "WWWW" "2323"]
;    ["24" "XXXX" "2424"]
;    ["25" "YYYY" "2525"]
;    ["26" "ZZZZ" "2626"]
;] [40 60 100]
   
