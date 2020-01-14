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
;; [ This object was originally created as indicated above, to make a          ]
;; [ quick and dirty data grid out of a block of data blocks.                  ]
;; [ This particular version you are looking at right now has an added         ]
;; [ feature.  The function is called with an extra argument, namely,          ]
;; [ a word that is the name of a function.  When the data grid is             ]
;; [ generated, the first item in each row will be "hot" so to speak,          ]
;; [ so that when it is clicked something will happen.  What will happen       ]
;; [ is that the function named by the name you passed will be called.         ]
;; [ The call to the function will pass the value of that first column         ]
;; [ that you clicked.  It is your job to create, in your program,             ]
;; [ a function with that name, that takes on argument.  What the function     ]
;; [ does is up to you.                                                        ]
;; [---------------------------------------------------------------------------]

GLOC-BOXHEIGHT: 500 
GLOC-BOXWIDTH: 0
GLOC-BOXSIZE: none 

GLOC-LAYOUT: func [
    GLOCBLOCK
    GLOCWIDTHS
    GLOCFUNC
    /local GLOCGRID GLOCDISP GLOCCOL
] [
    GLOC-BOXWIDTH: 0
    foreach WIDTH GLOCWIDTHS [
        GLOC-BOXWIDTH: GLOC-BOXWIDTH + WIDTH
    ]
    GLOC-BOXSIZE: to-pair reduce [GLOC-BOXWIDTH GLOC-BOXHEIGHT] 
    GLOCGRID: copy [across space 0]
    foreach BLK GLOCBLOCK [
        GLOCCOL: 0
        foreach COL BLK [
            GLOCCOL: GLOCCOL + 1
            append GLOCGRID compose [
                info (pick GLOCWIDTHS GLOCCOL) (form COL) 'bold
            ]
            if equal? GLOCCOL 1 [
                append GLOCGRID compose/deep [ 
                    [(to-word reduce GLOCFUNC) value]
                ]
            ]
         ]
         append GLOCGRID compose [return]
    ]
    GLOCDISP: layout/tight [
        across
        GLOCBOX: box GLOC-BOXSIZE with [ ;; "with" gets us to layout internals 
            pane: layout/tight GLOCGRID pane/offset: 0x0
        ]
        scroller to-pair reduce [20 second GLOC-BOXSIZE] [
            GLOCBOX/pane/offset/y: GLOCBOX/size/y - GLOCBOX/pane/size/y * value
            show GLOCBOX
        ]
    ]
    return GLOCDISP
]

;Uncomment to test
;CALLED: func [
;    VAL
;] [
;    print VAL
;]
;view center-face GLOC-LAYOUT [
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
;] [40 60 100] 'CALLED
  
