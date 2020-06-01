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
;; [ It appears that the "info" style has a certain default size, and it       ]
;; [ would be your job to create an instance of this object with a             ]
;; [ BOXSIZE wide enough to hold the number of columns you expect.             ]
;; [ Without a huge amount of fussing, there seems to be no reasonable way     ]
;; [ to tailor the sizes of the info fields, so we just take the default.      ]
;; [---------------------------------------------------------------------------]

GRIDLAYOUT: make object! [
    BOXSIZE: 400X500  ;; This default size will handle two columns.

    GRID-LAYOUT: func [
        DATABLOCK
        /local GRID DISPLAY
    ] [
        GRID: copy [across space 0]
        foreach BLK DATABLOCK [
            foreach COL BLK [
                append GRID compose [
                    info (form COL)
                ]
             ]
             append GRID compose [return]
        ]
        DISPLAY: layout [
            across
            DISPBOX: box BOXSIZE with [  ;;;;; What is the "with" keyword?
                pane: layout/tight GRID pane/offset: 0x0
            ]
            scroller to-pair reduce [20 second BOXSIZE] [
                DISPBOX/pane/offset/y: DISPBOX/size/y - DISPBOX/pane/size/y * value
                show DISPBOX
            ]
        ]
        return DISPLAY
    ]
]

;;Uncomment to test
;GL1: make GRIDLAYOUT [
;    BOXSIZE: 600X500
;]
;view GL1/GRID-LAYOUT [
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
;]
   
