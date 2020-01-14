REBOL [
    Title: "Report the memory and other data from the computer info files"
    Purpose: {Use a folder of files from the GatherComputerInfo
    program and list some miscellaneous information about each computer,
    including memory which is important information when planning  
    software upgrades.}
]

;; [---------------------------------------------------------------------------]
;; [ This program was suggested as a way to report the memory and other        ]
;; [ important information about deployed computers.                           ]
;; [ It uses text files created at startup time by computers.                  ]
;; [ Each text file contains information that the computer gathered about      ]
;; [ itself, Those files                                                       ]
;; [ were written into a common folder, and then all files in that folder      ]
;; [ were processed by this program which extracted the information we want    ]
;; [ to report.                                                                ]
;; [ The file is text in a REBOL-readable format, and the relevant items       ]
;; [ look like this:                                                           ]
;; [ COMPUTERNAME: "IS-SWHITE7"                                                ]
;; [ MANUFACTURER: "Hewlett-Packard"                                           ]
;; [ MODEL: "HP EliteDesk 800 G1 SFF"                                          ]
;; [ SERIALNO: "2UA52831RN"                                                    ]
;; [ MEMORY: "15.9085540771484"                                                ]
;; [ LASTREBOOT: "06/27/2017 09:19:27"                                         ]
;; [ DEFAULTBROWSER: "C:\Program Files\Internet Explorer\iexplore.exe"         ]
;; [                                                                           ]
;; [ The program to create these files is on the COBOLREBOL free stuff area    ]
;; [ and is called GatherComputerInfo.ps1.                                     ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Change these items for your own installation.                             ]
;; [---------------------------------------------------------------------------]

MR-FILENAME: %ComputerMemory.html    ;; output report in html format
LOGDIR: %ComputerList                ;; folder of computer info files

;; [---------------------------------------------------------------------------]
;; [ In a report file, there are several REBOL-readable data items.            ]
;; [ The ones below are the ones we will report on.                            ]
;; [---------------------------------------------------------------------------]

MR-COMPUTER: ""
MR-MODEL: ""
MR-WINDOWS: ""
MR-MEMORY: ""
MR-ADOBE: ""
MR-BROWSER: ""
MR-BROWSERPATH: none
MR-BROWSERPARTS: []
MR-PAGE: ""
MR-CORRUPT-FILE-NAME: ""

;; [---------------------------------------------------------------------------]
;; [ In our first attempt (and this might still be true), powershell put       ]
;; [ nulls in the list of monitors.  So we will read the file as binary,       ]
;; [ replace nulls with empty strings or spaces (whatever works), and then     ]
;; [ load that instead of loading the file directly.                           ]
;; [---------------------------------------------------------------------------]

PHONEHOME-BINARY: ""

;; [---------------------------------------------------------------------------]
;; [ These are the html fragments we will use to produce a report.             ]
;; [---------------------------------------------------------------------------]

MR-HTML-HEAD: {
<html>
<head>
<title>Computer Memory Report</title>
</head>
<body>
<h1>Computer memory report</h1>
<table width="100%" border="1">
<tr>
<th>Computer name</th>
<th>Model</th>
<th>Windows version</th>
<th>Memory</th>
<th>Adobe Version</th>
<th>Default browser</th>
</tr>
}
MR-HTML-FOOT: {
</table>
</body>
</html>
}
MR-HTML-ROW: {
<tr>
<td> <% MR-COMPUTER %> </td>
<td> <% MR-MODEL %> </td>
<td> <% MR-WINDOWS %> </td>
<td> <% MR-MEMORY %> </td>
<td> <% MR-ADOBE %> </td>
<td> <% MR-BROWSER %> </td>
</tr>
}
MR-HTML-CORRUPT: {
<tr>
<td> <% MR-COMPUTER %> </td>
<td colspan="7"> <% rejoin ["Corrupt file " MR-CORRUPT-FILE-NAME] %> </td>
</tr> 
} 

change-dir LOGDIR
FILE-LIST: read %.

append MR-PAGE MR-HTML-HEAD
append MR-PAGE newline

foreach PHONEHOME-FILE FILE-LIST [
    MR-COMPUTER: copy "" 
    MR-BROWSER: copy ""
    MR-BROWSERPATH: copy ""
    MR-BROWSERPARTS: copy []
    USERNAME: copy ""
    LOGINDATE: copy ""
    LOGINTEIME: copy ""
    COMPUTERNAME: copy ""
    MANUFACTURER: copy ""
    MODEL: copy ""
    SERIALNO: copy ""
    LOGGEDIN: copy ""
    OS: copy ""
    MEMORY: copy ""
    LASTREBOOT: copy ""
    DEFAULTBROWSER: copy ""
    INSTALLED-SOFTWARE: copy []
    PHONEHOME-BINARY: copy ""
;;  -- start of existence check
    either exists? PHONEHOME-FILE [
;;      -- the file exists   
        PHONEHOME-BINARY: to-string read/binary PHONEHOME-FILE
        replace/all PHONEHOME-BINARY #{00} "" 
        either error? try [do load PHONEHOME-BINARY] [
;;          -- the file is bad
            MR-CORRUPT-FILE-NAME: to-string PHONEHOME-FILE
            append MR-PAGE build-markup MR-HTML-CORRUPT   
            append MR-PAGE newline
        ] [
;;          -- the file is loadable, but could be incomplete
            MR-COMPUTER: COMPUTERNAME
            either equal? MODEL "" [
                MR-MODEL: "&nbsp;"
            ] [
                MR-MODEL: MODEL
            ]
            either equal? OS "" [
                MR-WINDOWS: "&nbsp"
            ] [
                MR-WINDOWS: OS
            ]
            either equal? MEMORY "" [
                MR-MEMORY: "&nbsp;"
            ] [
                MR-MEMORY: trim/all/with to-string to-money MEMORY "$" ;; cheap trick 
            ]
            either equal? DEFAULTBROWSER "" [
                MR-BROWSER: "&nbsp;"
            ] [
                MR-BROWSERPATH: to-rebol-file DEFAULTBROWSER
                MR-BROWSERPARTS: split-path MR-BROWSERPATH 
                MR-BROWSER: copy second MR-BROWSERPARTS
            ]
            MR-ADOBE: copy ""
            MR-REMIT: copy ""
            foreach [PKG VER] INSTALLED-SOFTWARE [
                if find/any PKG "Adobe Acrobat*" [
                    append MR-ADOBE PKG
                    append MR-ADOBE rejoin [
                        ", "
                        VER
                        " "
                    ]
                ]
            ]
            if equal? MR-ADOBE "" [
                MR-ADOBE: "&nbsp;"
            ]
            append MR-PAGE build-markup MR-HTML-ROW
            append MR-PAGE newline
        ]   
    ] [
;;      -- the file does not exist
        MR-MODEL: "unknown"
        MR-WINDOWS: "unknown"
        MR-MEMORY: "unknown"
        MR-ADOBE: "unknown"
        append MR-PAGE build-markup MR-HTML-ROW
        append MR-PAGE newline
    ]
;;  -- end of existence check
]

append MR-PAGE MR-HTML-FOOT
append MR-PAGE newline
write MR-FILENAME MR-PAGE
browse MR-FILENAME

;halt

