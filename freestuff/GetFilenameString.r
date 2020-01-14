REBOL [
    Title: "Get file name as string"
    Purpose: {Request a directory, make a list of all files
    in the directory, and display the list.  When a file is
    picked, copy the file name as a string to the clipboard.
    This was written as a documentation aid when lots of file
    names had to be written into documentation.}
]

STARTING-LOCATION: %/C/
change-dir STARTING-LOCATION

if not FOLDER: request-dir [
    alert "No folder requested"
    quit
]

change-dir FOLDER
FILE-LIST: read FOLDER
STRING-LIST: copy []
foreach FILE FILE-LIST [
    append STRING-LIST to-string FILE
]

CLIP-FILENAME: does [
    write clipboard:// first MAIN-FILES/picked
]

view layout [
    across
    MAIN-FILES: text-list 300x700 data STRING-LIST [CLIP-FILENAME]
    return 
    button "Quit" [quit]
    button "Debug" [halt] 
]

