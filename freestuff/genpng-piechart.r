REBOL [
    Title: Generate pie chart
]

;; [---------------------------------------------------------------------------]
;; [ This is a function to make a pie chart out of some input data.            ]
;; [ It saves the chart to a png file of a specified name.                     ]
;; [ The input data is a block of pairs of values.                             ]
;; [ The first item of a pair is a number.  This is some quantity that is      ]
;; [ to be shown as a slice of the pie chart.  One of these numbers,           ]
;; [ divided by the total of all the numbers, will form a fraction that is     ]
;; [ the size of the pie slice.  Multiplying that fraction by 360 degrees      ]
;; [ will give an angle for drawing the slice.                                 ]
;; [ The second item of a pair is a REBOL color word, which will be used       ]
;; [ to color the slice.                                                       ]
;; [ Also specified with the data block is a file name that will be the        ]
;; [ name of a file that will contain the image of the pie chart.              ]
;; [ It should be a ".png" file name.                                          ]
;; [ This function is only semi-general.                                       ]
;; [ You will want to change some items at the front that control the          ]
;; [ size of the image.                                                        ]
;; [---------------------------------------------------------------------------]

GEN-PIECHART: func [
    ;; Input data for the chart.
    ;; This is a block of repeating pairs of items.
    ;; The first item of a pair is the amount being turned into a slice.
    ;; We chose to supply amounts instead of percentages because it
    ;; seemed like that was the most likely data to be available.
    ;; The second item of a pair is the color for this slice (a 'word).
    ;; The second argument it the name of the file for saving the image.
    SLICE-DATA 
    PIECHART-FILENAME 
] [
    ;; Change these to change the size of the chart.
    BOX-SIZE:   400x400  ;; Size of box holding chart.
    PIE-CENTER: 200x200  ;; Center of pie in the box.
    PIE-RADIUS: 200x200  ;; Radius of pie chart (X and Y).
    START-ANGLE: 0       ;; Starting angle of first slice.
    
    ;; This block will hold the draw commands that we generate.
    DRAW-BLOCK: []
    
    ;; Working items.
    SLICE-START: 0       ;; Start angle of current slice.
    SLICE-LENGTH: 0      ;; Length of current slice.
    SLICE-TOTAL: 0       ;; Total of all amounts in the input data. 
    
    
    ;; Using the SLICE-DATA, generate the DRAW-BLOCK.
    ;; Remeber, the slice length is an angle, so for each slice
    ;; we add its length to its start to get the start of the
    ;; next slice.  We make two passes through the input.
    ;; The first pass adds up all the numbers so we can generate
    ;; the fractions for each slice.
    SLICE-TOTAL: 0
    foreach [AMOUNT COLOR] SLICE-DATA [
        SLICE-TOTAL: SLICE-TOTAL + AMOUNT
    ]
    SLICE-START: START-ANGLE
    foreach [AMOUNT COLOR] SLICE-DATA [
        SLICE-LENGTH: (AMOUNT / SLICE-TOTAL) * 360
        append DRAW-BLOCK reduce [
            'fill-pen 
            COLOR
            'arc
            PIE-CENTER
            PIE-RADIUS
            SLICE-START
            SLICE-LENGTH
            'closed
        ]
        SLICE-START: SLICE-START + SLICE-LENGTH
    ]
    
    PIECHART: layout [
        CHART-BOX: box BOX-SIZE white effect [draw DRAW-BLOCK]
    ]
    save/png PIECHART-FILENAME to-image CHART-BOX
]    

;; -- Uncomment to test
;GEN-PIECHART [25 'red 50 'green 10 'blue] %piechart.png 


