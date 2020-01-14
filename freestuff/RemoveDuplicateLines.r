REBOL [
    Title: "Remove duplicate lines from a text file"
    Purpose: {Read a text file, examine each line, and delete
    any line that exactly the same as the one before it.}
]

if not FILE-ID: request-file/only [
    alert "No file requested."
    quit
]
OUTPUT-ID: %Unduplicated.txt
ERROR-ID: %DroppedLines.txt

print "Loading file"
FILE-LINES: read/lines FILE-ID
OUTPUT-LINES: copy []

PREVIOUS-LINE: copy ""
LINES-IN: 0
LINES-OUT: 0
LINES-REMOVED: 0

ERROR-LIST: ""

print "Filtering file"
;halt
foreach LINE FILE-LINES [
    LINES-IN: LINES-IN + 1
    either equal? LINE PREVIOUS-LINE [
        LINES-REMOVED: LINES-REMOVED + 1
        append ERROR-LIST rejoin [
            "Line " LINES-IN ": "
            LINE
            newline
        ]
    ] [
        append OUTPUT-LINES LINE
        LINES-OUT: LINES-OUT + 1
    ]
    PREVIOUS-LINE: copy LINE
]

print "Writing non-duplicate lines"
write/lines OUTPUT-ID OUTPUT-LINES

write ERROR-ID ERROR-LIST 
print ["LINES IN: " LINES-IN "; LINES OUT: " LINES-OUT "; LINES REMOVED: " LINES-REMOVED]
halt


