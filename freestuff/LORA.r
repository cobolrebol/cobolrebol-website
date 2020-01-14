REBOL [
    Title: "LOgin Recorder Assistant"
]

;; [---------------------------------------------------------------------------]
;; [ This is a little helper program for web site credentials.                 ]
;; [ It speeds up the process of going to a web site and entering a user ID    ]
;; [ and password, at the expense of having the user ID and password stored    ]
;; [ somewhere besides in the head.                                            ]
;; [ Since this program was written for personal use, credentials are          ]
;; [ hard-coded.  One could put them into a text file and encrypt that file,   ]
;; [ but that was not needed in the original situation so it was not done.     ]
;; [ Credentials are in a block of blocks.  Each sub-block is credentials      ]
;; [ for one web site.  The items in the sub-block are strings:                ]
;; [     Description                                                           ]
;; [     The URL, but stored as a string                                       ]
;; [     The user ID                                                           ]
;; [     The password                                                          ]
;; [---------------------------------------------------------------------------]

;; -- Credentials could be hard-coded, or in a text file which you load.
CREDS: [
    ["Web site 1" "http://www.rebol.com" "USERID1" "PASSWORD1"]
    ["Web site 2" "http://www.rebol.com" "USERID2" "PASSWORD2"]
    ["Web site 3" "http://www.rebol.com" "USERID3" "PASSWORD3"]
    ["Web site 4" "http://www.rebol.com" "USERID4" "PASSWORD4"]
    ["Web site 5" "http://www.rebol.com" "USERID5" "PASSWORD5"]
    ["Web site 6" "http://www.rebol.com" "USERID6" "PASSWORD6"]
    ["Web site 7" "http://www.rebol.com" "USERID7" "PASSWORD7"]
    ["Web site 8" "http://www.rebol.com" "USERID8" "PASSWORD8"]
    ["Web site 9" "http://www.rebol.com" "USERID9" "PASSWORD9"]
    ["Web site 10" "http://www.rebol.com" "USERID10" "PASSWORD10"]
    ["Web site 11" "http://www.rebol.com" "USERID11" "PASSWORD11"]
    ["Web site 12" "http://www.rebol.com" "USERID12" "PASSWORD12"]
    ["Web site 13" "http://www.rebol.com" "USERID13" "PASSWORD13"]
    ["Web site 14" "http://www.rebol.com" "USERID14" "PASSWORD14"]
    ["Web site 15" "http://www.rebol.com" "USERID15" "PASSWORD15"]
    ["Web site 16" "http://www.rebol.com" "USERID16" "PASSWORD16"]
    ["Web site 17" "http://www.rebol.com" "USERID17" "PASSWORD17"]
    ["Web site 18" "http://www.rebol.com" "USERID18" "PASSWORD18"]
    ["Web site 19" "http://www.rebol.com" "USERID19" "PASSWORD19"]
    ["Web site 20" "http://www.rebol.com" "USERID20" "PASSWORD20"]
    ["Web site 21" "http://www.rebol.com" "USERID21" "PASSWORD21"]
    ["Web site 22" "http://www.rebol.com" "USERID22" "PASSWORD22"]
    ["Web site 23" "http://www.rebol.com" "USERID23" "PASSWORD23"]
    ["Web site 24" "http://www.rebol.com" "USERID24" "PASSWORD24"]
    ["Web site 25" "http://www.rebol.com" "USERID25" "PASSWORD25"]
]

START-ITEM: 0 

MAIN-WINDOW: layout [
    across
    banner "LOgin Recorder Assistant"
    return
    space 0
    text snow black 200 "Web site" center bold
    text snow black 200 "URL (click to go)" center bold
    text snow black 200 "User ID (click to copy)" center bold
    text snow black 200 "Password (click to copy)" center bold
    return
    LST: list 800x400 [
        origin 0 
        space 0x0
        across
        text 200 bold
        text 200 bold [browse to-url value]
        text 200 bold [write clipboard:// value]
        text 200 bold [write clipboard:// value] 
    ] supply [
        count: count + START-ITEM
        face/color: ivory
        face/text: none
        face/font/color: black
        if even? count [face/color: ivory - 50.50.50]
        if none? CRED-BLOCK: pick CREDS count [exit] 
        face/text: pick CRED-BLOCK index
    ]
    SLD: slider LST/size * 0x1 + 20x0 [ 
        C: to-integer value * length? CREDS
        if C <> START-ITEM [START-ITEM: C show LST]
    ]
    space 10x10 
    return
    button "Quit" [quit] 
    button "Debug" [halt] 
]

view MAIN-WINDOW

