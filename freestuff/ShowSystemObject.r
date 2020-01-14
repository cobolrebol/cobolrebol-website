REBOL [
    Title: "Show system object words"
    Purpose: {Make a quick reference of common words from the
    system object.}
]

;; [---------------------------------------------------------------------------]
;; [ This program find common items in the system object, puts them into a     ]
;; [ list, and displays them.  It was written for quick reference.             ]
;; [ It works by brute force, rather than any clever trick to find all the     ]
;; [ system object items.                                                      ]
;; [ Note that this is not all the items in the system object; is is the ones  ]
;; [ the author has found useful.  To get a complete list, run REBOL, go to    ]
;; [ the command prompt, and enter "help system."  That shows the top level,   ]
;; [ and you could begin investigating from there.                             ]
;; [ Some items are included here not because they would be used often or      ]
;; [ at all, but because having them on the list saves the time of running     ]
;; [ the interpreter to remember them.                                         ]
;; [ A more comprehensive program can be found here:                           ]
;; [ http://www.rebol.org/view-script.r?script=prob.r                          ]
;; [ Read it if you dare.  It is REBOL at its finest.                          ]
;; [---------------------------------------------------------------------------]

SYSOBJ-LIST-DATA: copy []
SYSOBJ-ITEM: []

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/product"
append SYSOBJ-ITEM to-string system/product
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

;; ---------------------------------------------------------------------

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/user/name"
append SYSOBJ-ITEM to-string system/user/name
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/user/email"
append SYSOBJ-ITEM to-string system/user/email
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

;; ---------------------------------------------------------------------

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/network/host"
append SYSOBJ-ITEM to-string system/network/host
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/network/host-address"
append SYSOBJ-ITEM to-string system/network/host-address
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

;; ---------------------------------------------------------------------

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/home"
append SYSOBJ-ITEM to-string system/options/home
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/script"
append SYSOBJ-ITEM to-string system/options/script
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/path"
append SYSOBJ-ITEM to-string system/options/path
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/boot"
append SYSOBJ-ITEM to-string system/options/boot
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/args"
append SYSOBJ-ITEM to-string system/options/args
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/binary-base"
append SYSOBJ-ITEM to-string system/options/binary-base
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

;; ---------------------------------------------------------------------

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/server-software"
append SYSOBJ-ITEM to-string system/options/cgi/server-software
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/server-name"
append SYSOBJ-ITEM to-string system/options/cgi/server-name 
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/gateway-interface"
append SYSOBJ-ITEM to-string system/options/cgi/gateway-interface
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/server-protocol"
append SYSOBJ-ITEM to-string system/options/cgi/server-protocol
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/server-port"
append SYSOBJ-ITEM to-string system/options/cgi/server-port
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/request-method"
append SYSOBJ-ITEM to-string system/options/cgi/request-method
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/path-info"
append SYSOBJ-ITEM to-string system/options/cgi/path-info
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/path-translated"
append SYSOBJ-ITEM to-string system/options/cgi/path-translated
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/script-name"
append SYSOBJ-ITEM to-string system/options/cgi/script-name
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/query-string"
append SYSOBJ-ITEM to-string system/options/cgi/query-string
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/remote-host"
append SYSOBJ-ITEM to-string system/options/cgi/remote-host
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/remote-addr"
append SYSOBJ-ITEM to-string system/options/cgi/remote-addr
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/auth-type"
append SYSOBJ-ITEM to-string system/options/cgi/auth-type
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/remote-user"
append SYSOBJ-ITEM to-string system/options/cgi/remote-user
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/remote-ident"
append SYSOBJ-ITEM to-string system/options/cgi/remote-ident
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/content-type"
append SYSOBJ-ITEM to-string system/options/cgi/content-type
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

SYSOBJ-ITEM: copy []
append SYSOBJ-ITEM "system/options/cgi/content-length"
append SYSOBJ-ITEM to-string system/options/cgi/content-length
append/only SYSOBJ-LIST-DATA SYSOBJ-ITEM

;; ---------------------------------------------------------------------

STARTING-ROW: 0 

MAIN-WINDOW: layout [
    across
    banner "Useful system object items"
    return 
    MAIN-LIST: list 600x400 [
        across
        text 300 font [style: 'bold]
        text 300 font [style: 'bold]
    ]
    supply [
        count: count + STARTING-ROW
        if none? PICKED-ROW: pick SYSOBJ-LIST-DATA count [face/text: none exit]
        face/text: pick PICKED-ROW index
    ]
    scroller 20x400 [
        STARTING-ROW: (length? SYSOBJ-LIST-DATA) * value
        show MAIN-LIST
    ]
    return 
    button "Quit" [quit]
]

view center-face MAIN-WINDOW 

