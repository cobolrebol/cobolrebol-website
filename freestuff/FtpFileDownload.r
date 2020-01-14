REBOL [
    Title: "FTP file download"
    Purpose: {Show a list of all files in a specified directlory on an
    ftp site, and download a selected one.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a little utility program for a specific situation.                ]
;; [ It is based on the assumption that we have a single folder on an ftp      ]
;; [ site where we keep files for storage and sharing.                         ]
;; [ This program shows a list of those files and has a button to download     ]
;; [ a single selected file.                                                   ]
;; [ The name of the ftp site and the directory are hard-coded.                ]
;; [ For a bit more generality, you could put the REPOSITORY-NAME in a         ]
;; [ configuration file and "do" that file at the start of the program.        ]
;; [ The hard-coding here is so that this script can be self-contained.        ]
;; [---------------------------------------------------------------------------]

REPOSITORY-NAME: ftp://USERID:PASSWORD@FTPSERVER/FOLDERNAME/
system/schemes/ftp/passive: true

DOWNLOAD-FILE: none
DOWNLOAD-URL: none 
DOWNLOAD-TEXT: none

FILE-NAMES: read REPOSITORY-NAME 

COPY-BUTTON: does [
    DOWNLOAD-PATH: none
    DOWNLOAD-FILE: none
    DOWNLOAD-TEXT: copy ""
;;  -- Get the name from the list of files 
    either empty? FILE-LIST/picked [
        alert "Select file from list"
        exit
    ] [
        DOWNLOAD-FILE: first FILE-LIST/picked   
    ]
;;  -- Construct the name on the ftp site
    DOWNLOAD-URL: rejoin [
        REPOSITORY-NAME
        DOWNLOAD-FILE
    ]
;;  -- Read the file from the site and write it to the local computer
    write/binary DOWNLOAD-FILE read/binary DOWNLOAD-URL
    alert "Done."
]

MAIN-WINDOW: layout [
    across
    banner "File downloader" font [size: 20]
    return
    FILE-LIST: text-list 500x600 data (FILE-NAMES)
    return
    button "Download" [COPY-BUTTON]
    button "Quit" [quit]
]

view center-face MAIN-WINDOW 


