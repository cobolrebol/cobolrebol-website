REBOL [
    Title: "Display text file line count"
    Purpose: {A little display program for video documentation.
    Requests a file name and displays the number of lines in it.}
]

if not FILE-ID: request-file/only [
    alert "No file requested"
    quit
]

FILE-LINES: read/lines FILE-ID
LINE-COUNT: length? FILE-LINES

view layout [
    across
    MAIN-FILE-NAME: info 400 (to-string FILE-ID)
    return
    label "Line count" 
    MAIN-LINE-COUNT: info 60 (to-string LINE-COUNT) 
]

