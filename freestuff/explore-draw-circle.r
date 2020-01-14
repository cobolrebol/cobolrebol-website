REBOL [
    Title: "Circle test"
]

;; [---------------------------------------------------------------------------]
;; [ Thanks to rebolforum.com for the inspiration for this demo.               ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a program to explore the "circle" command of the "draw" dialect.  ]
;; [ The original documentation was a little sparse.                           ]
;; [ The program displays a box with a circle in it, and provides sliders      ]
;; [ to change the center and radius of the circle.                            ]
;; [ It then displays the full "circle" command to produce the circle you see  ]
;; [ in the box.                                                               ]
;; [---------------------------------------------------------------------------]

;; Put the various box-defining numbers here so we can probe them
;; and display them.
;; Note that you can have two radii.  What does that mean, since a circle
;; has one.  If you specify one, you get a circle.  If you specify two you
;; get an elipse. The two radii are expressed as two numbers, not as a pair. 

CENTER-X: 0
CENTER-Y: 0
RADIUS-X: 0
RADIUS-Y: 0

;; The "draw" dialect that we will load into the "effect" block
;; of the box in the display window.    

drw: [ 
    'circle as-pair CENTER-X CENTER-Y RADIUS-X RADIUS-Y
] 

;; This is the procedure that is done whenever any slider is moved.
;; It adjusts the coordinates of the circle relative to the box upon
;; which it is drawn, rebuilds the "draw" effect, reloads the
;; "draw" effect into the definition of the box, and redisplays the
;; box. It also builds and displays the "circle" command that would
;; draw the circle. 

act: [
    CENTER-X: to-integer 400 * s1/data
    CENTER-Y: to-integer 400 * s2/data
    RADIUS-X: to-integer 400 * s3/data
    RADIUS-Y: to-integer 400 * s4/data
    b/effect: reduce [
        'draw reduce drw
    ] 
    show b
    THE-NUMBERS/text: rejoin [
        "circle "
        CENTER-X
        "X"
        CENTER-Y
        " "
        RADIUS-X
        " "
        RADIUS-Y 
    ]
    show THE-NUMBERS
] 

;; Main window.

view center-face layout [ 
    b: box 400x400 black 
    THE-NUMBERS: text 400 font [color: black shadow: none size: 14 style: 'bold]
    style sld slider 400x20 act 
    label "CENTER-X (0-400)" font [color: black shadow: none] 
    s1: sld 0.5
    label "CENTER-Y (0-400)" font [color: black shadow: none]
    s2: sld 0.5
    label "RADIUS-X (0-400)" font [color: black shadow: none]
    s3: sld 0.25
    label "RADIUS-Y (0-400)" font [color: black shadow: none]
    s4: sld 0.25
    do act 
] 

