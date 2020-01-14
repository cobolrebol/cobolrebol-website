REBOL [
    Title: "Line test"
]

;; [---------------------------------------------------------------------------]
;; [ Thanks to rebolforum.com for the inspiration for this demo.               ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a program to explore the "line" command of the "draw" dialect.    ]
;; [ The original documentation was a little sparse.                           ]
;; [ The program displays a box with a line in it, and provides sliders        ]
;; [ to change the starting and ending points of the line.                     ]
;; [ It then displays the full "line" command to produce the line you see      ]
;; [ in the box.                                                               ]
;; [---------------------------------------------------------------------------]

;; Put the various line-defining numbers here so we can probe them
;; and display them.

START-X: 0
START-Y: 0
END-X: 0
END-Y: 0

;; The "draw" dialect that we will load into the "effect" block
;; of the box in the display window.    

drw: [ 
    'line as-pair START-X START-Y as-pair END-X END-Y
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
    END-X: to-integer 400 * s3/data
    END-Y: to-integer 400 * s4/data
    b/effect: reduce [
        'draw reduce drw
    ] 
    show b
    THE-NUMBERS/text: rejoin [
        "line "
        START-X
        "X"
        START-Y
        " "
        END-X
        "x"
        END-Y 
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
    s2: sld 0.5 
    label "END-X (0-400)" font [color: black shadow: none]
    s3: sld 1.0
    label "END-Y (0-400)" font [color: black shadow: none]
    s4: sld 0.5 
    do act 
] 

