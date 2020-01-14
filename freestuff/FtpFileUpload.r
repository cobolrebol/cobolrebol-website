REBOL [
    Title: "FTP file upload"
    Purpose: {Transfer a single file to a folder on an ftp site.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a little utility program for a specific situation.                ]
;; [ It is based on the assumption that we have a single folder on an ftp      ]
;; [ site where we keep files for storage and sharing.                         ]
;; [ This program uploads a selected file to that folder.                      ]
;; [ The name of the ftp site and the directory are hard-coded.                ]
;; [ For a bit more generality, you could put the REPOSITORY-NAME in a         ]
;; [ configuration file and "do" that file at the start of the program.        ]
;; [ The hard-coding here is so that this script can be self-contained.        ]
;; [---------------------------------------------------------------------------]

REPOSITORY-NAME: ftp://USERID:PASSWORD@FTPSERVER/FOLDERNAME/
system/schemes/ftp/passive: true

FILE-NAME: none
LAST-NODE: none
CONFIRMATION-MESSAGE: copy ""
FTP-FILENAME: none

FILE-NAME: request-file/only
if not FILE-NAME [
    alert "No file select to send by ftp"
    exit
]
LAST-NODE: last parse to-string FILE-NAME "/"
FTP-FILENAME: to-url join REPOSITORY-NAME [LAST-NODE]

CONFIRMATION-MESSAGE: reform [
    "Transferring "
    to-string FILE-NAME
    " to "
    to-string FTP-FILENAME
]

either alert [CONFIRMATION-MESSAGE "OK" "CANCEL"] [
    write/binary FTP-FILENAME read/binary FILE-NAME
    alert "Transfer complete"
] [
    alert "No transfer performed"
]

