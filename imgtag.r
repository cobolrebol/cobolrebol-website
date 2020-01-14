REBOL [
    Title: "Make an html img tag from an image file"
    Purpose: {Request an image file, read it, convert it to base 64,
    and put it into an img tag for embedding in a web page.}
]

;; [---------------------------------------------------------------------------]
;; [ It is possible to embed an image into an html document if the image       ]
;; [ can be incoded as base 64, whatever that means.  This function takes      ]
;; [ a file name and a text description, reads the file, converts it to        ]
;; [ base 64, and makes an html img tag.  It uses the passed text description  ]
;; [ as the "alt" attribute for the image.                                     ]
;; [ The function does no checking about the existence of the image file.      ]
;; [ That would more appropriately be done by the caller.                      ]
;; [---------------------------------------------------------------------------]

IMGTAG: func [
    FILENAME
    ALTDESC
] [
    return rejoin [ 
        {<img alt="} ALTDESC {" }
        {src="data:image/}
        at form suffix? FILENAME 2
        {;base64,}
        enbase/base read/binary FILENAME 64
        {">}
    ]
]

;;Uncomment to test, provide your own image called TestImage.png (or jpg). 
;write %imgtagtest.html rejoin [
;{<html>
;<head><title>IMGTAG test</title></head>
;<body>
;<h1>IMGTAG test</h1>
;}
;IMGTAG %TestImage.png "Elbow image"
;{</body>
;</html>
;}
;]
;browse %imgtagtest.html

