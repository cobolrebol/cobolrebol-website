REBOL [
    Title: "Print labels"
    Purpose: {Provide functions used to put labels on paper.}
]

;; [---------------------------------------------------------------------------]
;; [ This module provides functions for emitting four-line labels into an      ]
;; [ html file in such a way that if you print the html page you will get      ]
;; [ a printout that can be put onto Avery 5160 labels.                        ]
;; [ There are some constraints.                                               ]
;; [ The first page of labels comes out fine, but following pages have to      ]
;; [ be fussed with.  It appears to work if you do a print preview and         ]
;; [ shorten up the bottom of the first page.  That seems to fix up the        ]
;; [ alignment of a second page.                                               ]
;; [ You have to set up printing preferences to take out any headers, footers, ]
;; [ page numbers, and any other ornamentation.                                ]
;; [ It appears that the person who figured this out went through a bit of     ]
;; [ trial and error and never did get it just right.                          ]
;; [ Reference:                                                                ]
;; [ https://boulderinformationservices.wordpress.com/                         ]
;; [     2011/08/25/print-avery-labels-using-css-and-html/                     ]
;; [                                                                           ]
;; [ So how does this work?                                                    ]
;; [ Define the body of the html page as being 8.5 inches wide.                ]
;; [ Define a class called "label" that is defined as the appropriate size.    ]
;; [ For each label, emit to the html the four lines of data as a label        ]
;; [ class.  Because the label size is defined, and the page width is          ]
;; [ restricted, the labels will go on the page left to right and will         ]
;; [ overflow to the next line every three labels.  This makes "printing"      ]
;; [ one label very simple and it makes printing many labels a matter of       ]
;; [ just printing one after the other without regard to fussing with things   ]
;; [ like counting every three labels for a line break and so on.              ]
;; [                                                                           ]
;; [ If a person did have to do lots of labels, and the first page always      ]
;; [ comes out aligned correctly, one could modify this module to emit         ]
;; [ several html files, with each html file being one page of labels.         ]
;; [ Yes, that is not a pretty solution, but remember that neither REBOL       ]
;; [ not html is designed for page layouts on paper.  Sometimes we must        ]
;; [ work with what we have and make the best of it.                           ]
;; [---------------------------------------------------------------------------]

LBL: make object! [

    FILE-ID: %LABELS.html 
    LABELS: copy ""
    HEADING-EMITTED: false

    HTML-START: rejoin [
        "<html>" newline
        "<head>" newline
        "<style>" newline
        "body {" newline
        "width: 8.5in;" newline
        "margin-top: .125in;" newline
        "margin-right: .1875in;" newline
        "margin-left: 0in;" newline
        "}" newline
        ".label {" newline
        "/* Avery 5160 labels -- CSS and HTML by MM at Boulder Information Services */"
        newline
        "width: 2.025in; /* plus .6 inches from padding */" newline
        "height: .875in; /* plus .125 inches from padding */" newline
        "padding: .125in .3in 0;" newline
        "margin-right: .125in; /* the gutter */" newline
        "float: left;" newline
        "text-align: left;" newline
        "overflow: hidden;" newline
        "outline: 1px dotted; /* outline doesn't occupy space like border does */"
        newline
        "}" newline
        "</style>" newline
        "</head>" newline
        "<body>" newline
    ]

    HTML-LAB: rejoin [
        {<div class="label">}
        "%%LINE1%%<br>"
        "%%LINE2%%<br>"
        "%%LINE3%%<br>"
        "%%LINE4%%<br>"
        "</div>" 
    ]

    HTML-END: {</body></html>}

    CLEAR-LABELS: does [
        LABELS: copy ""
        HEADING-EMITTED: false
    ]

    CLOSE-LABELS: does [
        append LABELS HTML-END 
        write FILE-ID LABELS
        browse FILE-ID
    ]

    EMIT-LABEL: func [
        LINE1
        LINE2
        LINE3
        LINE4
    ] [
        if not HEADING-EMITTED [
            append LABELS HTML-START
            HEADING-EMITTED: true
        ]
        WS-LAB: copy HTML-LAB
        replace WS-LAB "%%LINE1%%" LINE1
        replace WS-LAB "%%LINE2%%" LINE2
        replace WS-LAB "%%LINE3%%" LINE3
        replace WS-LAB "%%LINE4%%" LINE4 
        append LABELS WS-LAB                
        append LABELS newline
    ]
]

;;Uncomment to test
;LBL/EMIT-LABEL "Adam Adamson" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Ben Braddock" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Charles Carlson" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Donald Davis" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Everett Evenson" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Francis Fisk" "1800 1st St" "Boston MA 00000" "USA"
;LBL/EMIT-LABEL "Gerald George" "1800 1st St" "Boston MA 00000" "USA"
;LBL/CLOSE-LABELS

