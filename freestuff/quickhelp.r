REBOL [
    Title: "Quickhelp"
    Purpose: {This is a function that takes a big string of documentation
    and pops it up on a window with a scroll bar.  The purpose is to provide
    quick access to short documentation from text coded into a program.}
]

QUICKHELP: func [
    TXT
] [
    QH-WINDOW: layout [
        across
        banner "Quick help"
        return
        QH-TXT: info 600x600 wrap
            font [size: 14 style: 'bold]
        QH-SCROLLER: scroller 20x600 
            [scroll-para QH-TXT QH-SCROLLER]
        return
        button "Close" [hide-popup]
    ]
    QH-TXT/text: TXT
    QH-TXT/line-list: none
    QH-TXT/para/scroll/y: 0
    QH-TXT/user-data: second size-text QH-TXT
    QH-SCROLLER/data: 0
    QH-SCROLLER/redrag QH-TXT/size/y / QH-TXT/user-data
    inform QH-WINDOW
]

;;Uncomment to test
;HELPTEXT: {Quick help

;This is a function to be included in another program, and that will,
;when called with a string of documentation, pop up that documentation
;in an 'inform' window.

;Normally, documentation would not be coded into a program because it
;takes space.  This function is meant for a minimum amount of
;documentation (or text for any purpose) that is meant to be accessed
;quickly, like with a button.}
;view center-face layout [
;    banner "Quickhelp test"
;    button "Quickhelp" [QUICKHELP HELPTEXT]
;    button "Quit" [quit]
;]

