REBOL [
    Title: "Share one file by ftp"
    Purpose: {Get one file from a hard-coded folder on an ftp server.} 
]

;; [---------------------------------------------------------------------------]
;; [ This is one half of a pair of programs for getting or putting a single    ]
;; [ file to/from a specific folder on an ftp server.                          ]
;; [ The original purpose of this program was to work on files at the office   ]
;; [ and at home.  Sort of like a very, very primitive "dropbox."              ]
;; [ This program obtains a list of all the files in the specific folder and   ]
;; [ displays them in a text-list.  The operator selects one of the files      ]
;; [ and the program downloads that file to the current directory.             ]
;; [ This program can be as simple as it is because it is based on the         ]
;; [ assumption that your work flow is simple, specifically, get one file      ]
;; [ at a time, and put it into the folder on your local computer where you    ]
;; [ are working.  With a simple work flow you can use a simple tool.          ]
;; [ With a more complicated work flow, you probably would need a more         ]
;; [ complicated tool.                                                         ]
;; [---------------------------------------------------------------------------]

;; Modify this line for your own ftp server.
;; Format of the ftp site is like this:
;; ftp://userid:password@ftpsite//workingfolder
;; Generally:
;;     userid = user ID
;;     password = password
;;     ftpsite = ftp site name 
;;     workingfolder = folder where your files are located
;; You might have to do a little experimenting to get the folder name
;; right, depending on where the ftp connection puts you when you log in.
;; Using the ftp protocol in this shortened manner does hide a bit of
;; what is happending behind the scenes.
REPOSITORY-NAME: ftp://userid:password@ftpsite//workingfolder/

;; We are going to be doing some constructing of file names.
DOWNLOAD-FILE: none  ;; File name picked from the list
DOWNLOAD-URL: none   ;; Full name of file to download

;; Get all the file names on the ftp server, in the hard-coded work folder.
FILE-NAMES: read REPOSITORY-NAME 

;; This function responds to the selection of a file from the text-list.
COPY-BUTTON: does [
    DOWNLOAD-FILE: none
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
    banner "Share One file: get" font [size: 32]
    return
    FILE-LIST: text-list 500x600 data (FILE-NAMES)
    return
    button "Get" [COPY-BUTTON]
    button "Quit" [quit]
]

view center-face MAIN-WINDOW 

