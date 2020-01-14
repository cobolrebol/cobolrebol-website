REBOL [
    Title: "Remove front nodes of a file path"
    Purpose: {Given a full path file name, cut off a given
    number of the leading nodes, returning the remainder.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a very simple and very specific function for a very specific      ]
;; [ project.   The project was to check a massive movement of one folder of   ]
;; [ files to another location, keeping the same directory structure.          ]
;; [ It was like snipping off a branch of a direcory "tree" and grafting it    ]
;; [ onto a new branch.  We wanted to make sure nothing got lost in the        ]
;; [ transfer. Part of that was to generate the full path names of the old     ]
;; [ folders at the new location.                                              ]
;; [ This function takes one full path name, plus an integer, and cuts off     ]
;; [ the given number (specified by that integer) of nodes from the front,     ]
;; [ returning what is left.  Then, we attach "what is left" to the NEW        ]
;; [ folder location to get the full path of that directory in its new home,   ]
;; [ and we can do things like check to see if it exists, check how many       ]
;; [ files are in it, and so on.                                               ]
;; [ For example, we might have a folder like this:                            ]
;; [     /H/UTILBIL_OLD/@PHONE CALL LOG/03 MAR/2017/8760/                      ]
;; [ and that folder was copied to some place like this:                       ]
;; [     /NEWSERVER/UTILBIL/@PHONE CALL LOG/03 MAR/2017/8760/                  ]
;; [ We would want to take the path name from the old location and chop off    ]
;; [ the first two nodes, the /H/UTILBIL_OLD/, leaving the remainder,          ]
;; [ @PHONE CALL LOG/03 MAR/2017/8760/, then attach to the front of that       ]
;; [ "remainder" the new location, /NEWSERVER/UTILBIL/, to generate a new      ]
;; [ path name for the folder in its new location.                             ]
;; [ This function does not do any error checking.  To use it, you would       ]
;; [ have to be familiar with your data and know how many nodes to chop off    ]
;; [ for your specific situation.                                              ]
;; [---------------------------------------------------------------------------]

DEPATH: func [
    DIRECTORY
    REMOVECOUNT
    /local NODES PARTIALPATH
] [
    NODES: copy []
    NODES: parse/all trim DIRECTORY "/"
    loop REMOVECOUNT [
        remove NODES 
    ]
    PARTIALPATH: copy ""
    foreach NODE NODES [
        append PARTIALPATH NODE
        append PARTIALPATH "/"
    ]
    return to-file PARTIALPATH
]

;;Uncomment to test
;FOLDERNAMES: [
;    "/H/UTILBIL_OLD/@PHONE CALL LOG/03 MAR/2017/8760/"
;    "/H/UTILBIL_OLD/@PHONE CALL LOG/04 APR/8760 Maintenance/"
;]
;foreach FOLDER FOLDERNAMES [
;    print DEPATH FOLDER 3
;]
;halt


