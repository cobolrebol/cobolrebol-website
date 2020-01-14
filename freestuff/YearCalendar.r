REBOL [
    Title: "Quick full-year calendar"
    Purpose: {Display a full-year calendar in the middle of the monitor
    for a quick overview of the year.}
]

;; [---------------------------------------------------------------------------]
;; [ This script is borrowed from Nick Antonaccio's collection of demos.       ]
;; [ Instead of printing the calendar data to the console, it captures each    ]
;; [ month in a string and puts those 12 strings into a block.  Then is        ]
;; [ puts those 12 strings into text areas in a VID window.                    ]
;; [---------------------------------------------------------------------------]

monthblock: copy []
specifiedyear: ""

do [if "" = y: request-text/title "Year (ENTER for current)" [append specifiedyear y: now/year]
  foreach m system/locale/months [
    monthstring: copy ""
    append monthstring rejoin ["^/     " m "^/^/ "]
    foreach day system/locale/days [append monthstring join copy/part day 2 " "]
    append monthstring newline  f: to-date rejoin ["1-"m"-"y]  loop f/weekday - 1 [append monthstring "   "]
    repeat i 31 [
      if attempt [c: to-date rejoin [i"-"m"-"y]][
        append monthstring join either 1 = length? form i ["  "][" "] i
        if c/weekday = 7 [append monthstring newline] 
      ]
    ]
    append monthblock monthstring 
  ]
]

MAIN-WINDOW: layout [
    across
    space 0x0
    info 170x160 monthblock/1 font [name: font-fixed]
    info 170x160 monthblock/2 font [name: font-fixed]
    info 170x160 monthblock/3 font [name: font-fixed]
    return
    info 170x160 monthblock/4 font [name: font-fixed]
    info 170x160 monthblock/5 font [name: font-fixed]
    info 170x160 monthblock/6 font [name: font-fixed]
    return
    info 170x160 monthblock/7 font [name: font-fixed]
    info 170x160 monthblock/8 font [name: font-fixed]
    info 170x160 monthblock/9 font [name: font-fixed]
    return
    info 170x160 monthblock/10 font [name: font-fixed]
    info 170x160 monthblock/11 font [name: font-fixed]
    info 170x160 monthblock/12 font [name: font-fixed]
]

view center-face MAIN-WINDOW

