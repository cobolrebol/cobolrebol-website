REBOL [
    Title: "Folder monitor"
    Purpose: {To be run every day; check the contents of a hard-coded
    folder to see what is new or missing compared to the contents of
    the folder the previous day.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a program for the very specific project of checking, every day,   ]
;; [ the contents of a particular folder, the name of which is coded into      ]
;; [ this program.  The program makes a list of the files in the folder and    ]
;; [ sorts the list.  Then it compares the sorted list with a similar list     ]
;; [ made at some time in the past, usually yesterday.  It makes two lists,    ]
;; [ a list of new files that have appeared, and a list of other files that    ]
;; [ have disappeared.  It formats these lists into a report and sends the     ]
;; [ report by email.                                                          ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Depending on your situation, you might have to manually load the          ]
;; [ user.r file that usually is generated automatically when you install      ]
;; [ REBOL.                                                                    ]
;; [---------------------------------------------------------------------------]

do %user.r 

;; [---------------------------------------------------------------------------]
;; [ The comparison of the two lists is in a separate function.                ]
;; [---------------------------------------------------------------------------]

do %CompareTwoOrderedLists.r

;; [---------------------------------------------------------------------------]
;; [ Change these hard-coded file names for your own situation.                ]
;; [---------------------------------------------------------------------------]

FOLDER-ID: %dest/
FILE-ID-TODAY: %ContentsToday.txt
FILE-ID-YESTERDAY: %ContentsYesterday.txt
EMAIL-LIST: [
    admin@yourcompanyname.com
]

;; -- Get a current list of the contents of the folder being monitored.

FILE-LIST-RAW: copy []
FILE-LIST-RAW: read FOLDER-ID/.
FILE-LIST-TODAY: copy []
foreach FILE FILE-LIST-RAW [
    append FILE-LIST-TODAY to-string FILE
]
sort FILE-LIST-TODAY 

;; -- Get a list of the files as of yesterday. 
;; -- If this is the very first run, the file for yesterday will not
;; -- exist, so make a blank list.

either exists? FILE-ID-YESTERDAY [
    FILE-LIST-YESTERDAY: read/lines FILE-ID-YESTERDAY
] [
    FILE-LIST-YESTERDAY: copy []
]

;; -- Compare the two lists of file names.

MISMATCHES: COMPARE-TWO-ORDERED-LISTS FILE-LIST-TODAY FILE-LIST-YESTERDAY

;; -- Format a text report to be emailed.

REPORT: copy ""
append REPORT rejoin [
    "Monitoring report for: "
    FOLDER-ID
    newline newline
]
append REPORT rejoin [
    "New files in this folder:"
    newline newline 
]
foreach FILE MISMATCHES/1 [
    append REPORT rejoin [
        FILE
        newline
    ]
]
append REPORT newline
append REPORT rejoin [
    "Files missing from this folder:"
    newline newline
]
foreach FILE MISMATCHES/2 [
    append REPORT rejoin [
        FILE
        newline
    ] 
]

;; -- Send the report to everyone on the list

send EMAIL-LIST REPORT

;; -- Make today's list into yesterday's list for tomorrow's check.

write/lines FILE-ID-YESTERDAY FILE-LIST-TODAY

quit


