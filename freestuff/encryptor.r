REBOL [
    Title: "Encrypt/decrypt text messages"
]

;; [--------------------------------------------------------------------------]
;; [ This encryption key was obtained with this command:                      ]
;; [ ENCRYPTION-KEY: copy/part checksum/secure "OrangeJuice" 16               ]
;; [--------------------------------------------------------------------------]

ENCRYPTION-KEY: #{2937B848C4670572DC392CC958C68F0D}

;; [---------------------------------------------------------------------------]
;; [ The two port descriptions below, were obtained from the REBOL             ]
;; [ web site in the document that explains the features of the                ]
;; [ software development kit.                                                 ]
;; [ It appears that the encryption feature has been moved into the            ]
;; [ free version of REBOL.                                                    ]
;; [---------------------------------------------------------------------------]

ENCRYPTION-PORT: make port! [
    scheme: 'crypt
    algorithm: 'blowfish
    direction: 'encrypt
    strength: 128
    key: ENCRYPTION-KEY
    padding: true
]

DECRYPTION-PORT: make port! [
    scheme: 'crypt
    algorithm: 'blowfish
    direction: 'decrypt
    strength: 128
    key: ENCRYPTION-KEY
    padding: true
]

;; [---------------------------------------------------------------------------]
;; [ The two procedures below encrypt or decrypt the contents of the           ]
;; [ clipboard.                                                                ]
;; [ For encrypting, it is expected that the clipboard will contain a string.  ]
;; [ REBOL supports only text in the clipboard.  The output of encryption is   ]
;; [ binary data, but the "save" function saves binary in a REBOL              ]
;; [ text-based representation.                                                ]
;; [ For decrypting, it is expected that the clipboard will contain binary     ]
;; [ data in the REBOL text-based binary format, a format that will            ]
;; [ become binary when it is "loaded" with the "load" function.               ]
;; [ The output of decryption is a string in the format we want it,            ]
;; [ so we put it back on the clipboard with the "write" function.             ]
;; [---------------------------------------------------------------------------]

ENCRYPT-CLIPBOARD: does [
    open ENCRYPTION-PORT
    insert ENCRYPTION-PORT read clipboard://
    update ENCRYPTION-PORT
    system/options/binary-base: 64
    save clipboard:// copy ENCRYPTION-PORT 
    close ENCRYPTION-PORT 
]

DECRYPT-CLIPBOARD: does [
    open DECRYPTION-PORT
    system/options/binary-base: 64
    insert DECRYPTION-PORT load clipboard://
    update DECRYPTION-PORT
    write clipboard:// copy DECRYPTION-PORT
    close DECRYPTION-PORT 
]

;; [---------------------------------------------------------------------------]
;; [ The following procedure is called when there is a string on the           ]
;; [ clipboard and we want to encrypt it to paste it into an email.            ]
;; [ The output is put back on the clipboard with some header and trailer      ]
;; [ text so the recipient can figure out what part of the message to          ]
;; [ cut out and feed back into the decrypt function.                          ]
;; [ The header and trailer are NOT part of the message that will be           ]
;; [ decrypted.                                                                ]
;; [---------------------------------------------------------------------------]

ENCRYPTED-MESSAGE: ""
MAKE-ENCRYPTED-MESSAGE: does [
    ENCRYPTED-MESSAGE: copy ""
    ENCRYPT-CLIPBOARD
    append ENCRYPTED-MESSAGE rejoin [
        "---Start of message---"
        newline
    ]
    append ENCRYPTED-MESSAGE read clipboard://
    append ENCRYPTED-MESSAGE rejoin [
        newline
        "---End of message---"
    ]
    write/binary clipboard:// ENCRYPTED-MESSAGE
    alert "Message ready to be pasted to destination"
] 

;; [---------------------------------------------------------------------------]
;; [ The following function is used to decrypt a message encrypted with the    ]
;; [ above function.                                                           ]
;; [ The above function produces printable data that looks generally like      ]
;; [ this:                                                                     ]
;; [     64#{                                                                  ]
;; [     ...bunch of characters on many lines...                               ]
;; [     }                                                                     ]
;; [ The part that is expected on the clipboard for this function is the       ]
;; [ part from the 64# through the ending brace that is on the line by         ]
;; [ itself.  All of that data, from the 64# through (meaning including) the   ]
;; [ ending brace must be present, or the decryption will fail.                ]
;; [ The result of the procedure is that the decrypted data, now a string,     ]
;; [ will be displayed in the display area of the main window.                 ]
;; [---------------------------------------------------------------------------] 

DECRYPTED-MESSAGE: ""
MAKE-DECRYPTED-MESSAGE: does [
    DECRYPTED-MESSAGE: copy ""
    DECRYPT-CLIPBOARD
    DECRYPTED-MESSAGE: read clipboard://
    MAIN-LIST/text: DECRYPTED-MESSAGE
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
;; [ This function asks for a file name and then saves the text in the         ]
;; [ display window in a file with that name.                                  ]
;; [---------------------------------------------------------------------------]

SAVE-FILE-ID: none
SAVE-DISPLAY-WINDOW: does [
    either SAVE-FILE-ID: request-file/only/save [
        write SAVE-FILE-ID MAIN-LIST/text 
        alert "Text saved"
    ] [
        alert "No file name specified"
        exit
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function is called by the "Quit" button.                             ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This is the program's main window.                                        ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    space 5x5
    across
    banner "Message encrypter/decrypter"
    return
    space 0
    MAIN-LIST: area 600x600 wrap 
    MAIN-LIST-SCROLLER: scroller 20x600
        [SCROLL-TEXT MAIN-LIST MAIN-LIST-SCROLLER] 
    pad 0x20
    space 10x10
    return
    button 600 "Create encrypted message from clipboard" [MAKE-ENCRYPTED-MESSAGE]
    return
    button 600 "Decrypt contents of clipboard and show in above window" [MAKE-DECRYPTED-MESSAGE]
    return
    button 600 "Save display window as text file" [SAVE-DISPLAY-WINDOW]
    return
    button "Quit" [QUIT-BUTTON]
] 

;; [---------------------------------------------------------------------------]
;; [ Display the main window and respond to buttons.                           ]
;; [---------------------------------------------------------------------------]

view center-face MAIN-WINDOW 


