REBOL [
    Title: "EDNA: Email Delayed Notification Assistant queuer"
]

;; [---------------------------------------------------------------------------]
;; [ This is a simple email program with a twist, based on a realization       ]
;; [ that not everyone uses email strictly as email.  For some people,         ]
;; [ email is relayed to their cell phones and they have their phones with     ]
;; [ them at all times, so email is a de-facto pager.  For others, email       ]
;; [ is used as a reminder system for others, that is, they want to remind     ]
;; [ or inform some other person about something, so they send out an email    ]
;; [ and expect it to hit the recipient's inbox and remain there as a          ]
;; [ reminder for later attention.  These two uses are incompatible.           ]
;; [ So, what this program does, is accept an email address and a body of      ]
;; [ text, and writes it to a formatted text file.  Then, a second program     ]
;; [ reads that text file and sends that email.  This second program can       ]
;; [ be set up as a scheduled task to run at some time of day that is more     ]
;; [ friendly for a recipient who uses email as a pager.                       ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Modify the following items for you own situation.                         ]
;; [---------------------------------------------------------------------------]

EMAIL-QUEUE: %EDNAEmailQueue/
RECIPIENT-LIST: [
    Person1@YourInstallation.com
    Person2@YourInstallation.com
    Person3@YourInstallation.com
    Person4@YourInstallation.com
]

;; [---------------------------------------------------------------------------]
;; [ End of configuration items.                                               ]
;; [---------------------------------------------------------------------------]

GLB-DATESTAMP: does [
    GLB-TEMP-DATE: now
    GLB-TEMP-YYYYMMDD: to-string rejoin [
        GLB-TEMP-DATE/year
        reverse copy/part reverse join 0 GLB-TEMP-DATE/month 2
        reverse copy/part reverse join 0 GLB-TEMP-DATE/day 2
    ]
    return GLB-TEMP-YYYYMMDD
]
GLB-TIMESTAMP: does [
    GLB-TEMP-TIME: to-string rejoin [
        reverse copy/part reverse join "0" trim/with to-string now/time ":" 6
    ]
    return GLB-TEMP-TIME
]

EMAIL-DATA: ""

EMAIL-FILENAME: ""

ADD-TO-QUEUE: does [
    if not MAIN-TO-ADDR/text [
        alert "Select a TO address"
        exit
    ]
    if = MAIN-SUBJECT/text "" [
        alert "Subject line required"
        exit
    ]
    EMAIL-DATA: copy ""
    append EMAIL-DATA rejoin [
        "MSG-TO: "
        mold MAIN-TO-ADDR/text
        newline
    ]
    append EMAIL-DATA rejoin [
        "MSG-SUBJECT: "
        mold MAIN-SUBJECT/text
        newline
    ]
    append EMAIL-DATA rejoin [
        "MSG-MESSAGE: "
        mold MAIN-MESSAGE/text
        newline
    ]
    EMAIL-FILENAME: to-file rejoin [
        "MSG-"
        GLB-DATESTAMP
        "-"
        GLB-TIMESTAMP
        ".txt"
    ]
    change-dir EMAIL-QUEUE
    write/lines EMAIL-FILENAME EMAIL-DATA
    alert "Message launched"
]

MAIN-WINDOW: layout [
    across
    banner "Email Delayed Notification Assistant"
    return
    label "To:"
    tab
    MAIN-TO-ADDR: drop-down 400 data RECIPIENT-LIST
    return
    label "Subject:"
    tab
    MAIN-SUBJECT: field 400
    return
    label "Message:"
    tab
    MAIN-MESSAGE: area 400x500 wrap 
    return
    button "Queue it" [ADD-TO-QUEUE]
    button "Quit" [quit]
]

view MAIN-WINDOW


