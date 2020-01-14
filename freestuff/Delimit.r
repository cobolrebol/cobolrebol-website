REBOL [
    Title: "Delimit"
    Purpose: {Put some sort of delimiters around one line of text
    in the clipboard.}
]

L-DELIM: ""
R-DELIM: ""

DELIMIT: func [
    LDELIM
    RDELIM
] [
    write clipboard:// rejoin [
        LDELIM
        trim/with read clipboard:// "^/"
        RDELIM
    ]
]

MAIN-WINDOW: layout [
    across
    banner "Put delimiters on clipboard text"
    return
    button 120 "Double quotes" [DELIMIT {"} {"}]
    return
    button 120 "Single quotes" [DELIMIT {'} {'}]
    return 
    button 120 "Braces"        [DELIMIT "{" "}"]
    return
    button 120 "Parentheses"   [DELIMIT "(" ")"]
    return
    button 120 "Quit" [quit]
]

view center-face MAIN-WINDOW

