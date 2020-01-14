REBOL [
    Title: "Text marker"
    Purpose: {Provide a little graphic that can be use on
    a screen to mark a place on some documentation being
    read.}
]

view center-face layout/tight [
    across
    space 0x0
    box 200x20 red "You are here =======>"
]

