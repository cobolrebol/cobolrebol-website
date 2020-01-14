REBOL [
    Title: "Scrolling text functions, vertical"
    Purpose: {Encapsulate the procedure to scroll a text box so that
    one does not have to re-learn how to do it every time.}
]

;; [---------------------------------------------------------------------------]
;; [ This module encapsulates REBOL Cookbook article 29 into some functions    ]
;; [ that should work for any text face with a vertical scroller, no matter    ]
;; [ how they are placed on a window.  The reason this should work is that     ]
;; [ we can pass to a function the text and the scroller, and the function     ]
;; [ can update and redisplay the text and the scroller.                       ]
;; [ One scroller to rule them all, as it were.                                ]
;; [---------------------------------------------------------------------------]

;;  -- Scroll the text in response to the scroller.
SCRLTXTV-SCROLL: func [TXT BAR] [
    TXT/para/scroll/y: negate BAR/data *
        (max 0 TXT/user-data - TXT/size/y)
    show TXT
]

;;  -- Load the text face with text passed to us in TDATA.
SCRLTXTV-LOAD: func [TXT BAR TDATA] [
    TXT/text: TDATA
    TXT/para/scroll/y: 0
    TXT/line-list: none
    TXT/user-data: second size-text TXT
    BAR/data: 0
    BAR/redrag TXT/size/y / TXT/user-data
;;  show [TXT BAR] ;; Caller must do this, for better generality.
]

;; Uncomment to test
;
;SOMETEXT: read %scrltxtv.r
;NEWTEXT: reverse copy SOMETEXT
;MAIN-WINDOW: layout [
;    across
;    T1: text 400x600
;    S1: scroller 20x600 [SCRLTXTV-SCROLL T1 S1]
;    return
;    button "refresh" [SCRLTXTV-LOAD T1 S1 NEWTEXT show [T1 S1]]
;    button "revert" [SCRLTXTV-LOAD T1 S1 SOMETEXT show [T1 S1]]
;]
;SCRLTXTV-LOAD T1 S1 SOMETEXT
;view MAIN-WINDOW
 
