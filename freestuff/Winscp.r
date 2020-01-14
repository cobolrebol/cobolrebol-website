REBOL [
    Title: "Securely send folders by sftp"
    Purpose: {Get the names of all the folders in a special transfer
    area.  Send them to a secure server and remove them.}
]

;; [---------------------------------------------------------------------------]
;; [ The purpose of this program is to identify all the files in the           ]
;; [ source folder, transmit them to a destination, and then delete them.      ]
;; [ We will send them with a secure ftp program that can be scripted.         ]
;; [ It appears that REBOL can't do sftp.                                      ]
;; [ The scriptable sftp program we use is at: https://winscp.net              ]
;; [                                                                           ]
;; [ The program uses the REBOL "call" function to call WinSCP (the sriptable  ]
;; [ sftp client) to send the files, and Powershell to remove the files.       ]
;; [ The reason it uses WinSCP is that REBOL can't do secure ftp, and the      ]
;; [ reason it uses Powershell to delete files is that it seems REBOL can't    ]
;; [ delete a folder without first deleting everything in it, and              ]
;; [ Powershell can simply with the "recurse" option.                          ]
;; [ It appears that the "call/wait" function does indeed wait until the       ]
;; [ called program is done, so there is no danger of trying to remove a       ]
;; [ folder before it has been sent.                                           ]
;; [                                                                           ]
;; [ In the original use scenario for this program, the data to be sent        ]
;; [ was in folders, and each folder was to be sent, recursively.              ]
;; [ WinSCP handles this very nicely.  The same syntax works for individual    ]
;; [ files, so while this program originally was used to send folders,         ]
;; [ it would work as-is (or maybe with some minor change) for individual      ]
;; [ files.                                                                    ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Change the following items for your own installation.                     ]
;; [---------------------------------------------------------------------------]

SOURCE-DIR: %/C/OUTBOX/                ;; Folder of folders to be sent
SFTP-SERVER: "sft.servername.com"      ;; Destination server
USERID: "UserID"                       ;; Account on above server  
PASSWORD: "Password"                   ;; Password for above account
LOG-FILE-ID: %SendFolders.log          ;; Log what we do for auditing
LOG-FOLDER: %/SERVERNAME/TaskLogs/     ;; Send log here

;; [---------------------------------------------------------------------------]
;; [ HOME-DIR         Our starting folder because we will have to move.        ]
;; [ SENT-ITEM-LOCAL: The local-fomat name of the item we are going to send.   ]
;; [ BAT-FILE:        A generated DOS batch file to run WinSCP.                ]
;; [ PS1-FILE:        A generated Powershell script to remove folders.         ]
;; [ FILE-LIST:       A list of all the items we are about to send.            ]
;; [---------------------------------------------------------------------------]

HOME-DIR: what-dir                 
SENT-ITEM-LOCAL: none
BAT-FILE: ""
PS1-FILE: ""
FILE-LIST: []

;; [---------------------------------------------------------------------------]
;; [ Using a file/folder name from the list, generate its full name in         ]
;; [ a format suitable for the computer on which this program is running,      ]
;; [ which has to be a Windows computer since WinSCP runs on Windows.          ]
;; [---------------------------------------------------------------------------]

GENERATE-FILE-NAMES: func [
    SINGLE-FILE-ID
] [
    SENT-ITEM-LOCAL: to-local-file rejoin [
        to-string SOURCE-DIR
        to-string SINGLE-FILE-ID
    ]
]

;; [---------------------------------------------------------------------------]
;; [ After the local file name is generated, generate the batch file           ]
;; [ command that will run WinSCP.                                             ]
;; [---------------------------------------------------------------------------]

GENERATE-BATCH-FILE: does [
    BAT-FILE: copy ""
    BAT-FILE: rejoin [
        {winscp.com /command }
        {"open } USERID {:} PASSWORD {@} SFTP-SERVER {" }
        {"put } SENT-ITEM-LOCAL {" }
        {"close" }
        {"exit"}
    ]
]

;; [---------------------------------------------------------------------------]
;; [ After the local file name is generated, generate a Powershell command     ]
;; [ to remove the folder after it has been sent.                              ]
;; [---------------------------------------------------------------------------]

GENERATE-REMOVE-FILE: does [
    PS1-FILE: copy ""
    PS1-FILE: rejoin [
        {powershell -command }
        {"Remove-Item } SENT-ITEM-LOCAL { -recurse" }
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Log a line of text with a date stamp.                                     ]
;; [---------------------------------------------------------------------------]

LOG-EVENT: func [
    LOG-LINE
] [
    write/append to-file rejoin [HOME-DIR LOG-FILE-ID] rejoin [
        now
        " "
        LOG-LINE
        newline
    ] 
]

;; [---------------------------------------------------------------------------]
;; [ Go to the folder where we expect to find the folders to send.             ]
;; [ Get a list of all folder names currently in the source directory.         ]
;; [---------------------------------------------------------------------------]

LOG-EVENT "BOJ SendCaseFiles"
change-dir SOURCE-DIR
FILE-LIST: read %.
if equal? 0 length? FILE-LIST [
    LOG-EVENT "No items found to send."
]

;; [---------------------------------------------------------------------------]
;; [ For each item on the list,                                                ]
;; [ 1.  Generate the full name of the item in Windows format.                 ]
;; [ 2.  Generate the DOS command to send the item.                            ]
;; [ 3.  Generate the Powershell command to delete the item.                   ]
;; [ 4.  Send the item using the generated command.                            ]
;; [ 5.  Delete the item using the generated command.                          ]
;; [ Log the steps as we do them.                                              ]
;; [---------------------------------------------------------------------------]

foreach FILE-ID FILE-LIST [
    GENERATE-FILE-NAMES FILE-ID
    GENERATE-BATCH-FILE
    GENERATE-REMOVE-FILE
    LOG-EVENT replace copy BAT-FILE PASSWORD "???????"
    call/wait BAT-FILE
    LOG-EVENT rejoin [FILE-ID " sent."]
    LOG-EVENT PS1-FILE
    call/wait PS1-FILE
    LOG-EVENT rejoin [FILE-ID " removed."]
]

;; [---------------------------------------------------------------------------]
;; [ Finish the log for this run, and then send the log to a different         ]
;; [ area for viewing.  (Originally, this program was run on a secure server.) ]
;; [---------------------------------------------------------------------------]

LOG-EVENT "EOJ SendCaseFiles"
write to-file rejoin [LOG-FOLDER LOG-FILE-ID] 
    read to-file rejoin [HOME-DIR LOG-FILE-ID]

;;Uncomment the "halt" for debugging.
;halt

