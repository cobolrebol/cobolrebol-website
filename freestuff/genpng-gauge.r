REBOL [
    title: "Generate a gauge with a needle"
] 

;; [---------------------------------------------------------------------------]
;; [ This function uses the REBOL layout function to generate a png file       ]
;; [ that is a "gauge" graphic to show the amount of free space on a           ]
;; [ server disk.  One calls the function with three items:                    ]
;; [     An integer giving the total capacity of the disk.                     ]
;; [     An integer giving the amount of space used.                           ]
;; [     A file name for the resulting graphic.                                ]
;; [ The gauge is a semicircular "fuel gauge" graphic on a black background.   ]
;; [ It is in a 200x100 box.  The center is at the middle of the bottom edge,  ]
;; [ at pixel location 100x100 (from the top left corner).                     ]
;; [ Naturally, this could be modified for other uses.                         ]
;; [ The code for the function is a bit plodding, since this was a learning    ]
;; [ exercise.                                                                 ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This function calculates the endpoint of an arrow on a gauge.             ]
;; [ Then it draws the arrow on a generated gauge in a layout, converts        ]
;; [ the image to a png file, and saves it.                                    ]
;; [ The gauge is a semicircle in the middle of a 200x100 box.                 ]
;; [ The pixel grid in such a box starts at 0x0 in the upper left corner.      ]
;; [ The semicircular gauge will be centered at 100x100 in the box,            ]
;; [ in other words, along the bottom edge, at the center of the box.          ]
;; [ The point we want to calculate is a point on the circumference of the     ]
;; [ circle, to which a "needle" on the gauge will point.                      ]
;; [ THe gauge indicates the amount of free space, with all the way to         ]
;; [ the left meaning "empty" or no free space, and all the way to the         ]
;; [ right meaning "full" or all free space.                                   ]
;; [ The data provided to this function is NOT the amount of space free,       ]
;; [ but the amount of space used.  Fortunately, by the nature of the          ]
;; [ sine and cosine functions we will be using, if we make a gauge            ]
;; [ "needle" showing the amount full, that needle will point all the way      ]
;; [ to the right when the amount full is zero, and all the way to the         ]
;; [ when the amount full is at its maximum.                                   ]
;; [ Because of that happy coincidence, to get the result we want we           ]
;; [ just have to make a needle using the input data we have showing the       ]
;; [ amount used, because the needle indicating the amount used will move      ]
;; [ from right to left as the amount used increases, which then will show     ]
;; [ the amount of free space decreasing.  As the amount used decreases,       ]
;; [ the needle will move from left to right indicating that the amount        ]
;; [ of free space is increaseing.  This is the result we want.                ]
;; [ Normally this function would be used as part of some automated job        ]
;; [ that obtained the total capacity of a disk and the total amount in use.   ]
;; [ If your automated procedure produces the amount free instead of the       ]
;; [ amount used, you could revise this function, or else you could            ]
;; [ subtract the amount free from the total capacity to get the amount        ]
;; [ used, and then use this function as it is.  Either way should be          ]
;; [ a simple change.                                                          ]
;; [---------------------------------------------------------------------------]

GEN-GAUGE-FREESPACE: func [

    ;; Input items:                                                    
    ;; Because of the various scripts that will feed this function,     
    ;; the input items are the total capacity and the amount used.      

    AMOUNT-FULL          ;; From caller, value of full gauge
    AMOUNT-USED          ;; From caller, amount in use
    GAUGE-FILENAME       ;; Name of png file we will create

    /local

    ;; Items we calculate:        

    PERCENT-FULL          ;; Percent that amount used is of amount available
    ANGLE-USED            ;; Angle for percent full (180 * percent)
    ENDPOINT-X            ;; Endpoint X relative to gauge center
    ENDPOINT-Y            ;; Endpoint Y relative to gauge center
    ARROW-END-X           ;; Endpoint X relative to top left corner
    ARROW-END-Y           ;; Endpoint Y relative to top left corner
] [
    ;; Procedure:    

    ;; -- What percent is full?
    PERCENT-FULL: AMOUNT-USED / AMOUNT-FULL 

    ;; -- Apply percentage to 180 degrees to find out where the needle
    ;; -- should point.  This angle will be all the way to the right for
    ;; -- zeros, and moving left as the amount used increases.
    ;; -- This is good, because what we REALLY want the needle to show
    ;; -- is the amount of free space, with zero being all the way to the
    ;; -- left and maximum free space being all the way to the right.
    ANGLE-USED: to-integer (PERCENT-FULL * 180)

    ;; -- Find out where the needle should hit the arc.
    ;; -- We should be able to use the sine and cosine functions because
    ;; -- we have an angle and a hypotenuse (100 pixels).  
    ;; -- This will work even for an obtuse angle that is pointing to the
    ;; -- negative side of the Y axis because of the periodic nature of
    ;; -- the trigonometric function. 
    ENDPOINT-X: to-integer 100 * cosine ANGLE-USED
    ENDPOINT-Y: to-integer 100 * sine ANGLE-USED

    ;; -- The above calculations are based on a coordinate system that is
    ;; -- centered at the center of the bottom edge of the box.
    ;; -- In REBOL, coordinates inside a face start at the top left corner.
    ;; -- Calculate the REBOL coordinates from the X-Y values we calculated
    ;; -- above.
    ;; -- The ENDPOINT-X value will be negative if the needle is pointing
    ;; -- to the left of the Y axis.  Thus the calculation below works
    ;; -- when the needle is pointing to the left OR to the right of the
    ;; -- Y axis.
    ARROW-END-Y: to-integer 100 - ENDPOINT-Y
    ARROW-END-X: to-integer 100 + ENDPOINT-X 

    ;; -- Now make a pair for the draw function.
    ARROW-END: as-pair ARROW-END-X ARROW-END-Y

    GAUGE-LAYOUT: layout [
        across
        GAUGE-PICTURE: box 200x100 black effect [
            draw [
            fill-pen red    arc 100x100 100x100 180 20  closed
            fill-pen yellow arc 100x100 100x100 200 20  closed
            fill-pen green  arc 100x100 100x100 220 140 closed
            arrow 1x0 
            line-width 3
            pen black
            line 100x100 ARROW-END
            ]
        ]
    ]
    save/png GAUGE-FILENAME to-image GAUGE-PICTURE
]

;; -- Uncomment to test
;GEN-GAUGE-FREESPACE 100 65 %GAUGE-65PERCENT.png
;GEN-GAUGE-FREESPACE 100 25 %GAUGE-25PERCENT.png
;alert "Done."

