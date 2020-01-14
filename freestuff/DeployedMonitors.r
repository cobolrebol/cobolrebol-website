REBOL [
    Title: "Report deployed monitors from the computer info files"
    Purpose: {Use a folder of files from the GatherComputerInfo
    program and list the monitors therein, and the computers that
    have them.  This could be quick-and-dirty way to track a site's
    monitor inventory.}
]

;; [---------------------------------------------------------------------------]
;; [ This program was suggested as a way to keep track of monitors that we     ]
;; [ purchase and then deploy without always following official inventory      ]
;; [ procedures.  It uses text files created at startup time by computers.     ]
;; [ Each text file contains information that the computer gathered about      ]
;; [ itself, including the serial numbers of its monitors.  Those files        ]
;; [ were written into a common folder, and then all files in that folder      ]
;; [ were processed by this program which extracted the monitor information.   ]
;; [ The file is text in a REBOL-readable format, and the relevant items       ]
;; [ look like this:                                                           ]
;; [ COMPUTERNAME: "IS-SWHITE7"                                                ]
;; [ MODEL: "HP EliteDesk 800 G1 SFF"                                          ]
;; [ SERIALNO: "2UA52831RN"                                                    ]
;; [ MONITORS: ["CN422004BF      " "HWP             " 2012 ]                   ]
;; [                                                                           ]
;; [ The program to create these files is on the COBOLREBOL free stuff area    ]
;; [ and is called GatherComputerInfo.ps1.                                     ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Change these items for your own installation.                             ]
;; [---------------------------------------------------------------------------]

MR-FILENAME: %DeployedMonitors.html  ;; output report in html format
LOGDIR: %ComputerList                ;; folder of computer info files

;; [---------------------------------------------------------------------------]
;; [ In our html report, we want to mark any monitors on our "watch list"      ]
;; [ of monitors that were lost because they were deployed without the         ]
;; [ official inventory procedure. These are hard-coded serial numbers.        ]
;; [---------------------------------------------------------------------------]

WATCHLIST: [
    "CN45040L60"
    "CN45040L5X"
    "CN45040LG7"
    "2UA52831RM"
    "2UA52831RY"
    "2UA5101VR2"
    "2UA5101VR4"
]  
WATCHLIST-ALERT-COLOR: "#FFE1E1"
WATCHLIST-OK-COLOR: "#FFFFFF"   
WATCHLIST-SEARCH: ""

;; [---------------------------------------------------------------------------]
;; [ In a report file, there are several REBOL-readable data items.            ]
;; [ The ones below are the ones we will report on.                            ]
;; [---------------------------------------------------------------------------]

LOGINDATE: ""
COMPUTERNAME: ""
MODEL: ""
SERIALNO: ""
MONITORS: []
MONITOR-SERIALNO: ""
MONITOR-MANUFACTURER: ""
MONITOR-YEAR: ""
MONITOR-LIST: ""
CURRENT-FILE: ""
REPORT-COLOR: ""

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

MR-PAGE: ""
MR-HTML-HEAD: {
<html>
<head>
<title>Deployed Monitor Report</title>
</head>
<body>
<h1>Deployed Monitor report</h1>
<table width="100%" border="1">
<tr>
<th>Computer name</th>
<th>Model</th>
<th>Serial Number</th>
<th>Monitor Serial, manufacturer, year</th>
<th>Reported on</th>
</tr>
}
MR-HTML-FOOT: {
</table>
</body>
</html>
}
MR-HTML-ROW: {
<tr>
<td> <% COMPUTERNAME %> </td>
<td> <% MODEL %> </td>
<td> <% SERIALNO %> </td>
<td bgcolor="<%REPORT-COLOR%>"> <% MONITOR-LIST %> </td>
<td> <% LOGINDATE %> </td>
</tr>
}
MR-HTML-CORRUPT: {
<tr>
<td> <% COMPUTERNAME %> </td>
<td colspan="4"> <% rejoin ["Corrupt file " CURRENT-FILE] %> </td>
</tr> 
} 

change-dir LOGDIR
FILE-LIST: read %.

append MR-PAGE MR-HTML-HEAD
append MR-PAGE newline

foreach FILENAME FILE-LIST [
    if not dir? FILENAME [
        print ["Checking " FILENAME] 
        CURRENT-FILE: copy ""
        CURRENT-FILE: copy to-string FILENAME
        LOGINDATA: copy ""
        COMPUTERNAME: copy ""
        MODEL: copy ""
        SERIALNO: copy ""
        MONITORS: copy []
        MONITOR-LIST: copy ""
        PHONEHOME-BINARY: copy ""
        REPORT-COLOR: copy WATCHLIST-OK-COLOR
        PHONEHOME-BINARY: to-string read/binary FILENAME
        replace/all PHONEHOME-BINARY #{00} "" 
        either error? try [do load PHONEHOME-BINARY] [
            append MR-PAGE build-markup MR-HTML-CORRUPT
        ] [
            foreach [MONSERIAL MONMAKER MONYEAR] MONITORS [
                append MONITOR-LIST rejoin [
                    trim to-string MONSERIAL
                    ", "
                    trim to-string MONMAKER
                    ", "
                    trim to-string MONYEAR
                    "<br>" 
                ]
                WATCHLIST-SEARCH: copy trim to-string MONSERIAL
                if find WATCHLIST WATCHLIST-SEARCH [
                    REPORT-COLOR: copy WATCHLIST-ALERT-COLOR 
                ]
            ]
            append MR-PAGE build-markup MR-HTML-ROW
        ]
        append MR-PAGE newline  
    ] 
]

append MR-PAGE MR-HTML-FOOT
append MR-PAGE newline
write MR-FILENAME MR-PAGE
browse MR-FILENAME

;halt

