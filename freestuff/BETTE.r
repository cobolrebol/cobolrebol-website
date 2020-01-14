REBOL [
    Title: "Billable Electronic Time Tag Entry"
]

;;                       W O R K    T I M E R
;;                       ====================

;; [---------------------------------------------------------------------------]
;; [ This is a demo of a program for timing one's work.                        ]
;; [ The plan is that there is a timer one starts when one starts work.        ]
;; [ One can start and stop the timer.  One also can enter some text to        ]
;; [ indicate the activity being timed.                                        ]
;; [                                                                           ]
;; [ How do we handle the scenario where a person might work on several        ]
;; [ projects concurrently.  For example one might send off a support call     ]
;; [ and then do some programming while waiting for a  response.               ]
;; [ Then when the response comes he would put time on that.                   ]
;; [ We will handle that by having several mutually-exclusive timers.          ]
;; [ How many?  Well, realistically, if a person is "working" on half a        ]
;; [ dozen things at the "same" time, is he really, or is he just              ]
;; [ thrashing around ineffectively?  We will allow a fixed number of          ]
;; [ timers and make the person work with those.                               ]
;; [                                                                           ]
;; [ What happens when work is interrupted?                                    ]
;; [ Is an interrupt any different than moving from one concurrent             ]
;; [ project to another? It could be, if someone is interrupted by a           ]
;; [ co-worker asking a question.  It seems like a lot of work to start        ]
;; [ a new concurrent "project" just handle an interrupt of this nature.       ]
;; [                                                                           ]
;; [ So the plan is that when one experiences an interrupt, one starts an      ]
;; [ interrupt timer.  There is only one such timer; we will not allow         ]
;; [ interrupts to be interrupted.                                             ]
;; [ When one is interrupted, he starts the interrupt timer.                   ]
;; [ Starting the interrupt timer stops the main timers.                       ]
;; [ One works on the interrupt task, and then stops or finishes, then         ]
;; [ stops the interrupt timer.  At this point, one then manually starts       ]
;; [ the main timer and continues working on the main task.                    ]
;; [                                                                           ]
;; [ What if an interrupt task is interrupted?                                 ]
;; [ We could have more two interrupt timers and go between the two.           ]
;; [ We could stack the interrupts.  But that gets hard for a person to        ] 
;; [ manage in his head, regardless of how much computational help one has.    ]
;; [ Therefore, we will use this program to guide a certain way of working.    ]
;; [ One will start one project and work on it for a time, and then quit.      ]
;; [ If one is interrupted, one will handle that interrupt and then go back    ]
;; [ to the main task.  If one is interrupted doing an interrupt task,         ]
;; [ one will close out that interrupt task.                                   ]
;; [                                                                           ]
;; [ There will be a button for each timer to allow a person to record what    ]
;; [ one was doing, making a note in a file somewhere with the text            ]
;; [ entered for the timer plus the value of the timer.                        ]
;; [                                                                           ]
;; [ There will be a button to start an empty file to record the tasks         ]
;; [ for the current day.  When one finishes one of the timed tasks, or        ]
;; [ an interrupt task, a line will be written to that file.                   ]
;; [ The file will be in a csv format.  At the end of the day, the operator    ]
;; [ will be able to push another button to have that file mailed to a         ]
;; [ supervisor who then can open the file with a spreadsheet program and      ]
;; [ have a daily time report in spreadsheet format.                           ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Some data items put here for organizational purposes.                     ]
;; [---------------------------------------------------------------------------]

REPORT-FILENAME: %BETTEreport.csv
REPORT-EMAIL-FILE: %BETTEemail.csv
REPORT-EMAIL: [
    yoursupervisor@yourinstallation.com
]
REPORT-TASK-TYPE: ""
REPORT-TASK-TIME: 00:00:00
REPORT-TASK-DESC: ""

TASK1-TIMER: 00:00:00
TASK2-TIMER: 00:00:00
INTERRUPT-TIMER: 00:00:00
TOTAL-TIMER: 00:00:00

TASK1-DESC: ""
TASK2-DESC: ""
INTERRUPT-DESC: ""

TASK1-ON: false
TASK2-ON: false
INTERRUPT-ON: false
TOTAL-ON: false

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to make an empty report file.                       ]
;; [ The file is going to be a csv file with a line of column headings.        ]
;; [ A file of this format should read right into a spreadsheet program.       ]
;; [---------------------------------------------------------------------------]

INITIALIZE-REPORT-FILE: does [
    write REPORT-FILENAME rejoin [
        "TaskDate, TaskType, TaskTime, TaskDescription"
        newline
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure writes a task entry to the report file.                    ]
;; [ Since a task entry can come from one of several timers, we will make      ]
;; [ this procedure easy by having the items we want to record loaded into     ]
;; [ special data items for this operation.  Then this procedure is simple.    ]
;; [ The job of deciding where the data is coming from is pushed off           ]
;; [ elsewhere.                                                                ]
;; [---------------------------------------------------------------------------]

RECORD-REPORT-ENTRY: does [
    write/append REPORT-FILENAME rejoin [
        {"}
        to-string now/date
        {",}
        REPORT-TASK-TYPE
        {,}
        REPORT-TASK-TIME
        {,"}
        REPORT-TASK-DESC
        {"}
        newline
    ]
    REPORT-TASK-TYPE: ""
    REPORT-TASK-TIME: 00:00:00
    REPORT-TASK-DESC: ""
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is run just before we close out the day.                   ]
;; [ It adds a total line to the report file.                                  ]
;; [---------------------------------------------------------------------------]

RECORD-REPORT-TOTAL: does [
    write/append REPORT-FILENAME rejoin [
        {"}
        to-string now/date
        {",}
        "Total"  
        {,}
        TOTAL-TIMER     
        {,"}
        "Total time recorded for the day" 
        {"}
        newline
    ]
    REPORT-TASK-TYPE: ""
    REPORT-TASK-TIME: 00:00:00
    REPORT-TASK-DESC: ""
]
 

;; [---------------------------------------------------------------------------]
;; [ This set of steps, of resetting everything, is done from a couple         ]
;; [ places, so we will put them into this procedure to make things tidy.      ]
;; [---------------------------------------------------------------------------]

RESET-EVERYTHING: does [
    INITIALIZE-REPORT-FILE
    TASK1-ON: false
    TASK2-ON: false
    INTERRUPT-ON: false
    TOTAL-ON: false 
    TASK1-TIMER: 00:00:00
    TASK2-TIMER: 00:00:00
    INTERRUPT-TIMER: 00:00:00
    TOTAL-TIMER: 00:00:00
    MAIN-TASK1-TIMER/text: TASK1-TIMER
    MAIN-TASK2-TIMER/text: TASK2-TIMER
    MAIN-INTERRUPT-TIMER/text: INTERRUPT-TIMER
    MAIN-TOTAL-TIMER/text: TOTAL-TIMER
    show MAIN-TASK1-TIMER
    show MAIN-TASK2-TIMER
    show MAIN-INTERRUPT-TIMER
    show MAIN-TOTAL-TIMER
]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "New Day" button.                           ]
;; [ At the beginning of each day we want a blank report file, so this         ]
;; [ procedure removes an old file if it exists and starts a new one with      ]
;; [ just a line of headers.                                                   ]
;; [ We also do this procedure if there is no report file on disk              ]
;; [ when we start up.                                                         ]
;; [---------------------------------------------------------------------------]

NEW-DAY: does [
    RESET-EVERYTHING
    alert "Ready for new day."
]
;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Close day" button.                         ]
;; [ At the end of the day we want to make sure all timers are stopped         ]
;; [ and all tasks recorded, and then we want to send the report file to       ]
;; [ a supervisor.  We also then will clear out the file in case this is       ]
;; [ not the end of the day and we are continuing to work.                     ]
;; [ A design question to be answered is, if a person tries to close a day     ]
;; [ with a timer still running, should we 1) assume he knows what he is       ]
;; [ doing and let him, 2) ask if he knows what he is doing, or 3) check       ]
;; [ everything and record task that he still seems to be doing?               ]
;; [ You will have to look at the code below to see our current thinking       ]
;; [ on this matter because it could change over time.                         ]
;; [---------------------------------------------------------------------------]

CLOSE-DAY: does [
    RECORD-REPORT-TOTAL
    write/lines REPORT-EMAIL-FILE read/lines REPORT-FILENAME 
;;  -- Un-comment if your operation allows sending of email. 
;   send/attach REPORT-EMAIL 
;       "Time report is in attached file"
;       REPORT-EMAIL-FILE
    RESET-EVERYTHING 
    alert "Time report will be sent tonight." 
]

;; [---------------------------------------------------------------------------]
;; [ These buttons respond to the "Start" buttons for the tasks.               ]
;; [ Basically, we just want to set indicators so that the appropriate         ]
;; [ timer will run and the others will not.                                   ]
;; [---------------------------------------------------------------------------]

TASK1-START: does [
    TASK1-ON: true
    TASK2-ON: false
    INTERRUPT-ON: false
    TOTAL-ON: true 
]

TASK2-START: does [
    TASK1-ON: false
    TASK2-ON: true 
    INTERRUPT-ON: false
    TOTAL-ON: true
]

INTERRUPT-START: does [
    TASK1-ON: false
    TASK2-ON: false
    INTERRUPT-ON: true 
    TOTAL-ON: true 
]
;; [---------------------------------------------------------------------------]
;; [ These buttons respond to the "Pause" buttons for the tasks.               ]
;; [ Basically, we just want to make the timers quit by setting the            ]
;; [ appropriate control flags.                                                ]
;; [ Don't turn off the total timer unless we are clicking the pause button    ]
;; [ for a running timer.                                                      ]
;; [---------------------------------------------------------------------------]

TASK1-PAUSE: does [
    if TASK1-ON [
        TOTAL-ON: false
    ]
    TASK1-ON: false
]

TASK2-PAUSE: does [
    if TASK2-ON [
        TOTAL-ON: false
    ]
    TASK2-ON: false
]

INTERRUPT-PAUSE: does [
    if INTERRUPT-ON [
        TOTAL-ON: false 
    ]
    INTERRUPT-ON: false
]

;; [---------------------------------------------------------------------------]
;; [ These buttons respond to the "Close" buttons for the tasks.               ]
;; [ The "Close" button is used when one is done recording time for a task.    ]
;; [ This does not mean a task is done, just that you are done working on      ]
;; [ it for now.                                                               ]
;; [ What we want to do is to make an entry in the report file and reset       ]
;; [ the timer.  Because of that, we have to make sure that the task           ]
;; [ description is filled in.                                                 ]
;; [ A design decision to be answered is, do we let the operator close a       ]
;; [ task for which the timer is not running, or does that not make sense?     ]
;; [ The current plan (unless the code below says differently) is to let       ]
;; [ the operator do what he wants.                                            ]
;; [ But remember, if we close a task that is not running, we don't want to    ]
;; [ turn off the total timer, because another task might be running.          ]
;; [---------------------------------------------------------------------------] 

TASK1-CLOSE: does [
    REPORT-TASK-DESC: MAIN-TASK1-DESC/text
    if (REPORT-TASK-DESC = "") [
        alert "You must have a task description to record."
        exit
    ]
    REPORT-TASK-TIME: MAIN-TASK1-TIMER/text
    if ((REPORT-TASK-TIME = "") or (REPORT-TASK-TIME = "0:00")) [
        alert "You must be recording a time for this task."
        exit
    ]
    REPORT-TASK-TYPE: "Task"
    RECORD-REPORT-ENTRY
    TASK1-TIMER: 00:00:00
    TASK1-DESC: copy ""
    if TASK1-ON [
        TOTAL-ON: false
    ]
    TASK1-ON: false
    MAIN-TASK1-TIMER/text: TASK1-TIMER
    MAIN-TASK1-DESC/text: TASK1-DESC
    show MAIN-TASK1-TIMER
    show MAIN-TASK1-DESC
]

TASK2-CLOSE: does [
    REPORT-TASK-DESC: MAIN-TASK2-DESC/text
    if (REPORT-TASK-DESC = "") [
        alert "You must have a task description to record."
        exit
    ]
    REPORT-TASK-TIME: MAIN-TASK2-TIMER/text
    if ((REPORT-TASK-TIME = "") or (REPORT-TASK-TIME = "0:00")) [
        alert "You must be recording a time for this task."
        exit
    ]
    REPORT-TASK-TYPE: "Task"
    RECORD-REPORT-ENTRY
    TASK2-TIMER: 00:00:00
    TASK2-DESC: copy ""
    if TASK2-ON [
        TOTAL-ON: false 
    ]
    TASK2-ON: false
    MAIN-TASK2-TIMER/text: TASK2-TIMER
    MAIN-TASK2-DESC/text: TASK2-DESC
    show MAIN-TASK2-TIMER
    show MAIN-TASK2-DESC
]

INTERRUPT-CLOSE: does [
    REPORT-TASK-DESC: MAIN-INTERRUPT-DESC/text
    if (REPORT-TASK-DESC = "") [
        alert "You must have a task description to record."
        exit
    ]
    REPORT-TASK-TIME: MAIN-INTERRUPT-TIMER/text
    if ((REPORT-TASK-TIME = "") or (REPORT-TASK-TIME = "0:00")) [
        alert "You must be recording a time for this task."
        exit
    ]
    REPORT-TASK-TYPE: "Interruption"
    RECORD-REPORT-ENTRY
    INTERRUPT-TIMER: 00:00:00
    INTERRUPT-DESC: copy ""
    if INTERRUPT-ON [
        TOTAL-ON: false 
    ]
    INTERRUPT-ON: false
    MAIN-INTERRUPT-TIMER/text: INTERRUPT-TIMER
    MAIN-INTERRUPT-DESC/text: INTERRUPT-DESC
    show MAIN-INTERRUPT-TIMER
    show MAIN-INTERRUPT-DESC
]

MAIN-WINDOW: layout [
    tabs 20
    across
    banner "Billable Electronic Time Tag Entry" font [size: 48 shadow: none]
    return
;;  -- Work timer area
    MAIN-TIME: h1 100 red black (to string! now/time) 
        rate 1                            
        feel [
            engage: [                     
                MAIN-TIME/text: now/time          
                show MAIN-TIME  
                if TASK1-ON [
                    TASK1-TIMER: TASK1-TIMER + 00:00:01
                    MAIN-TASK1-TIMER/text: TASK1-TIMER
                    show MAIN-TASK1-TIMER
                ]                  
                if TASK2-ON [
                    TASK2-TIMER: TASK2-TIMER + 00:00:01
                    MAIN-TASK2-TIMER/text: TASK2-TIMER
                    show MAIN-TASK2-TIMER
                ]                  
                if INTERRUPT-ON [
                    INTERRUPT-TIMER: INTERRUPT-TIMER + 00:00:01
                    MAIN-INTERRUPT-TIMER/text: INTERRUPT-TIMER
                    show MAIN-INTERRUPT-TIMER
                ]   
                if TOTAL-ON [
                    TOTAL-TIMER: TOTAL-TIMER + 00:00:01
                    MAIN-TOTAL-TIMER/text: TOTAL-TIMER
                    show MAIN-TOTAL-TIMER
                ]                
            ]
        ]

    tab
    tab
    tab
    tab
    label "Task 1:"
    MAIN-TASK1-TIMER: h1 100 red black (to-string TASK1-TIMER)
    tab
    tab
    tab
    label "Task 2:"
    MAIN-TASK2-TIMER: h1 100 red black (to-string TASK2-TIMER)
    tab
    tab
    tab
    label "Interrupt:"
    MAIN-INTERRUPT-TIMER: h1 100 red black (to-string INTERRUPT-TIMER)
    tab
    tab
    tab
    label "Billable:" 
    MAIN-TOTAL-TIMER: h1 100 red black (to-string TOTAL-TIMER) 
    return
    tab
    tab
    tab
    tab
    tab
    tab
    tab
    tab
    tab
    MAIN-TASK1-DESC: area 200x40 wrap 
    tab
    MAIN-TASK2-DESC: area 200x40 wrap
    tab
    MAIN-INTERRUPT-DESC: area 200x40 wrap 
    return

    button 70 "New day" [NEW-DAY] 
    button 70 "Close day" [CLOSE-DAY]
    tab
    tab
    button 60 "Start" [TASK1-START]
    button 60 "Pause" [TASK1-PAUSE] 
    button 60 "Close" [TASK1-CLOSE]
    tab
    button 60 "Start" [TASK2-START] 
    button 60 "Pause" [TASK2-PAUSE] 
    button 60 "Close" [TASK2-CLOSE]
    tab
    button 60 "Start" [INTERRUPT-START] 
    button 60 "Pause" [INTERRUPT-PAUSE] 
    button 60 "Close" [INTERRUPT-CLOSE] 
    return
    tab
    return
    tab
    return
    tab
    tab
    return
    box 1000x12 red 
]

;; [---------------------------------------------------------------------------]
;; [ Begin.                                                                    ]
;; [---------------------------------------------------------------------------]

;;  -- Clear out a report file for the day.
if not exists? REPORT-FILENAME [
    INITIALIZE-REPORT-FILE 
]

view MAIN-WINDOW

