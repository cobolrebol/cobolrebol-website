REBOL [
    Title: "Arc explorer"
]

;; [---------------------------------------------------------------------------]
;; [ Thanks to rebolforum.com where I got the program.                         ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a program to explore the "arc" command from the "draw" dialect.   ]
;; [ The original documentation was a little sparse.                           ]
;; [ The program displays a window with a closed arc in the middle,            ]
;; [ along with some sliders to modify the numbers that control the size and   ]
;; [ shape of the arc, so you can see what the numbers actually do.            ]
;; [                                                                           ]
;; [ In summary if you are not familiar, the "draw" dialect is a sub-dialect   ]
;; [ of the Video Interface Dialect (VID) of REBOL version 2.                  ]
;; [ It is used in the "effect" facet and allows you to draw lines and         ]
;; [ shapes on top of a style.  There are many keywords in this dialect,       ]
;; [ and this program explores just one, the "arc" command.                    ]
;; [ One other command, "line," is used in a supporting role.                  ]
;; [                                                                           ]
;; [ Here is what comes after the "arc" command.                               ]
;; [ 1.  A pair, to indicate the center point of the arc in relation to        ]
;; [     the face upon which it is drawn.  In this example, the arc is         ]
;; [     drawn in the middle of a 400x400 box, so the center is at 200x200.    ]
;; [ 2.  A pair indicating a number of pixels that marks a "boundary"          ]
;; [     of the arc in the X and Y directions.  This is a number               ]
;; [     of pixels on either side of the center.  This example has two         ]
;; [     vertical lines and two horizontal lines to show these boundaries.     ]
;; [ 3.  A number indicating the angle of the starting vector of the arc.      ]
;; [     This is like the hand of an analog clock that will "sweep out"        ]
;; [     the arc as it moves in a clockwise direction.  A value of zero        ]
;; [     indicates a direction straight to the right, like the X axis of a     ]
;; [     coordinate system.  The value can run from zero to 360.               ]
;; [ 4.  A number indicating the "length" of the arc, which means the number   ]
;; [     of degrees from the starting (left) vector clockwise to the           ]
;; [     ending (right) vector.                                                ]
;; [ This program is not written in the usual compact REBOL style.             ]
;; [ It is purposely written in a plodding manner so that it can serve         ]
;; [ as a training aid.                                                        ]
;; [---------------------------------------------------------------------------]

;; Put the various arc-defining numbers here so we can probe them
;; and display them.

ARC-CENTER: 200X200
MAX-X: 0
MAX-Y: 0 
START-ANGLE: 0
ARC-LENGTH: 0

;; Boundaries, just to help visualize.
TOP-Y-LEFT-X: 0
TOP-Y-LEFT-Y: 0
TOP-Y-RIGHT-X: 0
TOP-Y-RIGHT-Y: 0

BOTTOM-Y-LEFT-X: 0
BOTTOM-Y-LEFT-Y: 0
BOTTOM-Y-RIGHT-X: 0
BOTTOM-Y-RIGHT-Y: 0

LEFT-X-TOP-X: 0
LEFT-X-TOP-Y: 0
LEFT-X-BOTTOM-X: 0
LEFT-X-BOTTOM-Y: 0

RIGHT-X-TOP-X: 0
RIGHT-X-TOP-Y: 0
RIGHT-X-BOTTOM-X: 0
RIGHT-X-BOTTOM-Y: 0

;; The "draw" dialect that we will load into the "effect" block
;; of the box in the display window.
    
drw: [ 
    'arc ARC-CENTER
    as-pair MAX-X MAX-Y
    START-ANGLE
    ARC-LENGTH 
    'closed 
    'line as-pair TOP-Y-LEFT-X TOP-Y-LEFT-Y as-pair TOP-Y-RIGHT-X TOP-Y-RIGHT-Y
    'line as-pair BOTTOM-Y-LEFT-X BOTTOM-Y-LEFT-Y as-pair BOTTOM-Y-RIGHT-X BOTTOM-Y-RIGHT-Y
    'line as-pair LEFT-X-TOP-X LEFT-X-TOP-Y as-pair LEFT-X-BOTTOM-X LEFT-X-BOTTOM-Y 
    'line as-pair RIGHT-X-TOP-X RIGHT-X-TOP-Y as-pair RIGHT-X-BOTTOM-X RIGHT-X-BOTTOM-Y 
] 

;; This procedure is done whenever any slider is moved.
;; It adjusts the parameters of the arc based on the slider values,
;; regenerates the "draw" dialect for the box, and re-shows the box.
;; It also displays the new "arc" command that would produce the
;; displayed arc.

act: [
;;  -- Set the values of the arc.
    MAX-X: to-integer 200 * s1/data
    MAX-Y: to-integer 200 * s2/data
    START-ANGLE: to-integer 360 * s3/data
    ARC-LENGTH: to-integer 360 * s4/data

;;  -- Set values for four lines we will display to aid in understanding.
    TOP-Y-LEFT-X: 0
    TOP-Y-LEFT-Y: 200 - MAX-Y 
    TOP-Y-RIGHT-X: 400
    TOP-Y-RIGHT-Y: 200 - MAX-Y

    BOTTOM-Y-LEFT-X: 0
    BOTTOM-Y-LEFT-Y: 200 + MAX-Y 
    BOTTOM-Y-RIGHT-X: 400
    BOTTOM-Y-RIGHT-Y: 200 + MAX-Y

    LEFT-X-TOP-X: 200 - MAX-X
    LEFT-X-TOP-Y: 0
    LEFT-X-BOTTOM-X: 200 - MAX-X
    LEFT-X-BOTTOM-Y: 400

    RIGHT-X-TOP-X: 200 + MAX-X
    RIGHT-X-TOP-Y: 0
    RIGHT-X-BOTTOM-X: 200 + MAX-X
    RIGHT-X-BOTTOM-Y: 400

;;  -- Reload the "draw" command into the effect for the box
;;  -- and redisplay the box.
    b/effect: reduce [
        'draw reduce drw
    ] 
    show b

;;  -- Format and display the "arc" command that would produce
;;  -- the arc we have shown.
    THE-NUMBERS/text: rejoin [
        "arc "
        to-string ARC-CENTER
        " "
        MAX-X
        "X"
        MAX-Y
        " "
        START-ANGLE
        " "
        ARC-LENGTH 
    ]
    show THE-NUMBERS
] 

;;  -- Main window.
view center-face layout [ 
    b: box 400x400 black 
    THE-NUMBERS: text 400 font [color: black shadow: none size: 14 style: 'bold]
    style sld slider 400x20 act 
    label "MAX-X (0-200)" font [color: black shadow: none] 
    s1: sld 0.5 
    label "MAX-Y (0-200)" font [color: black shadow: none]
    s2: sld 0.5 
    label "START-ANGLE (0-360)" font [color: black shadow: none]
    s3: sld 
    label "ARC-LENGTH (0-360)" font [color: black shadow: none]
    s4: sld 0.5 
    do act 
] 

