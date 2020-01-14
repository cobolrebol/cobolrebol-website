REBOL [
    Title: "Request a color and produce the html color value for it."
    Purpose: {This is a little helper used when hand-coding html. 
    It asks for a color which you select with sliders, and then produces
    the html color value.  This is explained in the REBOL function 
    dictionary for "to-hex."}
]

to-html-color: func [color [tuple!]] [
    to-issue enbase/base to-binary color 16
]

write clipboard:// mold join "#" to-string to-html-color request-color 

alert "Clipboard loaded."

