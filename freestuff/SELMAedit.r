REBOL [
    Title: "Secure Encrypted List Maintenance Assistant"
]

;; [--------------------------------------------------------------------------]
;; [ MPW-LIST will be the password list, decrypted, and held in memory.       ]
;; [ MPW-ENCRYPTED-FILE is the name of the incrypted file.                    ]
;; [ We created the file in advance with a one-time program.                  ]
;; [ The name is hard-coded because in the orignal use of the program         ]
;; [ the file was a master password list that we wanted to be obscure.        ]
;; [ This script could be encapsulated into an exe file with the REBOL SDK.   ]
;; [--------------------------------------------------------------------------]

MPW-LIST: ""
MPW-ENCRYPTED-FILE: %MPW.enc

;; [--------------------------------------------------------------------------]
;; [ This encryption key was obtained with this command:                      ]
;; [ MPW-ENCRYPTION-KEY: copy/part checksum/secure "OrangeJuice" 16           ]
;; [--------------------------------------------------------------------------]

MPW-ENCRYPTION-KEY: #{2937B848C4670572DC392CC958C68F0D}

;; [---------------------------------------------------------------------------]
;; [ The two port descriptions below, and the following procedures for         ]
;; [ encrypting and decrypting the file, were obtained from the REBOL          ]
;; [ web site in the document that explains the features of the                ]
;; [ software development kit.  We have the software development kit,          ]
;; [ but it appears that the encryption feature has been moved into the        ]
;; [ free version of REBOL.                                                    ]
;; [---------------------------------------------------------------------------]

MPW-ENCRYPTION-PORT: make port! [
    scheme: 'crypt
    algorithm: 'blowfish
    direction: 'encrypt
    strength: 128
    key: MPW-ENCRYPTION-KEY
    padding: true
]

MPW-DECRYPTION-PORT: make port! [
    scheme: 'crypt
    algorithm: 'blowfish
    direction: 'decrypt
    strength: 128
    key: MPW-ENCRYPTION-KEY
    padding: true
]

MPW-ENCRYPT-list: does [
    open MPW-ENCRYPTION-PORT
    insert MPW-ENCRYPTION-PORT MPW-LIST                    
    update MPW-ENCRYPTION-PORT
    write/binary MPW-ENCRYPTED-FILE copy MPW-ENCRYPTION-PORT
    close MPW-ENCRYPTION-PORT
]

MPW-DECRYPT-FILE: does [
    open MPW-DECRYPTION-PORT
    insert MPW-DECRYPTION-PORT read/binary MPW-ENCRYPTED-FILE 
    update MPW-DECRYPTION-PORT
    MPW-LIST: copy ""
    MPW-LIST: to-string copy MPW-DECRYPTION-PORT
    close MPW-DECRYPTION-PORT
]

;; [---------------------------------------------------------------------------]
;; [ This function loads the decrypted password list into the editing area     ]
;; [ of the main window, and then sets various control items that make the     ]
;; [ associated scroller operate correctly.  We need a scroller because the    ]
;; [ list is more than will fit into the editing box.                          ]
;; [---------------------------------------------------------------------------]

LOAD-MAIN-LIST: does [
    MAIN-LIST/text: MPW-LIST
    MAIN-LIST/para/scroll/y: 0
    MAIN-LIST/line-list: none
    MAIN-LIST/user-data: second size-text MAIN-LIST
    MAIN-LIST-SCROLLER/redrag MAIN-LIST/size/y / MAIN-LIST/user-data
    show MAIN-LIST
]

;; [---------------------------------------------------------------------------]
;; [ This function takes the editing area and the associated scroller          ]
;; [ as arguments and redisplays the text in response to the activity of       ]
;; [ the scroller.  In other words, it makes the scroller operate.             ]
;; [---------------------------------------------------------------------------]

SCROLL-TEXT: func [TXT BAR] [
    ;; -- Make sure important values are not 'none'. 
    if TXT/user-data [
        if TXT/size/y [
            TXT/para/scroll/y: negate BAR/data * 
                (max 0 TXT/user-data - TXT/size/y)
            SHOW TXT
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function is called by the "Quit" button.                             ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This function is called by the "Save" button.                             ]
;; [---------------------------------------------------------------------------]

SAVE-BUTTON: does [
    MPW-LIST: copy ""
    MPW-LIST: copy MAIN-LIST/text
    MPW-ENCRYPT-LIST 
    alert "Updated list saved"
]

;; [---------------------------------------------------------------------------]
;; [ This is the main (and only) window.                                       ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    space 5x5
    across
    banner "Secure Encrypted List Maintenance Assistant" font [shadow: none]
    return
    button "Quit" [QUIT-BUTTON]
    button "Save" [SAVE-BUTTON]
    return
    space 0
    MAIN-LIST: area 600x700 MPW-LIST
    MAIN-LIST-SCROLLER: scroller 16x700
        [SCROLL-TEXT MAIN-LIST MAIN-LIST-SCROLLER] 
    space 10x10
    return
    pad 0x10
    button "Quit" [QUIT-BUTTON]
    button "Save" [SAVE-BUTTON]
] 

;; [---------------------------------------------------------------------------]
;; [ Begin.                                                                    ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ Read and decrypt the file, and store the decripted file in memory.        ]
;; [---------------------------------------------------------------------------]

MPW-DECRYPT-FILE

;; [---------------------------------------------------------------------------]
;; [ Load the text editing area with the password list and reset the           ]
;; [ scroller so it will scroll the text correctly.                            ]
;; [---------------------------------------------------------------------------]

LOAD-MAIN-LIST

;; [---------------------------------------------------------------------------]
;; [ Display the main window and respond to its controls.                      ]
;; [---------------------------------------------------------------------------]

view center-face MAIN-WINDOW

