REBOL [
    Title: "Run the whois.exe command and parse its output"
    Purpose: {Use powershell and a whois.exe program to make a 
    whois request and parse its output for useful items.}
]

;; [---------------------------------------------------------------------------]
;; [ This is a function created when the built-in REBOL whois operation        ]
;; [ was not producing results.  It uses powershell and a whois.exe            ]
;; [ program downloaded from Microsoft to get a whois output, put it into      ]
;; [ a text file, and try to extract useful information from it.               ]
;; [                                                                           ]
;; [ The input to the function is an IP address.                               ]
;; [ The output will be a block of strings, each string being some item of     ]
;; [ interest.  Look at the code to see what those strings are, because        ]
;; [ you could modify it as desired depending on what you want to extract      ]
;; [ from the whois output.                                                    ]
;; [                                                                           ]
;; [ If you want to use this, you will have to do two things.                  ]
;; [ You will have to allow powershell scripts to run.  This is done by        ]
;; [ starting powershell (start, programs, accessories, powershell) and        ]
;; [ enter: set-executionpolicy remotesigned.                                  ]
;; [ You also will have to obtain a whois program, which at one time           ]
;; [ could be found here:                                                      ]
;; [ https://technet.microsoft.com/en-us/sysinternals/whois.aspx               ]
;; [---------------------------------------------------------------------------]

WHOISOUTPUT: %whoisresult.txt   ;; Modify for your own use

WHOIS-LOOKUP: func [
    IPADDRESS                   ;; in IP address
    /local
        CMD                     ;; powershell command we will build
        WHOISDATA               ;; whois seems to return unicode
        ASCII                   ;; WHOISDATA converted to ascii as best we can
        TIMEOUT                 ;; timeout interval for waiting for whois
        TIMER                   ;; timer for waiting
        INTERVAL                ;; amount of time to wait for whois
        OUTPUTAVAILABLE         ;; whois result ready for reading
        REGISTRANT-NAME         ;; extracted from result
        REGISTRANT-ORGANIZATION ;; extracted from result
        WHOISFIELDS             ;; data items extracted from whois result
] [
;; -- Try to remove the output from any previous call.
;; -- Sometimes we can remove this file, and sometimes not.
;; -- Could it be a timing issue?
    wait 00:00:05
    if not attempt [delete WHOISOUTPUT] [
        wait 00:00:05
        attempt [delete WHOISOUTPUT]
    ]
;; -- Use powershell to run whois to put results into a text file.
    CMD: rejoin [
        {powershell -command "whois }
        IPADDRESS
        { | out-file }
        to-string WHOISOUTPUT
        {"}
    ]
    call CMD
;; -- Wait for the results of whois, within reason.
    TIMEOUT: 00:00:10
    TIMER: 00:00:00
    INTERVAL: 00:00:01
    forever [
        either exists? WHOISOUTPUT [
            OUTPUTAVAILABLE: true
            break
        ] [
            TIMER: TIMER + INTERVAL 
            wait INTERVAL
            if TIMER > TIMEOUT [
                OUTPUTAVAILABLE: false 
                break       
            ]
        ]
    ] 
;; -- Process the whois result if it is available.
;; -- The output of our whois program seems to be some sort of unicode.
    REGISTRANT-NAME: copy ""
    REGISTRANT-ORGANIZATION: copy ""
    if OUTPUTAVAILABLE [
        WHOISDATA: read/binary WHOISOUTPUT
        ASCII: copy ""
        foreach X WHOISDATA [
            if (X > 08) and (X < 128) [
                append ASCII to-char X 
            ]
        ]
        WS-REGISTRANT: copy ""
        parse/case ASCII [
            thru "Registrant Name:" copy REGISTRANT-NAME to "^M^/"
            thru "Registrant Organization:" copy REGISTRANT-ORGANIZATION to "^M^/"
        ]
    ] 
;; -- Assemble and return the output block
    WHOISFIELDS: copy []
    append WHOISFIELDS trim/head REGISTRANT-NAME
    append WHOISFIELDS trim/head REGISTRANT-ORGANIZATION    
    return WHOISFIELDS
]

;; Uncomment to test
;WHOISRESULT: WHOIS-LOOKUP "206.108.214.98"
;print ["Registrant Name: " WHOISRESULT/1]
;print ["Registrant Organization: " WHOISRESULT/2]
;WHOISRESULT: WHOIS-LOOKUP "96.87.132.254"
;print ["Registrant Name: " WHOISRESULT/1]
;print ["Registrant Organization: " WHOISRESULT/2]
;halt

 
