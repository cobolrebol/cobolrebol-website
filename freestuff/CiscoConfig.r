REBOL [
    Title: "Report Cisco configuration changes"
    Purpose: {This is program to make a little report of data items
    from a log file that seems to be a standard output from various
    Cisco switches and routers and such.}                          
]

;; [---------------------------------------------------------------------------]
;; [ Files used in the program.                                                ]
;; [ We put these in one place so it is easy to change them as requirements    ]
;; [ evolve.                                                                   ]
;; [---------------------------------------------------------------------------]

CONFIG-LOG: %CiscoConfig.txt
OUTPUT-FILE: %CiscoConfig.htm

;; [---------------------------------------------------------------------------]
;; [ This script has been sanitized for giving away.  The code below can be    ]
;; [ used to make a test file to show the program's operation.                 ]
;; [---------------------------------------------------------------------------]

DEMO: true
DEMO-DATA:  
{6/22/2017 4:37 AM|111.222.333.161|111.222.333.161|SYS-5-CONFIG_I|69: 000068: *Jun 22 04:08:10: %SYS-5-CONFIG_I: Configured from console by console
6/22/2017 4:37 AM|111.222.333.161|111.222.333.161|SYS-5-CONFIG_I|70: 000069: *Jun 22 04:08:10: %SYS-5-CONFIG_I: Configured from console by console
6/22/2017 4:37 AM|111.222.333.161|111.222.333.161|SYS-5-CONFIG_I|72: 000071: *Jun 22 04:08:10: %SYS-5-CONFIG_I: Configured from console by console
6/22/2017 1:19 PM|111.222.333.141|111.222.333.141|SYS-5-CONFIG_I|26990: 026993: Jun 22 13:19:19: %SYS-5-CONFIG_I: Configured from console by jsmith on vty0 (10.1.250.78)
6/23/2017 8:42 AM|111.222.333.141|111.222.333.141|SYS-5-CONFIG_I|26998: 027001: Jun 23 08:42:24: %SYS-5-CONFIG_I: Configured from console by jsmith on vty0 (10.1.250.78)
6/24/2017 12:31 PM|111.222.333.217|111.222.333.217|SYS-5-CONFIG_I|72: 002391: Jun 24 12:31:10: %SYS-5-CONFIG_I: Configured from 10.1.0.100 by snmp
6/26/2017 1:24 PM|111.222.333.132|111.222.333.132|SYS-5-CONFIG_I|1223: 001257: Jun 26 13:24:57: %SYS-5-CONFIG_I: Configured from console by jsmith on vty0 (10.1.250.78)
6/26/2017 1:32 PM|111.222.333.133|111.222.333.133|SYS-5-CONFIG_I|59: 000078: .Jun 26 13:32:39: %SYS-5-CONFIG_I: Configured from console by jsmith on vty0 (10.1.250.78)
6/28/2017 7:33 AM|111.222.333.141|111.222.333.141|SYS-5-CONFIG_I|27032: 027035: Jun 28 07:33:12: %SYS-5-CONFIG_I: Configured from console by jsmith on vty0 (10.1.250.78)}
if DEMO [
    write CONFIG-LOG DEMO-DATA
]

;; [---------------------------------------------------------------------------]
;; [ These are some functions used for emitting the html code in the final     ]
;; [ report.                                                                   ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Items set up by the caller.                                               ]
;; [---------------------------------------------------------------------------]

HTMLREP-FILE-ID: %htmlrep.html
HTMLREP-TITLE: "&nbsp;"
HTMLREP-PRE-STRING: "&nbsp;"
HTMLREP-POST-STRING: "&nbsp;"
HTMLREP-PROGRAM-NAME: "&nbsp;"
HTMLREP-CODE-BLOCK: "&nbsp;"

;; [---------------------------------------------------------------------------]
;; [ Internal working items.                                                   ]
;; [---------------------------------------------------------------------------]

HTMLREP-FILE-OPEN: false

;; [---------------------------------------------------------------------------]
;; [ This is the top of the html page.                                         ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE-HEAD: {
<html>
<head>
<meta http-equiv="refresh" content="30">
<title> VPN logins </title>
<style>
body {
   background: #F2F2E3;
}
h1 {
    color: #9931fE;
    font-family: arial, helvetica, sans-serif;
    font-size: 80px;
}
th {
    font-family: arial, helvetica, sans-serif;
    font-size: 30px;
}
td {
    font-family: arial, helvetica, sans-serif;
    font-size: 30px;
}
p {
    font-family: arial, helvetica, sans-serif;
    font-size: 30px;
}
</style>
</head>

<body>
<table width="100%" border="0">
<tr>
<td><h1 align="center"> Router Configuration Changes </h1></td>
</tr>
</table>

<table width="100%" border="1">
}

;; [---------------------------------------------------------------------------]
;; [ This is the end of the html page.                                         ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE-FOOT: {
</table>
</body>
</html>
}

;; [---------------------------------------------------------------------------]
;; [ This is the area where we will build up the html page in memory.          ]
;; [---------------------------------------------------------------------------]

HTMLREP-PAGE: make string! 5000

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to "open" the report.                               ]
;; [ The "build-markup" function will replace the placeholders in the html     ]
;; [ with the values resulting from their evaluation.                          ]
;; [---------------------------------------------------------------------------]

HTMLREP-OPEN: does [
    HTMLREP-PAGE: copy ""
    append HTMLREP-PAGE build-markup HTMLREP-PAGE-HEAD
    append HTMLREP-PAGE newline
    HTMLREP-FILE-OPEN: true
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure to "close" the report.                              ]
;; [ It writes to disk the html page we have built up in memeory.              ]
;; [---------------------------------------------------------------------------]

HTMLREP-CLOSE: does [
    append HTMLREP-PAGE build-markup HTMLREP-PAGE-FOOT
    append HTMLREP-PAGE newline
    write HTMLREP-FILE-ID HTMLREP-PAGE
    HTMLREP-FILE-OPEN: false
]

;; [---------------------------------------------------------------------------]
;; [ This procedure emits a row of an html table containing heading            ]
;; [ elements supplied by the caller in a block of strings.                    ]
;; [---------------------------------------------------------------------------]

HTMLREP-EMIT-HEAD: func [
    "Emit a heading row with literals supplied in a block"
    HTMLREP-HEADING-BLOCK [block!]
] [
    append HTMLREP-PAGE "<TR>"
    foreach HTMLREP-HEAD-LIT HTMLREP-HEADING-BLOCK [
        append HTMLREP-PAGE {<TH align="center">}
        append HTMLREP-PAGE HTMLREP-HEAD-LIT
        append HTMLREP-PAGE "</TH>"
    ]
    append HTMLREP-PAGE "</TR>"
    append HTMLREP-PAGE newline
]

;; [---------------------------------------------------------------------------]
;; [ This procedure emits a row of an html table containing the values of      ]
;; [ words supplied by the caller in a block.                                  ]
;; [ Note the requirement that the caller "reduce" the block passed to this    ]
;; [ function so that we are getting values and not words.                     ]
;; [---------------------------------------------------------------------------]

HTMLREP-EMIT-LINE: func [
    "Emit a detail row with values supplied in a block"
    HTMLREP-DETAIL-BLOCK [block!]
] [
    append HTMLREP-PAGE "<TR>"
    foreach HTMLREP-VALUE HTMLREP-DETAIL-BLOCK [
        append HTMLREP-PAGE {<TD align="center">}
        append HTMLREP-PAGE HTMLREP-VALUE
        append HTMLREP-PAGE "</TD>"
    ]
    append HTMLREP-PAGE "</TR>"
    append HTMLREP-PAGE newline
]

;; [---------------------------------------------------------------------------]
;; [ End of html functions.                                                    ]
;; [ Below is the operation performed by this program.                         ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Data we will be working with.                                             ]
;; [ We are going to display only a few lines, as many as will fit on a        ]
;; [ monitor.                                                                  ]
;; [---------------------------------------------------------------------------]

CONFIG-LINES: []
WS-DATE: ""
WS-SWITCH: ""
WS-IP: ""
WS-XXX: ""
WS-USERID: ""
WS-FROM: ""
WS-START: 0
WS-STOP: 0
WS-LENGTH: 0
WS-COUNTER: 0
WS-PAGESIZE: 20

;; [---------------------------------------------------------------------------]
;; [ Set up the output file.                                                   ]
;; [---------------------------------------------------------------------------]

HTMLREP-FILE-ID: OUTPUT-FILE
HTMLREP-TITLE: "Cisco Changes"
HTMLREP-PROGRAM-NAME: "CiscoConfig.r"
HTMLREP-OPEN
HTMLREP-EMIT-HEAD [
    "DATE-TIME"
    "SWITCH"
    "USERID"
    "FROM"
]

;; [---------------------------------------------------------------------------]
;; [ Bring the entire file into memory.                                        ]
;; [---------------------------------------------------------------------------]

CONFIG-LINES: read/lines CONFIG-LOG
WS-LENGTH: length? CONFIG-LINES
WS-STOP: WS-LENGTH
if (WS-LENGTH <= WS-PAGESIZE) [
    WS-START: 0
]
if (WS-LENGTH > WS-PAGESIZE) [
    WS-START: (WS-STOP - WS-PAGESIZE)
]

;; [---------------------------------------------------------------------------]
;; [ Take apart each line and put the relevant data items in the output        ]
;; [ report.                                                                   ]
;; [---------------------------------------------------------------------------]

ID-CHAR: charset "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

foreach LINE CONFIG-LINES [
    WS-COUNTER: WS-COUNTER + 1
    if (WS-COUNTER > WS-STOP) [
        break
    ]
    WS-DATE: copy ""
    WS-SWITCH: copy ""
    WS-USERID: copy ""
    WS-FROM: copy ""
    if (WS-COUNTER > WS-START) [
        set [WS-DATE WS-SWITCH WS-IP WS-XXX WS-MSG ] parse/all LINE "|"
        parse/all/case WS-MSG [
            thru " by " copy WS-USERID some ID-CHAR
            thru "(" copy WS-FROM TO ")"
        ]
        HTMLREP-EMIT-LINE reduce [
            WS-DATE
            WS-SWITCH
            WS-USERID
            WS-FROM
        ]
    ]
]

attempt [HTMLREP-CLOSE]

;halt
;alert "Done."

