REBOL [
    Title: "Mail And Report Transmission Assistant"
]

;; [---------------------------------------------------------------------------]
;; [ This is a little clerical assistant for sending a file as an email        ]
;; [ attachment toa person from a small list of possible recipients.           ]
;; [ This could be done with Outlook; this is just a slightly quicker way.     ]
;; [ Since the only advantage this program can offer over a regulare email     ]
;; [ client, the interface is basic.  The first thing you see is a file        ]
;; [ request box for the file, and then after you select the recipient in      ]
;; [ a drop-down, the next thing that happens is that the message is sent.     ]
;; [ This is deliberate; to reduce the number of points and clicks.            ]
;; [---------------------------------------------------------------------------]

;;  -- Put your own list of recipients here. 
MARTA-RECIPIENTS: [
    person1@company.com
    person2@company.com
    person3@company.com
    person4@company.com
]

;;  -- Put your own text here. 
MARTA-SUBJECT: "Report delivery from I-S"
MARTA-BODY: {
Here is the file or report you requested from Information Systems World Headquarters.

Thank you for your business.

MARTA

Mail And Report Transmission Assistant
}

MARTA-DEST: none
MARTA-FILE: none

MARTA-MAILER: func [MARTA-NAME] [
    MARTA-FILE: MARTA-NAME
    view MARTA-WINDOW  
]

MARTA-SEND: does [
    MARTA-DEST: MARTA-DROPDOWN/text
    if MARTA-DEST [
        send/subject/attach MARTA-DEST MARTA-BODY MARTA-SUBJECT MARTA-FILE 
    ]
    quit   
]

;;  -- For quick operation, choose the address and the message is sent.
;;  -- No SEND button, no confirmation box; just send and quit.
MARTA-WINDOW: layout [
    below
    label "Mail report to:"
    MARTA-DROPDOWN: drop-down 400 data MARTA-RECIPIENTS [MARTA-SEND]
    box 400x100
]

MARTA-SELECTED-FILE: request-file
if not MARTA-SELECTED-FILE [
    alert "No file selected"
    quit
]
MARTA-MAILER MARTA-SELECTED-FILE  

