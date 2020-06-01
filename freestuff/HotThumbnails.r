REBOL [
    Title: "Hot thumbnails"
    Purpose: {Given a block of file names, generate a layout that
    contains thumbnails that will call a function when clicked.
    For generality, we will pass also the name of that function 
    that is called on click.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a very specialized function for a very specialized purpose.       ]
;; [ It takes a block of file names that are expected to be jpeg files,        ]
;; [ plus a REBOL function name of your choice, and generates the REBOL        ]
;; [ code for a layout of buttons, one button for each file name in the        ]
;; [ block.  Each button will have the picture on it, and the text of the      ]
;; [ button will be the name of the picture file.  Each button will have a     ]
;; [ code block to call the specified function and pass to that function       ]
;; [ the name of the picture file.                                             ]
;; [ The caller then is expected to use the "layout" function on the code      ]
;; [ from this function, and then to use that layout in some appropriate       ]
;; [ way.  The original use was to put the genearated layout into a pane       ]
;; [ of a larger window to show thumbnails of pictures.                        ]
;; [---------------------------------------------------------------------------] 

HOT-THUMBNAILS: func [
    FILEID-LIST 
    FUNCTION-TO-CALL
    /local LAYOUT-CODE 
] [
    LAYOUT-CODE: copy [] 
    foreach ID FILEID-LIST [
        append LAYOUT-CODE reduce [
            'button 100X100 ID (to-string ID) (reduce [FUNCTION-TO-CALL ID])
        ]
    ]
;;; print mold LAYOUT-CODE
    return LAYOUT-CODE
]

;;Uncomment to test
;SHOW-PICTURE: does [
;    print "called"
;]
;view layout HOT-THUMBNAILS [
;    %picture-1.jpg
;    %picture-2.jpg
;] 'SHOW-PICTURE

