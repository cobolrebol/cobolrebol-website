REBOL [
    Title: "Secure Encrypted List Maintenance Assistant"
]

;; [--------------------------------------------------------------------------]
;; [ This is a one-time program to encrypt the file.                          ]
;; [ The prefix MPW is an arifact of the original use, and stands for         ]
;; [ Master Password List.                                                    ]
;; [--------------------------------------------------------------------------]

;; [--------------------------------------------------------------------------]
;; [ This encryption key was obtained with this command:                      ]
;; [ MPW-ENCRYPTION-KEY: copy/part checksum/secure "OrangeJuice" 16           ]
;; [--------------------------------------------------------------------------]

MPW-ENCRYPTION-KEY: #{2937B848C4670572DC392CC958C68F0D}

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

MPW-ENCRYPT-FILE: func [
    DECRYPTED-FILE 
    ENCRYPTED-FILE
] [
    open MPW-ENCRYPTION-PORT
    insert MPW-ENCRYPTION-PORT read/binary DECRYPTED-FILE 
    update MPW-ENCRYPTION-PORT
    write/binary ENCRYPTED-FILE copy MPW-ENCRYPTION-PORT
    close MPW-ENCRYPTION-PORT
]

MPW-DECRYPT-FILE: func [
    ENCRYPTED-FILE 
    DECRYPTED-FILE
] [
    open MPW-DECRYPTION-PORT
    insert MPW-DECRYPTION-PORT read/binary DECRYPTED-FILE 
    update MPW-DECRYPTION-PORT
    write/binary DECRYPTED-FILE copy MPW-DECRYPTION-PORT
    close MPW-DECRYPTION-PORT
]

MPW-ENCRYPT-FILE %MPW.txt %MPW.enc

alert "File encrypted" 





