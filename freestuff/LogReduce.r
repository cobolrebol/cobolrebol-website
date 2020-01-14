REBOL [
    Title: "Log reduce function"
    Purpose: {Given the name of a text file and an number of lines as an 
    integer, cut lines off the front of the file to leave behind only 
    the specified number of lines.  Add a line to the front of the file
    to indicate that this change was made.  This function was created
    for reducing log files on programs that run continuously.}
]

;; [---------------------------------------------------------------------------]
;; [ The function expects a block containing a file name and an integer.       ]
;; [ The file name is a text file of log lines, and the integer is the         ]
;; [ number of lines we want to leave behind after we chop off the front       ]
;; [ of the file.                                                              ]
;; [---------------------------------------------------------------------------]

LOG-REDUCE: func [
    NAME-AND-SIZE 
    /local FILE-LINES SIZE-OF-FILE LINES-TO-DROP 
] [
    FILE-LINES: read/lines first NAME-AND-SIZE
    SIZE-OF-FILE: length? FILE-LINES
    LINES-TO-DROP: max 0 SIZE-OF-FILE - second NAME-AND-SIZE
    remove/part FILE-LINES LINES-TO-DROP
    insert head FILE-LINES rejoin [
        now
        " "
        "Log reduced by "
        LINES-TO-DROP
        " lines."
    ]
    FILE-LINES: head FILE-LINES
    write/lines first NAME-AND-SIZE FILE-LINES 
]

;;Uncomment to test
;LOGNAME: %testlog.txt
;write LOGNAME rejoin [now " BOJ" newline]
;loop 100 [
;    write/append LOGNAME rejoin [now " xxxx" newline]
;]
;LOG-REDUCE reduce [LOGNAME 25]
;halt

