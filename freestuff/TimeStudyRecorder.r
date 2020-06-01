REBOL [
    Title: "Simple time recording program"
    Purpose: {Aid in recording time spent in quarter-hour units.}
]

START-LOC: %/C/
COUPON-FOLDER: %TimeCoupons/
COUPON-SUBFOLDER: none
COUPON-FILE-ID: none
COUPON-START: none
COUPON-END: none
COUPON-DURATION: none
COUPON-TIMESPENT: none 

CURRENT-LOC: "" 

QH-TABLE: [
    0  0.00
    1  0.00 
    2  0.00 
    3  0.00 
    4  0.00 
    5  0.25 
    6  0.25 
    7  0.25 
    8  0.25 
    9  0.25 
    10 0.25 
    11 0.25 
    12 0.25 
    13 0.25 
    14 0.25 
    15 0.25 
    16 0.25 
    17 0.25 
    18 0.25 
    19 0.25 
    20 0.50 
    21 0.50 
    22 0.50 
    23 0.50 
    24 0.50 
    25 0.50 
    26 0.50 
    27 0.50 
    28 0.50 
    29 0.50 
    30 0.50 
    31 0.50 
    32 0.50 
    33 0.50 
    34 0.50 
    35 0.75 
    36 0.75 
    37 0.75 
    38 0.75 
    39 0.75 
    40 0.75 
    41 0.75 
    42 0.75 
    43 0.75 
    44 0.75 
    45 0.75 
    46 0.75 
    47 0.75 
    48 0.75 
    49 0.75 
    50 0.75 
    51 0.75 
    52 0.75 
    53 1.00 
    54 1.00 
    55 1.00 
    56 1.00 
    57 1.00 
    58 1.00 
    59 1.00 
    60 1.00 
]

change-dir START-LOC 
if not exists? COUPON-FOLDER [
    make-dir COUPON-FOLDER
]
change-dir COUPON-FOLDER  
COUPON-SUBFOLDER: to-file now/date
if not exists? COUPON-SUBFOLDER [
    make-dir COUPON-SUBFOLDER
]
change-dir COUPON-SUBFOLDER 

WS-START-DATE: none
WS-END-DATE: none

DISSECT-TIME: func [
    TIMEVAL 
    /local TIMESTRING TIMEPARTS TIMEBLOCK 
] [
    TIMEBLOCK: copy []
    TIMEPARTS: copy []
    TIMESTRING: to-string TIMEVAL 
    TIMEPARTS: parse TIMESTRING ":"
    append TIMEBLOCK to-integer TIMEPARTS/1
    append TIMEBLOCK to-integer TIMEPARTS/2
    either TIMEPARTS/3 [
        append TIMEBLOCK to-integer TIMEPARTS/3
    ] [
        append TIMEBLOCK 0
    ]
    return TIMEBLOCK 
]

START-RECORDING: does [
    CURRENT-LOC: "START-RECORDING"
    WS-START-DATE: now
    COUPON-START: WS-START-DATE/time
    COUPON-END: none
    COUPON-DURATION: none
    COUPON-TIMESPENT: none
    TEMP-TIME: trim/with to-string WS-START-DATE/time ":"
    if equal? 3 length? TEMP-TIME [
        insert TEMP-TIME 0
        TEMP-TIME: head TEMP-TIME
    ]
    if equal? 5 length? TEMP-TIME [
        insert TEMP-TIME 0
        TEMP-TIME: head TEMP-TIME
    ]
    if equal? 4 length? TEMP-TIME [
        append TEMP-TIME "00"
    ]
    COUPON-FILE-ID: to-file rejoin [
        WS-START-DATE/date
        "-"
        TEMP-TIME
        ".txt"
    ]   
    WRITE-COUPON
    set-face MAIN-STATUS "Recording"
]

WRITE-COUPON: does [
    CURRENT-LOC: "WRITE-COUPON"
    write COUPON-FILE-ID rejoin [
        "START-TIME: " mold COUPON-START newline
        "END-TIME: " mold COUPON-END newline
        "DURATION: " mold COUPON-DURATION newline
        "TIMESPENT: " mold COUPON-TIMESPENT newline 
        "SUMMARY: " mold MAIN-SUMMARY/text newline 
        "ACTIVITY: " mold MAIN-WORK/text newline
    ]
    alert "Ok."
] 

STOP-RECORDING: does [
    CURRENT-LOC: "STOP-RECORDING"
    if not COUPON-FILE-ID [
        alert "Not recording at this time"
        exit
    ]
    WS-END-DATE: now
    COUPON-END: WS-END-DATE/time
    COUPON-DURATION: WS-END-DATE/time - WS-START-DATE/time 

    TEMP-HMS: DISSECT-TIME COUPON-DURATION
    COUPON-TIMESPENT: TEMP-HMS/1 + select QH-TABLE TEMP-HMS/2

    WRITE-COUPON
    COUPON-FILE-ID: none
    COUPON-START: none
    COUPON-END: none
    COUPON-DURATION:none
    COUPON-TIMESPENT: none
    WS-DATE-DATE: none
    WS-END-DATE: none
    MAIN-WORK/line-list: none
    MAIN-WORK/text: copy ""
    show MAIN-WORK 
    set-face MAIN-STATUS "Not recording"
    set-face MAIN-SUMMARY ""
]

UPDATE-ACTIVITY: does [
    CURRENT-LOC: "UPDATE-ACTIVITY"
    if not COUPON-FILE-ID [
        alert "Not recording at this time"
        exit
    ]
    WRITE-COUPON 
]

QUIT-BUTTON: does [
    CURRENT-LOC: "QUIT-BUTTON" 
    if COUPON-FILE-ID [
        WS-END-DATE: now
        COUPON-END: WS-END-DATE/time
        COUPON-DURATION: WS-END-DATE/time - WS-START-DATE/time 
        TEMP-HMS: DISSECT-TIME COUPON-DURATION
        COUPON-TIMESPENT: TEMP-HMS/1 + select QH-TABLE TEMP-HMS/2
        WRITE-COUPON
    ]
    quit        
]

MAIN-WINDOW: layout [
    across 
    text 500 "What are you doing now?"
    return
    label "Summary" 
    MAIN-SUMMARY: field 300
    return
    MAIN-WORK: area 500x200 wrap 
    return
    MAIN-STATUS: text 500 "Not recording" font [size: 24 shadow: none]
    return
    button "Start recording" [START-RECORDING]
    button "Stop recording" [STOP-RECORDING]
    button "Update activity" [UPDATE-ACTIVITY]
    button "Quit" [QUIT-BUTTON] 
]

view MAIN-WINDOW

