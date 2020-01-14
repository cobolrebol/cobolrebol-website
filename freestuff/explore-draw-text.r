REBOL [
    Title: "Line test"
]

;; [---------------------------------------------------------------------------]
;; [ Thanks to rebolforum.com for the inspiration for this demo.               ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a program to explore the "text" command of the "draw" dialect.    ]
;; [ The original documentation was a little sparse.                           ]
;; [ The program displays a box with text in it, and provides sliders          ]
;; [ to change the starting point of the text.                                 ]
;; [ It then displays the full "text" command to produce what you see          ]
;; [ in the box.                                                               ]
;; [---------------------------------------------------------------------------]

;; Put the various line-defining numbers here so we can probe them
;; and display them.

START-X: 0
START-Y: 0

;; To control the font (if you don't want the default attributes), 
;; you have to make a "font object"
;; using the same syntax as the font specifications for
;; text on any other style.

FONT-OBJECT: make face/font [
    size: 24
    style: [bold italic]
    shadow: none
]

;; The "draw" dialect that we will load into the "effect" block
;; of the box in the display window.    

drw: [ 
    'fill-pen red
    'box 100x100 300x300
    'font (FONT-OBJECT)
    'text as-pair START-X START-Y "This is a test"    
] 

;; This is the procedure that is done whenever any slider is moved.
;; It adjusts the coordinates of the line relative to the box upon
;; which it is drawn, rebuilds the "draw" effect, reloads the
;; "draw" effect into the definition of the box, and redisplays the
;; box. It also builds and displays the "line" command that would
;; draw the line. 

act: [
    START-X: to-integer 400 * s1/data
    START-Y: to-integer 400 * s2/data
    b/effect: reduce [
        'draw reduce drw
    ] 
    show b
    THE-NUMBERS/text: rejoin [
        "text "
        START-X
        "X"
        START-Y
        " "
        "This is a test"
    ]
    show THE-NUMBERS
] 

;; Main window.

view center-face layout [ 
    b: box 400x400 black 
    THE-NUMBERS: text 400 font [color: black shadow: none size: 14 style: 'bold]
    style sld slider 400x20 act 
    label "START-X (0-400)" font [color: black shadow: none] 
    s1: sld 0.0 
    label "START-Y (0-400)" font [color: black shadow: none]
    s2: sld 0.0 
    do act 
] 

