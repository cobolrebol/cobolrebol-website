REBOL [
    Title: "Spelling lists"
    Purpose: {Using a plain text file, build any number of named lists
    of the words in the file.  The original use was to put the words 
    into a text-list and when a word is selected copy it to the clipboard. 
    This was created as part of a program to help people spell names and
    addresses consistently.}
]

;; [---------------------------------------------------------------------------]
;; [ This module was created to help people spell important names correctly    ]
;; [ by allowing them to pick a name from a list and having the name copied    ]
;; [ to the clipboard, from which it could be pasted somewhere.                ]
;; [                                                                           ]
;; [ The source of the spelling lists is one text file.  Each line of the      ]
;; [ text file contains one of the entities that must be spelled correctly.    ]
;; [ These "words" as we will call them are grouped into lists, so that        ]
;; [ we can have one program that can handle many lists.  A list is identified ]
;; [ by one line in the file that begins the list and contains a dollar sign   ]
;; [ in the first character.  After the dollar sign is a REBOL word that will  ]
;; [ become the name of a block that holds the words on the lines that follow. ]
;; [ All the lines that follow will belong on the list identified by the       ]
;; [ header line until the next header line or the end of the file.            ]
;; [ For example:                                                              ]
;; [     $COMPANYNAMES                                                         ]
;; [     Johnson Electic                                                       ]
;; [     Smith Plumbing                                                        ]
;; [     ...                                                                   ]
;; [     $STREETNAMES                                                          ]
;; [     1st AVE S                                                             ]
;; [     PENNSYLVANIA AVE                                                      ]
;; [     ...                                                                   ]
;; [ The result of executing the function that loads the spelling list will    ]
;; [ be two blocks, called COMPANYNAMES and STREETNAMES, and the contents      ]
;; [ of the blocks will be strings, each string being the text on one line     ]
;; [ of the text file.  In addition, there will be a block called CONTENTS     ]
;; [ that will contain the words COMPANYNAMES and STREETNAMES.  This contens   ]
;; [ block can be useful for generating code that refers to the lists.         ]
;; [                                                                           ]
;; [ And finally, this functionality is put into a context called              ]
;; [ SPELLINGS to guard against name conflicts.                                ]
;; [---------------------------------------------------------------------------]

SPELLINGS: context [
    WORDLIST: %Spellings.txt
    WORDDATA: []
    CONTENTS: []
    LIST-NAME: ""
    WORD-VALUE: ""
    CONTROL-CHARACTER: ""
    LOAD-LISTS: does [
        WORDDATA: read/lines WORDLIST
        foreach LINE WORDDATA [
            CONTROL-CHARACTER: copy ""
            CONTROL-CHARACTER: copy/part LINE 1
            either equal? "$" CONTROL-CHARACTER [
                LIST-NAME: copy ""
                LIST-NAME: trim/all/with LINE "$ "
                append CONTENTS to-word LIST-NAME
                do rejoin [LIST-NAME ": []"]
            ] [
                WORD-VALUE: copy ""
                WORD-VALUE: trim LINE
                do rejoin ["append " LIST-NAME " " mold WORD-VALUE]
            ] 
        ]
    ]
]

;; Uncomment to test 
;write %Spellings.txt {$COMPANYNAMES                                               
;Johnson Electic
;Smith Plumbing
;$STREETNAMES
;1st AVE S
;PENNSYLVANIA AVE}             
;SPELLINGS/LOAD-LISTS
;probe COMPANYNAMES 
;probe STREETNAMES
;halt

 
