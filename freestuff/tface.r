TITLE
Scrolling text face

SUMMARY
This module provides a way to display a window of text that can
be scrolled.  It is useful for a screen-based report.

DOCUMENTATION
Format a text string that you want to display.
It is the job of the caller to format this string in the desired
way.  This module just displays what it gets in a scrolling window.

Get the module into your program with:

do %/L/COB_REBOL_modules/tface.r

When the input string is ready, call the module thusly:

TFACE-SHOW-TEXT input-string

The window that will appear will have a "Close" button that
will "unview" the window.

SCRIPT
REBOL [
    Title: "TFACE: Scrolling text face"
]

;; [---------------------------------------------------------------------------]
;; [ This module was modified from a scroller demo that was modified from      ]
;; [ an example in the REBOL cookbook.                                         ]
;; [                                                                           ]
;; [ This module provides a function that accepts a big text string and        ]
;; [ displays it in a scrolling face.  It is like a "printing" module that     ]
;; [ "prints" to the screen in a way that can be scrolled.  The formatting     ]
;; [ of the text string is up to the caller.                                   ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a scroller demo from the REBOL cookbook, with annotations to      ]
;; [ describe some of the obscure points.                                      ]
;; [                                                                           ]
;; [The key understanding is that T1 it an interface object, and its text value] 
;; [can be envisioned as a rectangle of pixels, with the text "displayed" on   ]
;; [it.                                                                        ]
;; [                                                                           ]
;; [Only a part shows through the window. The para/scroll/y value shows the    ]
;; [starting point from which text is displayed. This value starts at zero when] 
;; [the text is displayed at the top, and "increases" in a negative direction  ]
;; [because the text area can be envisioned as a grid with the top left corner ]
;; [being 0x0--thus "down" the text would be in a negative y direction like    ]
;; [the coordinates in algebra. The display window also is a rectangle of      ]
;; [pixels, and displaying in it starts at 0x0.                                ]
;; [                                                                           ]
;; [The size/y value is the vertical size of the text window. The user-data    ] 
;; [value is the vertical size of the text. The (user-data minus size/y)       ]
;; [expression is evaluated first. The result of that calculation represents   ]
;; [a point in the text value somewhere back from the maximum value, that is,  ]
;; [back from the end. That point, back from the end, is back by a distance    ]
;; [equal to the size of the display window. In other words, it is the point   ]
;; [in the text value where, if the text is displayed from that point forward, ]
;; [you will hit the end of the text when you hit the end of the window. In    ]
;; [other words, it is the point where you start to display text when you are  ]
;; [displaying the last page.                                                  ] 
;; [                                                                           ]
;; [The para/scroll/y value is going to vary from zero (the top of the text)   ]
;; [to the result of the above calculation (the last page), as you operate     ]
;; [the scroller. That is why the (user-data minus size/y) result is           ]
;; [multiplied by the data value of the scroller (which is a fraction in       ]
;; [the range of zero to one). Somewhere in that range of zero through         ]
;; [(user-data minus size/y) is where we want to start displaying a window     ]
;; [of text.                                                                   ]
;; [                                                                           ]
;; [The reason for the max function is that it could happen that the text      ]
;; [is SMALLER than the window. In that case, (user-data minus size/y) will    ]
;; [be negative (and will be negated later giving a positive value), and we    ]
;; [don't want that. Instead, we want to display from the top all the time,    ]
;; [and thus want para/scroll/y to be zero.                                    ]
;; [                                                                           ]
;; [We negate the para/scroll/y value because we are going "down" the          ] 
;; [text in a negative y direction.                                            ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ In the functions below, TXT and BAR are internal names to refer to        ]
;; [ the text area and the scroller that get passed to the functions.          ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is the viewing screen with a text area and a scroller to scroll      ]
;; [ through the text area.                                                    ]
;; [---------------------------------------------------------------------------]

TFACE-OUT: center-face layout [
        ;; "across" means that interface objects will be side-by-side,
        ;; and the "return" command will go down.
        across

        h3 "Program Output" 
        return
        
        ;; This makes the scroller tight up next to the text box.
        space 0

        ;; a text box and a scroller right next to it.
        T1: text 800x600 wrap green black font-name font-fixed 
        S1: scroller 16x600 [TFACE-SCROLL T1 S1]
        return

        ;; Go down 5 pixels
        pad 0x5 
        
        ;; Set inter-object spacing to 5 pixels.
        space 5

        ;; Make our operating and debugging buttons.
        button "Close" [TFACE-CLOSE T1 S1]
    ]

;; [---------------------------------------------------------------------------]
;; [ This function is called every time the scroller is moved.                 ]
;; [ In general, it modifies the properties that indicate where the text       ]
;; [ should be displayed from, and the redisplays the text.                    ]
;; [ But how does it do that?                                                  ]
;; [ The para/scroll/y attribute is a number that shows the position in        ]
;; [ in the text that is at the top of the display area.  It varies from       ]
;; [ zero, when the text is shown from the beginning, to some maximum          ]
;; [ value when the and of the text is in the window.                          ]
;; [ What is that maximum value?  It is size of the text minus the size        ]
;; [ of the the display area.  In other words, it is a point back from the     ]
;; [ end equal to the size of the box.  If the text is displayed from that     ]
;; [ point, when you run out of text you will run out of box.                  ]
;; [ The para/scroll/y value becomes a negative value, with an increasing      ]
;; [ absolute value, as we move down through the text.                         ]
;; [ The "data" attribute of the scroller varies from zero, when the           ]
;; [ scroller is at the top, to 1 when the scroller is at the bottom.          ]
;; [ This fractional value is applied to the maximum possible size of          ]
;; [ para/scroll/y to set it to a point from which text will be displayed.     ]
;; [ The "max" function is used to account for the situation where the         ]
;; [ text is smaller than the size of the box.  In that case, the              ]
;; [ calculation of (text size) minus (box size) will be negative, and         ]
;; [ negating that will be positive, which is a value we don't want to         ]
;; [ see for para/scroll/y because it is in the "wrong direction" so to        ]
;; [ speak.                                                                    ]
;; [---------------------------------------------------------------------------] 

TFACE-SCROLL: func [TXT BAR][
        TXT/para/scroll/y: negate BAR/data *
            (max 0 TXT/user-data - TXT/size/y)
        show TXT
    ]

;; [---------------------------------------------------------------------------]
;; [ This is the function used by the caller.  It loads the text area          ]
;; [ with the contents of a passed text wtring, so that we have something      ]
;; [ to scroll through.  Then is displays a window containing the text.        ]
;; [---------------------------------------------------------------------------]
TFACE-SHOW-TEXT: func [TFACE-TEXT-IN][
       
            ;; Load the text area of the screen with the text passed from 
            ;; the caller.                                        
            T1/text: TFACE-TEXT-IN  

            ;; Set para/scroll/y so we display from the top of the text.
            T1/para/scroll/y: 0

            ;; Set the initial scroller position to the top.
            S1/data: 0

            ;; This must be done whenever you load up a test area.
            T1/line-list: none

            ;; Store the "y" size of the text in the user-data attribute.
            T1/user-data: second size-text T1

            ;; Set the size of the thing you grab in the scroller.
            ;; It is the size of the text area divided by the size of the
            ;; text in that area.  In other words, if the size of the
            ;; text in the area gets bigger, the little grabby thing
            ;; has to get smaller. 
            S1/redrag T1/size/y / T1/user-data

            ;; Display the window.
            view TFACE-OUT
    ]

;; [---------------------------------------------------------------------------]
;; [ This function responds to the "Close"button.                              ]
;; [ Parameters are passed in case of some future need, but at this time       ]
;; [ all the procedure does is close the window.                               ]
;; [---------------------------------------------------------------------------]

TFACE-CLOSE: func [TXT BAR] [
    unview
]


