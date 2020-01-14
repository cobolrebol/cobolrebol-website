REBOL [
    Title: "List all folders with descriptions"
    Purpose: {List all the folders that were labeled with the
    FolderLabeler.r program.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a companion program to FolderLabeler.r.  It goes through all      ]
;; [ the folders in a selected directory and locates the "_WHAT-IS-THIS"       ]
;; [ folders, then pulls out the title and description files and makes         ]
;; [ a web page listing the folders with their titles and descriptions.        ]
;; [---------------------------------------------------------------------------]

STARTING-FOLDER: %/C/
LABEL-FOLDER: %_WHAT-IS-THIS/
README-FILE: %readme.txt
TITLE-FILE: %title.txt
DESCRIPTION-FILE: %description.txt
KEYWORDS-FILE: %keywords.txt 
OUTPUT-FILE: %FolderList.html

HTML-HEAD: {
<html>
<head>
<title>Folder list</title>
</head>
<body>
<h1>List of folders in <%STARTING-FOLDER%></h1>
<table width="100%" border="1">
<tr>
<th> FOLDER NAME </tn>
<th> FOLDER TITLE </th>
<th> FOLDER DESCRIPTION </th>
</tr>
}

HTML-FOOT: {
</table>
</body>
</html>
}

HTML-BODY: {
<tr>
<td> <%WS-FOLDERNAME%> </td>
<td> <%WS-FOLDERTITLE%> </td>
<td> <%WS-FOLDERDESCRIPTION%> </td>
</tr>
}

WS-FOLDERNAME: ""
WS-FOLDERTITLE: ""
WS-FOLDERDESCRIPTION: ""
FILE-LIST: []
HTML-REPORT: ""

CHECK-FOLDER: func [
    DIRNAME
] [
    WS-FOLDERNAME: copy ""
    WS-FOLDERTITLE: copy ""
    WS-FOLDERDESCRIPTION: copy ""
    change-dir DIRNAME
    if exists? LABEL-FOLDER [
        WS-FOLDERNAME: to-string DIRNAME
        change-dir LABEL-FOLDER
        WS-FOLDERTITLE: read TITLE-FILE
        WS-FOLDERDESCRIPTION: read DESCRIPTION-FILE 
        append HTML-REPORT build-markup HTML-BODY
    ]
    change-dir TARGET-DIR
]

change-dir STARTING-FOLDER
if not TARGET-DIR: request-dir [
    alert "No folder selected"
    quit
]
change-dir TARGET-DIR
FILE-LIST: read TARGET-DIR/.

append HTML-REPORT build-markup HTML-HEAD
foreach FILE-OR-DIR FILE-LIST [
    if dir? FILE-OR-DIR [
        CHECK-FOLDER FILE-OR-DIR
    ]
]
append HTML-REPORT HTML-FOOT

change-dir STARTING-FOLDER
write OUTPUT-FILE HTML-REPORT
browse OUTPUT-FILE

