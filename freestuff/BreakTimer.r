REBOL [
    Title: "Exercise break timer"
    Purpose: {Run a timer and sound an alarm when the timer is done,
    and then reset the timer and run again.}
]

;; [---------------------------------------------------------------------------]
;; [ This is an adaptation of a clock demo from the rebol.org web site.        ]
;; [ It runs a timer from a starting value down to zero, and then sounds       ]
;; [ an alarm.  It is used by SW to remind him to get out of his chair.        ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Configurable items.                                                       ]
;; [ -------------------                                                       ]
;; [ TIMER-INTERVAL:  How often do you want to sound an alarm.                 ]
;; [                  This is a number of minutes and seconds, and REBOL       ] 
;; [                  recognizes it as such from its format.                   ]
;; [ SOUND-FILE:      "wav" file played every TIMER-INTERVAL minutes.          ]
;; [---------------------------------------------------------------------------]

TIMER-INTERVAL: 00:30:00
SOUND-FILE: %bushorn.wav 

;; [---------------------------------------------------------------------------]
;; [ Setup.                                                                    ]
;; [ ------                                                                    ]
;; [ Set a working counter to the timer interval.  REBOL will do "time         ]
;; [ arithmetic" with no problem.                                              ]
;; [ Load the sound file in preparation for playing, if it exists.             ]
;; [---------------------------------------------------------------------------]

COUNTER: TIMER-INTERVAL
SOUND-ENABLED: false
either exists? SOUND-FILE [
    AUDIO-MSG: load SOUND-FILE
    SOUND-ENABLED: true
] [
    alert rejoin [
        "Sound file "
        to-string SOUND-FILE
        " does not exist; no audio alerts"
    ]
    SOUND-ENABLED: false
]

;; [---------------------------------------------------------------------------]
;; [ Procedures.                                                               ]
;; [ -----------                                                               ]
;; [ START-TIMING:  This is done when the "Reset" button is clicked,           ]
;; [     to set the counter back to the timing interval so we can start        ]
;; [     fresh on our countdown to zero.                                       ]
;; [ PLAY-SOUND-FILE:  This is done when the counter gets down to zero.        ]
;; [     It plays an alert sound.                                              ]
;; [---------------------------------------------------------------------------]

START-TIMING: does [
    COUNTER: TIMER-INTERVAL
    MAIN-COUNTER/text: to-string COUNTER
    show MAIN-COUNTER
]

PLAY-SOUND-FILE: does [
    if SOUND-ENABLED [
        wait 0
        SOUND-PORT: open sound://
        insert SOUND-PORT AUDIO-MSG
        wait SOUND-PORT
        close SOUND-PORT
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Main (and only) window.                                                   ]
;; [ -----------------------                                                   ]
;; [ Show the current time of day.  The timer interrupt of one second,         ]
;; [ combined with the "engage" function that is performed at the interrupt    ]
;; [ and redisplays the time, makes it look like the clock is running.         ]
;; [ Every time the "engage" function runs, every second, we reduce the        ]
;; [ counter, so it in effect counts seconds down to zero.                     ]
;; [ When we hit zero, sound an alarm and start over again.                    ]
;; [ Note:  It appears that "rate" and "feel" are not attributes of the        ]
;; [ window in general, but some item IN the window, in this case, the         ]
;; [ item of h1-style text that displays the time.                             ]
;; [ Note:  The stuff in parentheses is REBOL code that is run when the        ]
;; [ window is displayed.                                                      ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    origin 0                              
    MAIN-TIME: h1 100 red black (to string! now/time) 
        rate 1                            
        feel [
            engage: [                     
                MAIN-TIME/text: now/time          
                show MAIN-TIME                    
                COUNTER: COUNTER - 00:00:01   
                if COUNTER < 00:00:01 [      
                    COUNTER: TIMER-INTERVAL 
                    PLAY-SOUND-FILE         
                ]
                MAIN-COUNTER/text: to-string COUNTER 
                show MAIN-COUNTER                    
            ]
        ]
    MAIN-COUNTER: h1 100 (to-string COUNTER)             
    button "Reset" [START-TIMING]         
;;; button "Test" [PLAY-SOUND-FILE]
]

;; [---------------------------------------------------------------------------]
;; [ Begin. "First executable instruction," so to speak.                       ]
;; [---------------------------------------------------------------------------]

view MAIN-WINDOW

