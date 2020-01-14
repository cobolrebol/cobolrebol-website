REBOL [
    Title: "Make html figures page"
    Purpose: {Select images one at a time, transform to base 64
    encoding, embed in a web page with a caption.  The purpose of
    this is to make an html page of figures that can be referred 
    to from other documents that aren't friendly to images.}
]
;; [---------------------------------------------------------------------------]
;; [ This program is a documentation aid.                                      ]
;; [ It is for a situation where documentation must be written in text files   ]
;; [ but we would like the ability to refer to graphic images.                 ]
;; [ This program requests the name of an image file and transforms that       ]
;; [ file into base 64 encoding.  Then it adds that base 64 image to an        ]
;; [ html file as an embedded image.  This process is repeated until the       ]
;; [ final result is an html page of images with captions that is a companion  ]
;; [ to a text document that refers to those images.                           ]
;; [---------------------------------------------------------------------------]

CURRENT-FILE: none
CURRENT-FILE-BINARY: none

HTML-HEADING: "Figures"
HTML-TITLE: "Figures"
HTML-BASE64-IMAGE: none
HTML-CAPTION: ""
HTML-SUFFIX: ""
HTML-STARTED: false
HTML-PAGE: ""
HTML-FILEID: none

HTML-TEMPLATE-HEAD: {
<html>
<head>
<title> <%HTML-TITLE%> </title>
</head>
<body>
<h1> <%HTML-HEADING%> </h1>
}

HTML-TEMPLATE-FOOT: {
</body>
</html>
}

HTML-TEMPLATE-FIGURE: {
<img style="border:5px solid black" alt="<%HTML-CAPTION%>"
src="data:image/<%HTML-SUFFIX%>;base64,<%HTML-BASE64-IMAGE%>">
<br>
<font size="6"><%HTML-CAPTION%></font>
<br><br>
}

QUIT-BUTTON: does [
    quit
]

CHOOSE-FILE-BUTTON: does [
    if not CURRENT-FILE: request-file/only [
        alert "No file requested."
        exit
    ]
    HTML-SUFFIX: suffix? CURRENT-FILE
    replace HTML-SUFFIX "." ""
    system/options/binary-base: 64
    CURRENT-FILE-BINARY: read/binary CURRENT-FILE
    save clipboard:// CURRENT-FILE-BINARY
    HTML-BASE64-IMAGE: read clipboard://
    replace HTML-BASE64-IMAGE "64#{" ""
    replace HTML-BASE64-IMAGE "}" ""
    MAIN-IMAGE/image: load CURRENT-FILE
    show MAIN-IMAGE
]

EMBED-BUTTON: does [
    if not CURRENT-FILE [
        alert "No image loaded."
        exit
    ]
    HTML-CAPTION: get-face MAIN-CAPTION
    if equal? "" HTML-CAPTION [
        alert "No caption specified"
        exit
    ]
    if not HTML-STARTED [
        HTML-HEADING: get-face MAIN-HEADING
        append HTML-PAGE build-markup HTML-TEMPLATE-HEAD
        HTML-STARTED: true
    ]
    append HTML-PAGE build-markup HTML-TEMPLATE-FIGURE
    alert "OK"
]

SAVE-HTML-BUTTON: does [
    if not HTML-FILEID: request-file/only/save [
        alert "No save file requested"
        exit
    ]
    append HTML-PAGE build-markup HTML-TEMPLATE-FOOT
    write HTML-FILEID HTML-PAGE
    alert "Saved"
]

CLEAR-HTML-BUTTON: does [
    HTML-PAGE: copy ""
    HTML-STARTED: false
    MAIN-IMAGE/image: none
    show MAIN-IMAGE
]

MAIN-WINDOW: layout [
    across
    label "Page title"
    MAIN-HEADING: field 500 HTML-HEADING 
    return
    MAIN-IMAGE: image 800x600 'aspect 
    return 
    label "Image caption: "
    MAIN-CAPTION: field 500
    return
    button "Quit" [QUIT-BUTTON]
    button "Choose file" [CHOOSE-FILE-BUTTON]
    button "Embed" [EMBED-BUTTON]
    button "Save html" [SAVE-HTML-BUTTON]
    button "Clear html" [CLEAR-HTML-BUTTON]
]

view center-face MAIN-WINDOW

