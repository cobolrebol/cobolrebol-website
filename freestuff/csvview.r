REBOL [
    Title:  "Demo shell for the csvbrowser functions"
]

do %csvbrowser.r 

either SOURCE-FILE-ID: request-file/only [
    CSV-OPEN SOURCE-FILE-ID 
    CSV-READ-FIRST
    view layout CSV-WINDOW 
] [
    alert "No file requested"
]

