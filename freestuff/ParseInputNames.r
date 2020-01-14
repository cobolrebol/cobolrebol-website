REBOL [
    Title: "Parse html form for input names"
    Purpose: {Given the name of a valid html file that contains
    a form, return the "name" attributes of all "input" tags.}
]

;; [---------------------------------------------------------------------------]
;; [ This function was part of a code generation project to ease the           ]
;; [ burden of creating a program that processes an html form.                 ]
;; [ The handling of "input" items is similar for each item so if one          ]
;; [ could obtain the "name" attributes of the "input" items in an html        ]
;; [ form, one ought to be able to generate the code to process them.          ]
;; [ This function read a specified file and parses it for the "name"          ]
;; [ attriubtes which are expected to be specified for each "input" item.      ]
;; [ The names are returned in a block, and the caller can do with them        ]
;; [ what he likes.                                                            ]
;; [---------------------------------------------------------------------------]

PARSE-INPUT-NAMES: func [
    HTMLFILE
    /local HTMLTEXT NAMES
] [
    HTMLTEXT: read HTMLFILE
    NAMES: copy []
    parse HTMLTEXT [
        any [thru {name="} copy NM to {"} (append NAMES to-string NM)] to end 
    ]
    return NAMES
]

;;Uncomment to test
;write %testhtmlform.html {
;<html>
;<head><title></title></head>
;<body>
;<form action="http://website/cgi-bin/testprogram.py" method="post">
;Data-name-1: <input type="text" size="30" name="DATA-NAME-1"><br>
;Data-name-2: <input type="text" size="30" name="DATA-NAME-2"><br>
;Data-name-3: <input type="text" size="30" name="DATA-NAME-3"><br>
;<input type="submit" name="SUBMITBUTTON" value="Process">
;</form>
;</body>
;</html>
;}
;probe PARSE-INPUT-NAMES %testhtmlform.html
;halt

