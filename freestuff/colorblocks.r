REBOL [
    Title: "Color code REBOL code based on brackets"
]

;; [---------------------------------------------------------------------------]
;; [ This is a REBOL debugging tool.                                           ]
;; [ Run the program, and when asked, open a REBOL code file.                  ]
;; [ The program will display the file in an html page, with a color change    ]
;; [ at each opening bracket.  At each closing bracket, the color will         ]
;; [ revert to the previous color.                                             ]
;; [ The use of this program is for locating missing brackets, which is a      ]
;; [ common REBOL coding error and can be hard to find in a large program.     ]
;; [---------------------------------------------------------------------------]

;; The colors can be changed to your liking. 
COLOR-LIST: [
    "#000000"
    "#FF0000"
    "#008500"
    "#0000FF"
    "#64C88B"
    "#E0C800"
    "#6BBDFF"
    "#FFBD00"
    "#FFbdFF"
    "#660099"
]

;; Goes up as we hit open brackets, and back down for closed.
COLOR-IN-USE: 1

;; Our data areas. 
TEXT-IN: copy ""
TEXT-IN-ID: none
TEXT-OUT: copy ""
TEXT-OUT-ID: %ColoredBlocks.html

;; Emit an opening font tag to set color of text to follow.
EMIT-FONT-TAG: does [
    append TEXT-OUT rejoin [
        {<font color="}
        pick COLOR-LIST COLOR-IN-USE
        {">}
    ]
]

;; Emit closing font tag so we can re-open a new font tag.
EMIT-FONT-END: does [
    append TEXT-OUT rejoin [
        {</font>}
    ]
]

;; Get the name of the file to scan; should be a REBOL script.
if not TEXT-IN-ID: request-file/only [
    alert "No file selected."
    quit
]

;; Set up the output html page.
append TEXT-OUT rejoin [
    "<html>"
    "<head><title>Colored blocks</title></head>"
    "<body>"
    "<pre>"
    newline
]
 
;; Bring in the data file as-is.
TEXT-IN: to-string read/binary TEXT-IN-ID

;; Set up the base level text color.
EMIT-FONT-TAG

;; Copy input to output, change colors as we find brackets.
foreach BYTE TEXT-IN [
    if equal? BYTE #"[" [
        EMIT-FONT-END
        COLOR-IN-USE: COLOR-IN-USE + 1
        EMIT-FONT-TAG
    ]
    if equal? BYTE #"]" [
        EMIT-FONT-END
        COLOR-IN-USE: COLOR-IN-USE - 1
        if equal? COLOR-IN-USE 0 [
            COLOR-IN-USE: 1
        ]
        EMIT-FONT-TAG
    ]
    append TEXT-OUT BYTE
]

;; Close the html page.
append TEXT-OUT rejoin [
    "</pre></body></html>" 
]

;; Put the output data on disk.
write/binary TEXT-OUT-ID TEXT-OUT

;; Pop up a browser to show the results.
browse TEXT-OUT-ID 

;; Sample lines to put into a text file for testing.
;; Remove comment character before using.

;BASE TEXT [
;    OPEN LEVEL 1 [
;        OPEN LEVEL 2 [
;            OPEN LEVEL 3 [
;                OPEN LEVEL 4 [
;                    OPEN LEVEL 5 [
;                         OPEN LEVEL 6 [
;                             level 6 text
;                         ]
;                         level 5 text
;                    ]     
;                    level 4 text
;                ] 
;                level 3 text
;            ]
;            level 2 text
;        ]
;        level 1 text
;    ]
;    base level text
;]

