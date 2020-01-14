REBOL [
    Title: "Multi-Category Description Table"
    Purpose: {An object for create a description lookup table
    that can combine several tables into one, with the tables
    identified by a category code.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a module to address a situation that comes up in database work.   ]
;; [ If a database has various codes that represent things, it is nice to      ]
;; [ provide descriptions of those codes in anything produced for human use.   ]
;; [ If the actual code is the description, that can use up space in the       ]
;; [ database, and the description never can change unless one wants to go     ]
;; [ through the entire databse and change any descriptions that already are   ]
;; [ in there.  So it is customary to use codes to represent things, and to    ]
;; [ put the human-readable meaning of the codes in another table.             ]
;; [ If a database has many codes, that can result in many description         ]
;; [ tables, OR, one can find a way to put all such codes and their            ]
;; [ descriptions into one big table.  This module is a way to do that.        ]
;; [                                                                           ]
;; [ The end result of this will be a bunch of description tables, each        ]
;; [ consisting of a bunch of codes with a description for each code.          ]
;; [ Each table will be identified by a category code.                         ]
;; [ So, to find a description for some code, you have to find the table it    ]
;; [ is in by supplying the category code, and also the code for which         ]
;; [ you want the description.  This will be implemented in a big block        ]
;; [ that will look like this:                                                 ]
;; [                                                                           ]
;; [ [                                                                         ]
;; [     category-1 [code-1-1 desc-1-1 code-1-2 desc-1-2 ...]                  ]
;; [     category-2 [code-2-1 desc-2-1 code-2-2 desc-2-2 ...]                  ]
;; [     category-3 [code-3-1 desc-3-1 code-3-2 desc-3-2 ...]                  ]
;; [ ]                                                                         ]
;; [                                                                           ]
;; [ With a structure like this, if we want to find the descripion for a       ]
;; [ certain code in a certain category, we just have to "select" on the       ]
;; [ category to get the table, and then select code to get the description.   ]
;; [ This module provides a function to do that.                               ]
;; [                                                                           ]
;; [ Also, we have to build that multi-category table in the first place.      ]
;; [ A function is provided so you can supply a caegory, a code, and a         ]
;; [ description and they will be put into the table.                          ]
;; [ In case you can get your table data into a block of blocks, perhaps       ]
;; [ as the result of an SQL query, a function is provided to load the         ]
;; [ table from that direction.                                                ]
;; [                                                                           ]
;; [ More specifically:                                                        ]
;; [                                                                           ]
;; [ LOAD-ENTRY category code description                                      ]
;; [ This function is called repeatedly to load codes into the table.          ]
;; [ If you want to save the final table and have it look nice, you could      ]
;; [ provide the items in category-code order, but it is not necessary.        ]
;; [ It should not matter what types of data you use for the category,         ]
;; [ code, and description, but usually these would be strings.                ]
;; [                                                                           ]
;; [ LOAD-RESULTSET resultset                                                  ]
;; [ This function is called with all the table data in a block of blocks,     ]
;; [ where each sub-block contains a category, a code, and a description,      ]
;; [ all of them strings.  The function will call LOAD-ENTRY repeatedly        ]
;; [ for all the sub-blocks in the outer block.                                ]
;; [                                                                           ]
;; [ GET-DESCRIPTION category code                                             ]
;; [ This function returns the description string for the code supplied.       ]
;; [                                                                           ]
;; [ SAVE-TABLE file-id                                                        ]
;; [ This function saves a finished table to a text file.                      ]
;; [                                                                           ]
;; [ LOAD-TABLE file-id                                                        ]
;; [ This function loads a table previously saved with the SAVE-TABLE          ]
;; [ function.                                                                 ]
;; [                                                                           ]
;; [ And finally, all this is packaged into an object so you could have        ]
;; [ several such table in your program, although the purpose of this          ]
;; [ object in the first place is so that you don't need more than one         ]
;; [ table.                                                                    ]
;; [---------------------------------------------------------------------------]

MCDT: make object! [

    DESCRIPTIONS: []

    LOAD-ENTRY: func [
        CATEGORY
        CODE
        DESCRIPTION
        /local LOC BLK
    ] [
        LOC: head DESCRIPTIONS
        LOC: find DESCRIPTIONS CATEGORY
        either LOC [
            BLK: first next LOC ;; a reference, not a copy 
            append BLK CODE
            append BLK DESCRIPTION
        ] [
            BLK: copy []
            append BLK CODE
            append BLK DESCRIPTION
            append DESCRIPTIONS CATEGORY
            append/only DESCRIPTIONS BLK
        ]
    ]

    LOAD-RESULTSET: func [
        RESULTSET
    ] [
        DESCRIPTIONS: copy []
        foreach SUBBLOCK RESULTSET [
            LOAD-ENTRY SUBBLOCK/1 SUBBLOCK/2 SUBBLOCK/3
        ]
    ]

    GET-DESCRIPTION: func [
        CATEGORY
        CODE
    ] [
        either TBL: select DESCRIPTIONS CATEGORY [
            return SELECT TBL CODE
        ] [
            return none
        ]
    ]

    SAVE-TABLE: func [
        FILE-ID
    ] [
;;      save FILE-ID DESCRIPTIONS  ;; Instead, make it look nicer...
        if exists? FILE-ID [
        delete FILE-ID 
        ]
        foreach [CATEGORY TABLE] DESCRIPTIONS [
            write/append FILE-ID rejoin [
                mold CATEGORY
                " ["
                newline
            ]
            foreach [CODE DESC] TABLE [
                write/append FILE-ID rejoin [
                    "    "
                    mold CODE 
                    " "
                    mold DESC
                    newline
                ]
            ]
            write/append FILE-ID rejoin [
                "]"
                newline
            ]
        ]
    ]

    LOAD-TABLE: func [
        FILE-ID
    ] [
        DESCRIPTIONS: copy []
        DESCRIPTIONS: load FILE-ID
    ]
]

;;Uncomment to test
;MCDT/LOAD-ENTRY "WIND-DIR" "1" "North"
;MCDT/LOAD-ENTRY "WIND-DIR" "2" "Northeast"
;MCDT/LOAD-ENTRY "WIND-DIR" "3" "East"
;MCDT/LOAD-ENTRY "WIND-DIR" "4" "Southeast"
;MCDT/LOAD-ENTRY "WIND-DIR" "5" "South"
;MCDT/LOAD-ENTRY "WIND-DIR" "6" "Southwest"
;MCDT/LOAD-ENTRY "WIND-DIR" "7" "West"
;MCDT/LOAD-ENTRY "WIND-DIR" "8" "Northwest"
;MCDT/LOAD-ENTRY "WIND-DIR" "9" "Shifting winds"
;MCDT/LOAD-ENTRY "WIND-DIR" "N" "None/Calm"
;MCDT/LOAD-ENTRY "WIND-DIR" "U" "Undetermined"
;MCDT/LOAD-ENTRY "TAKEN" "0" "Taken to other"
;MCDT/LOAD-ENTRY "TAKEN" "1" "Hospital"
;MCDT/LOAD-ENTRY "TAKEN" "2" "Doctor's office"
;MCDT/LOAD-ENTRY "TAKEN" "3" "Morgue or funeral home"
;MCDT/LOAD-ENTRY "TAKEN" "4" "Residence"
;MCDT/LOAD-ENTRY "TAKEN" "5" "Station or quarters"
;MCDT/LOAD-ENTRY "TAKEN" "6" "Not transported"
;MCDT/LOAD-ENTRY "ACENGINE" "1" "Jet"
;MCDT/LOAD-ENTRY "ACENGINE" "2" "Turbo Prop"
;MCDT/LOAD-ENTRY "ACENGINE" "3" "Propeller"
;MCDT/LOAD-ENTRY "ACENGINE" "4" "None (Glider)"
;foreach [CATEGORY TABLE] MCDT/DESCRIPTIONS [
;    print [CATEGORY mold TABLE]
;]
;print "------------------------------------"
;print ["ACENGINE 2 = " MCDT/GET-DESCRIPTION "ACENGINE" "2"]
;print ["WIND-DIR 6 = " MCDT/GET-DESCRIPTION "WIND0DIR" "6"] ;; error
;print ["WIND-DIR U = " MCDT/GET-DESCRIPTION "WIND-DIR" "U"]
;print ["TAKEN 7 = " MCDT/GET-DESCRIPTION "TAKEN" "7"]
;print "------------------------------------"
;MCDT/SAVE-TABLE %tbltest.txt
;MCDT/LOAD-TABLE %tbltest.txt
;RESULTSET: [
;    ["ACFUEL" "1" "Jet Aviation Fuel"]
;    ["ACFUEL" "2" "Aviation Gasoline"]
;    ["ACFUEL" "3" "Other type of fuel"]
;    ["PAT_STAT" "1" "Improved"]
;    ["PAT_STAT" "2" "Remained Same"]
;    ["PAT_STAT" "3" "Worsened"]
;]
;MCDT/LOAD-RESULTSET RESULTSET
;foreach [CATEGORY TABLE] MCDT/DESCRIPTIONS [
;    print [CATEGORY mold TABLE]
;]
;halt

