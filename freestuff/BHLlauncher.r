REBOL [
    Title: "Basic help launcher"
    Purpose: {This small object is used to define a function
    that launches another program that displays a basic help
    window based on help in a basic text file.}
]

;; [---------------------------------------------------------------------------]
;; [ This is another scheme for providing help on a REBOL window.              ]
;; [ In this scheme, help is stored in a text file of topics.                  ]
;; [ Each topic is a string, and the associated help is a multi-line string.   ]
;; [ The help file would look like this:                                       ]
;; [     "topic one"                                                           ]
;; [     {Multi-line help text in braces}                                      ]
;; [     "topic two"                                                           ]
;; [     {More multi-line help text in braces}                                 ]
;; [     ... and so on                                                         ]
;; [ With a structure like this, the "select" function can be used to find     ]
;; [ the help text based on the help topic.                                    ]
;; [ Because we are trying to make a general-purpose program, we have to       ]
;; [ have a way to tailor it for specific uses.  Here is what we do.           ]
;; [ Include this module in your program; then...                              ]
;; [     MYHELPNAME: make BHL [                                                ]
;; [         HELPFILE: %myhelpfilename.txt                                     ]
;; [     ]                                                                     ]
;; [ The purpose of the above code is to define your own help file name        ]
;; [ so that this module can be general-purpose.                               ]
;; [ Also, you are not required to make a new object that is an instance       ]
;; [ of the BHL object.  You can just code:                                    ]
;; [     BHL/HELPFILE: %myhelpfilename.txt                                     ]
;; [ Now, as for how you display a help topic, you call a function,            ]
;; [ passing it a topic name, and the function launches another REBOL          ]
;; [ program that will load the whole help file, show a list of all topics,    ]
;; [ and display the requested topic.                                          ]
;; [ Note the implication of the above.  Every time you call for help,         ]
;; [ another separate program is launched, displaying another help window.     ]
;; [ Why not just change topics in the existing window?  Mainly because        ]
;; [ because I don't know how, but also because I can imagine scenarios        ]
;; [ where you want several help windows open to refer from one to the         ]
;; [ other.  Note also that when the help windows is open, the compplete       ]
;; [ list of topics is displayed, and you can move around among topics         ]
;; [ by selecting from the list.                                               ]
;; [ Another note: We want the help displayed by a separate program so that    ]
;; [ the help window could have no bad effects on the calling window.          ]
;; [ Also, for OS-independence, we use the "launch" function.                  ]
;; [ How does this module inform the launched program what file to use and     ]
;; [ what topic to show?  We will write that information into a one-line       ]
;; [ text file which the launched program will read.                           ]
;; [---------------------------------------------------------------------------]

BHL: make object! [
    HELPFILE: %defaulthelp.txt
    COMMFILE: %BHL-communication-file.txt
    COMMLINE: none
    DISPLAYERID: %BHLdisplayer.r 
    SHOWHELP: func [
        REQUESTEDTOPIC
    ] [
        COMMLINE: copy []
        append COMMLINE HELPFILE 
        append COMMLINE REQUESTEDTOPIC
        save COMMFILE COMMLINE
        launch DISPLAYERID
    ]
]

