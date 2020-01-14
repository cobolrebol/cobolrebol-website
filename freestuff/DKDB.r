REBOL [
    Title: "Duplicate Key Data Blocks"
    Purpose: {Provide a data structure for reporting attributes of
    key values that might be duplicated in a file.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a module that provides a specific data structure for a specific   ]
;; [ problem.  The original problem was locating multiple sales for            ]
;; [ properties, where a sale is one record from an SQL query, containing      ]
;; [ an ID number (the key) and an owner name plus a sale date (attributes     ]
;; [ of the key).  The data from those sales records is loaded into a block    ]
;; [ using a provided function, another optional function sorts the block      ]
;; [ on the key to group together all sales for an ID, and then another        ]
;; [ function loads all the records for a single ID into a single block        ]
;; [ consisting of the key plus one block that contains all the attribute      ]
;; [ blocks of the individual sales records.  In other words:                  ]
;; [                                                                           ]
;; [ Input:  any records that contain some key value and some attributes       ]
;; [ on each record.  Use the function provided to load, for each record,      ]
;; [ the key plus the attributes in a block.  Put these items into             ]
;; [ DKDB/INPUTBLOCK, like this:                                               ]
;; [ [                                                                         ]
;; [    [key1 [attributes-1-1]]                                                ]
;; [    [key2 [attributes-2-1]]                                                ]
;; [    [key2 [attributes-2-2]]                                                ]
;; [    [key3 [attributes-3-1]]                                                ]
;; [ ]                                                                         ]
;; [ Note that you must append to DPDB/INPUTBLOCK a key value and a block,     ]
;; [ over and over again.  A function is provided to do this, DKDP/LOADINPUT.  ]
;; [ Note also that sometimes a key will appear more than once with            ]
;; [ different attribute blocks.  Note also that some of the key values        ]
;; [ do appear just once.                                                      ]
;; [                                                                           ]
;; [ Sorting:  DPDB/INPUTBLOCK must contain the keys in order.  If your        ]
;; [ source data is in order, then everything is good.  Otherwise you          ]
;; [ may use the function DKDB/SORTINPUT to sort the input block on the key.   ]
;; [                                                                           ]
;; [ Reading:  Now, what are you going to do with the data in INPUTBLOCK?      ]
;; [ You are going to run the function DPDB/READNEXT and it is going to        ]
;; [ return a block.  That block will consist of the next unique key plus      ]
;; [ a block that contains sub-blocks, and each sub-block is one of the        ]
;; [ attributes blocks for that key.  In other words, three calls to           ]
;; [ READNEXT on the above example will return the following three results.    ]
;; [     [key1 [[attributes-1-1]]]                                             ]
;; [     [key2 [[attributes-2-1] [attributes-2-2]]]                            ]
;; [     [key3 [[attributes-3-1]]]                                             ]
;; [                                                                           ]
;; [ What do you so with the data rearranged in this manner?                   ]
;; [ In the original application, the key value was a property identifier      ]
;; [ and each attribute block was sales data, showing an owner name and        ]
;; [ a sale date.  So for key2, the block after key2 would consist of two      ] 
;; [ blocks representing two sales.                                            ]
;; [                                                                           ]
;; [ This data structure and functions is packaged into an object for a        ]
;; [ specific reason.  In the original application, a sales attribute          ]
;; [ block consisted of a name and a sale date, and in some situations         ]
;; [ the name was duplicated.  In other words, a person sold a property        ]
;; [ to himself.  So the attribute blocks are another source of data           ]
;; [ for this function.  With the object structure, we can make a second       ]
;; [ DKDB object and use it on the sales data to identify properties           ]
;; [ that had sales to the same person.  In this case, the key value           ]
;; [ would be the owner name, and the attribute block would contain just       ]
;; [ one item, the sale date.                                                  ]
;; [                                                                           ]
;; [ Note that the above scenario, where a first set of data is put into       ]
;; [ a DKDB object and then subsets of the first data are repeatedly put       ]
;; [ into a second DKDB means that we must have a function to clear the        ]
;; [ INPUTBLOCK so we can use it over and over again in a program,             ]
;; [ and we do have such a function, DKDB/CLEARINPUT.                          ]
;; [                                                                           ]
;; [ Notes on the READNEXT function.  It always is tricky to read through      ]
;; [ a list of things that fall into groups, and know when you are at          ]
;; [ the end of a group.  For the READNEXT function, we want to gather         ]
;; [ all blocks in INPUTBLOCK that have the same key.  We will not know        ]
;; [ that we are done picking for one key until we have the first item         ]
;; [ for the next key, or have hit the end of INPUTBLOCK.  That is the         ]
;; [ key to understanding how we will proceed.  CURRENTREC is a pointer        ]
;; [ to the item in INPUTBLOCK that we currently are "at" so to speak.         ]
;; [ On the first call, CURRENTREC will be 1.  On a subsequent call,           ]
;; [ CURRENTREC will point to the first item with a key that differs from      ]
;; [ the last item we picked on the previous call, or it will be one           ]
;; [ greater than the size of INPUTBLOCK if the previous call took us to       ]
;; [ the end.  If we call READNEXT when the previous call took us to the       ]
;; [ last item, we will set EOF to true and can use that to detect the         ]
;; [ "end of file" situation.                                                  ]
;; [---------------------------------------------------------------------------]

DKDB: make object! [
    
    DEBUG: false
    INPUTBLOCK: []
    INPUTSIZE: 0
    CURRENTREC: 1
    CURRENTKEY: ""
    EOF: false

    CLEARINPUT: does [
        INPUTBLOCK: copy []
        INPUTSIZE: 0
        CURRENTREC: 1
        CURRENTKEY: ""
        EOF: false
    ]
    
    LOADINPUT: func [
        KEYVALUE [string!]
        ATTRIBUTEBLOCK [block!]
        /local TEMPBLOCK
    ] [
        TEMPBLOCK: copy []
        append TEMPBLOCK KEYVALUE
        append/only TEMPBLOCK ATTRIBUTEBLOCK
        append/only INPUTBLOCK TEMPBLOCK
        INPUTSIZE: INPUTSIZE + 1
    ]

    SORTINPUT: does [
        SORTBLOCK: copy []
        foreach REC INPUTBLOCK [
            append SORTBLOCK REC/1
            append/only SORTBLOCK REC/2
        ]
        sort/skip SORTBLOCK 2
        INPUTBLOCK: copy []
        foreach [KEY ATTR] SORTBLOCK [
            TEMPBLOCK: copy []
            append TEMPBLOCK KEY
            append/only TEMPBLOCK ATTR
            append/only INPUTBLOCK TEMPBLOCK
        ]
    ]

    READNEXT: does [
        if DEBUG [
            print ["Reading from " CURRENTREC]
        ]
        if greater? CURRENTREC INPUTSIZE [
            EOF: true
            return RETURNBLOCK: copy []
            if DEBUG [
                print "EOF"
            ]
        ]
        RETURNBLOCK: copy []
        ATTRBLOCK: copy []
        CURRENTKEY: INPUTBLOCK/:CURRENTREC/1
        while [(lesser-or-equal? CURRENTREC INPUTSIZE)] [
            either (equal? CURRENTKEY INPUTBLOCK/:CURRENTREC/1) [ 
                append/only ATTRBLOCK INPUTBLOCK/:CURRENTREC/2
                CURRENTREC: CURRENTREC + 1 
            ] [
                break
            ]
        ]  
        append RETURNBLOCK CURRENTKEY
        append/only RETURNBLOCK ATTRBLOCK
        if DEBUG [
            print ["Returning " mold RETURNBLOCK]
        ]
        return RETURNBLOCK            
    ]
]

;;Uncomment to test
;DKDB/DEBUG: true
;DKDB/LOADINPUT "key1" ["attr-1-1-1" "attr-1-1-2"]
;DKDB/LOADINPUT "key2" ["attr-2-1-1" "attr-2-1-2"]
;DKDB/LOADINPUT "key2" ["attr-2-2-1" "attr-1-2-2"]
;DKDB/LOADINPUT "key3" ["attr-3-1-1" "attr-3-1-2"]
;DKDB/SORTINPUT
;print ["INPUTBLOCK: " mold DKDB/INPUTBLOCK]
;print mold DKDB/READNEXT
;print mold DKDB/READNEXT
;print mold DKDB/READNEXT
;halt

