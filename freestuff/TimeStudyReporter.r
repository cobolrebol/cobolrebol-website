REBOL [
    Title: "Simple time recorder report"
    Purpose: {Report on time coupons from TimeStudyRecorder.r}
]

START-LOC: %/C/
COUPON-FOLDER: %TimeCoupons/
REPORT-FILE-ID: %ReportFile.csv
REPORT-TEXT: ""

change-dir START-LOC
change-dir COUPON-FOLDER
if not COUPON-SUBFOLDER: request-dir [
    alert "No folder requested"
    quit
]
change-dir COUPON-SUBFOLDER

append REPORT-TEXT rejoin [
    replace to-string second split-path COUPON-SUBFOLDER "/" ""
    ",,"
    newline
]
append REPORT-TEXT rejoin [
    "Work,"
    "Detail,"
    "Time Spent"
    newline
]

TOTAL-TIMESPENT: 0.00

PROCESS-COUPON: func [
    FILEID
] [
    do load FILEID
    replace/all ACTIVITY newline " "
    replace/all ACTIVITY "," " "
    print [FILEID ":" START-TIME " to " END-TIME ":" TIMESPENT " hours:"  SUMMARY]
    if TIMESPENT [
        TOTAL-TIMESPENT: TOTAL-TIMESPENT + TIMESPENT
    ]
    append REPORT-TEXT rejoin [
        SUMMARY ","
        ACTIVITY ","
        60 * TIMESPENT newline
    ]
]

FILE-LIST: read %.

foreach FILEID FILE-LIST [
    PROCESS-COUPON FILEID
]
append REPORT-TEXT rejoin [
    "Total,,"
    to-string 60 * TOTAL-TIMESPENT
    newline    
]

change-dir START-LOC
change-dir COUPON-FOLDER
write REPORT-FILE-ID REPORT-TEXT

print ["Total time spent: " TOTAL-TIMESPENT] 
print "Done."

browse REPORT-FILE-ID 
halt

