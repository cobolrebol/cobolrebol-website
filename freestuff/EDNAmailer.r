REBOL [
    Title: "EDNA: Email Delayed Notification Assistant mailer" 
]

;; [---------------------------------------------------------------------------]
;; [ This is the second program of the pair that make up the EDNA assistant.   ]
;; [ It locates files created with the ENDA queuer and sends them by email.    ]
;; [ Each message is in a text file that is in a REBOL-readable format,        ]
;; [ in a single directory.  This program will locate all files in that        ]
;; [ directory, load each one in turn, and create an email message from the    ]
;; [ data in the file.                                                         ]
;; [ The plan for this program is that it would be set up as a scheduled task  ]
;; [ on a server, or on some computer that runs all the time so that it can    ]
;; [ send its messages at any desired time.  At its original installation,     ]
;; [ a server was used because servers were on all the time and also           ]
;; [ servers were the only computers that allowed email sending, for           ]
;; [ security reasons.  Also, if you set this up to run on a server,           ]
;; [ you might have to run it though a DOS batch file with the security        ]
;; [ switch set so that the program does not hang on operator input.           ]
;; [ That would be done with your own modification of this:                    ]
;; [ "C:\Program Files (x86)\rebol\view\rebol.exe" -s                          ]
;; [     --script C:\scripts\EDNAmailer.r                                      ]
;; [---------------------------------------------------------------------------]

EMAIL-QUEUE: %EDNAEmailQueue/

TEXT-FILE?: func ["Returns true if file is a text file" file] [
    find [%.txt %.TXT] find/last file "."
]

;; -- Get all names in the email queue folder 
FILE-LIST: read rejoin [EMAIL-QUEUE "."]

;; -- Filter out non-text files so we don't crash on bad data 
while [not tail? FILE-LIST] [
    either TEXT-FILE? first FILE-LIST [
        FILE-LIST: next FILE-LIST
    ][
        remove FILE-LIST
    ]
]
FILE-LIST: head FILE-LIST

;; -- Make and email from each text file 
foreach FILE-NAME FILE-LIST [
    do load rejoin [EMAIL-QUEUE FILE-NAME]
    send/subject MSG-TO MSG-MESSAGE MSG-SUBJECT 
    delete rejoin [EMAIL-QUEUE FILE-NAME]
]


