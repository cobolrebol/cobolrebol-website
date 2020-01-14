REBOL [
    Title: "Share one file by ftp"
    Purpose: {Send one file to a hard-coded folder on an ftp server.} 
]

;; [---------------------------------------------------------------------------]
;; [ This is one half of a pair of programs for getting or putting a single    ]
;; [ file to/from a specific folder on an ftp server.                          ]
;; [ The original purpose of this program was to work on files at the office   ]
;; [ and at home.  Sort of like a very, very primitive "dropbox."              ]
;; [ This program obtains a list of all the files in the current folder and    ]
;; [ displays them in a text-list.  The operator selects one of the files      ]
;; [ and the program uploads it to a hard-coded location on an ftp site.       ]
;; [ This program can be as simple as it is because it is based on the         ]
;; [ assumption that your work flow is simple, specifically, put one file      ]
;; [ at a time, and get it from the folder on your local computer where you    ]
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
UPLOAD-FILE: none  ;; File name picked from the list
UPLOAD-URL: none   ;; Full name of file to upload

;; Get all the file names in the current directory.
FILE-NAMES: read %.

;; This function responds to the selection of a file from the text-list.
COPY-BUTTON: does [
    UPLOAD-FILE: none
;;  -- Get the name from the list of files 
    either empty? FILE-LIST/picked [
        alert "Select file from list"
        exit
    ] [
        UPLOAD-FILE: first FILE-LIST/picked   
    ]
;;  -- Construct the name on the ftp site
    UPLOAD-URL: rejoin [
        REPOSITORY-NAME
        UPLOAD-FILE
    ]
;;  -- Read the file from the current folder and write to the ftp server
    write/binary UPLOAD-URL read/binary UPLOAD-FILE
    alert "Done."
]

MAIN-WINDOW: layout [
    across
    banner "Share One file: put" font [size: 32]
    return
    FILE-LIST: text-list 500x600 data (FILE-NAMES)
    return
    button "Put" [COPY-BUTTON]
    button "Quit" [quit]
]

view center-face MAIN-WINDOW 

