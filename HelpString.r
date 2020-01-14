REBOL [
    Title: "Function help as string"
    Purpose: {This is the REBOL 'help function source code, modified so
    that instead of printing the help it puts it into a big string.
    The big string that is returned can be used as desired, perhaps for
    a text area on a window (the original use).  Original lines are
    commented out, and new/replacement lines are marked.
    A better example of this concept can be found here:
    http://reb4.me/x/help.r}
]

;help: func [                                                   ;original
HELPSTRING: func [                                              ;helpstring
    "Prints information about words and values." 
    'word [any-type!] 
    /local value args item type-name refmode types attrs rtype 
     helptext                                                   ;helpstring
][
    helptext: copy ""                                           ;helpstring     
    if unset? get/any 'word [
;       print trim/auto {                                       ;original
; helpstring replacement line:                                  ;helpstring
        append helptext rejoin [ trim/auto {                                       
^-^-^-To use HELP, supply a word or value as its
^-^-^-argument:
^-^-^-
^-^-^-^-help insert
^-^-^-^-help system
^-^-^-^-help system/script

^-^-^-To view all words that match a pattern use a
^-^-^-string or partial word:

^-^-^-^-help "path"
^-^-^-^-help to-

^-^-^-To see words with values of a specific datatype:

^-^-^-^-help native!
^-^-^-^-help datatype!

^-^-^-Word completion:

^-^-^-^-The command line can perform word
^-^-^-^-completion. Type a few chars and press TAB
^-^-^-^-to complete the word. If nothing happens,
^-^-^-^-there may be more than one word that
^-^-^-^-matches. Press TAB again to see choices.

^-^-^-^-Local filenames can also be completed.
^-^-^-^-Begin the filename with a %.

^-^-^-Other useful functions:

^-^-^-^-about - see general product info
^-^-^-^-usage - view program options
^-^-^-^-license - show terms of user license
^-^-^-^-source func - view source of a function
^-^-^-^-upgrade - updates your copy of REBOL
^-^-^-
^-^-^-More information: http://www.rebol.com/docs.html
^-^-} 
        newline                                                 ;helpstring
        ]                                                       ;helpstring
;       exit                                                    ;original
        return helptext                                         ;helpstring
    ] 
    if all [word? :word not value? :word] [word: mold :word] 
    if any [string? :word all [word? :word datatype? get :word]] [
        types: dump-obj/match system/words :word 
        sort types 
        if not empty? types [
;           print ["Found these words:" newline types]          ;original
            append helptext rejoin [
                "Found these words: "                           ;helpstring
                newline                                         ;helpstring
                types                                           ;helpstring
                newline                                         ;helpstring
            ]
;           exit                                                ;original
            return helptext                                     ;helpstring
        ] 
;       print ["No information on" word "(word has no value)"]  ;original
        append helptext rejoin [                                ;helpstring
            "No information on "                                ;helpstring
            word                                                ;helpstring
            " (word has no value)"                              ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
;       exit                                                    ;original
        return helptext                                         ;helpstring
    ] 
    type-name: func [value] [
        value: mold type? :value 
        clear back tail value 
        join either find "aeiou" first value ["an "] ["a "] value
    ] 
    if not any [word? :word path? :word] [
;       print [mold :word "is" type-name :word]                 ;original
        append helptext rejoin [                                ;helpstring
            mold :word                                          ;helpstring
            " is "                                              ;helpstring
            type-name :word                                     ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
;       exit                                                    ;original
        return helptext                                         ;helpstring
    ] 
    value: either path? :word [first reduce reduce [word]] [get :word] 
    if not any-function? :value [
;       prin [uppercase mold word "is" type-name :value "of value: "] ;original
        append helptext rejoin [                                ;helpstring
            uppercase mold word                                 :helpstring
            word                                                ;helpstring
            " is "                                              ;helpstring
            type-name :value                                    ;helpstring
            " of value: "                                       ;helpstring
        ]
;       print either object? value [print "" dump-obj value] [mold :value] ;original
        either object? value [                                  ;helpstring
            append helptext rejoin [                            ;helpstring
                newline                                         ;helpstring
                dump-obj value                                  ;helpstring
                newline                                         ;helpstring
            ]                                                   ;helpstring
        ] [                                                     ;helpstring
            append helptext rejoin [                            ;helpstring
                mold :value                                     ;helpstring
                newline                                         ;helpstring
            ]                                                   ;helpstring
        ]                                                       ;helpstring 
;       exit                                                    ;original
        return helptext                                         ;helpstring
    ] 
    args: third :value 
;   prin "USAGE:^/^-"                                           ;original
    append helptext rejoin [                                    ;helpstring
        "USAGE:^/^-"                                            ;helpstring
    ]                                                           ;helpstring
;   if not op? :value [prin append uppercase mold word " "]     ;original
    if not op? :value [                                         ;helpstring
        append helptext rejoin [                                ;helpstring
            append uppercase mold word " "                      ;helpstring
        ]                                                       ;helpstring
    ]                                                           ;helpstring
    while [not tail? args] [
        item: first args 
        if :item = /local [break] 
        if any [all [any-word? :item not set-word? :item] refinement? :item] [
;           prin append mold :item " "                          :original
            append helptext rejoin [                            ;helpstring
                append mold :item " "                           ;helpstring
            ]                                                   ;helpstring 
;           if op? :value [prin append uppercase mold word " " value: none] ;original
            if op? :value [                                     ;helpstring
                append helptext rejoin [                        ;helpstring
                    append uppercase mold word " "              ;helpstring
                    value: none                                 ;helpstring
                ]                                               ;helpstring
            ]                                                   ;helpstring
        ] 
        args: next args
    ] 
;   print ""                                                    :original
    append helptext newline                                     ;helpstring
    args: head args 
    value: get word 
;   print "^/DESCRIPTION:"                                      ;helpstring
    append helptext rejoin [                                    ;helpstring     
        "^/DESCRIPTION:"                                        ;helpstring
        newline                                                 ;helpstring
    ]                                                           ;helpstring
    either string? pick args 1 [
;       print [tab first args]                                  ;original
        append helptext rejoin [                                ;helpstring 
            tab                                                 ;helpstring
            first args                                          ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
        args: next args
    ] [
;       print "^-(undocumented)"                                ;original
        append helptext rejoin [                                ;helpstring
            "^-(undocumented)"                                  ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
    ] 
;   print [tab uppercase mold word "is" type-name :value "value."] ;original
    append helptext rejoin [                                    ;helpstring
        tab                                                     ;helpstring
        uppercase mold word                                     ;helpstring
        " is "                                                  ;helpstring
        type-name :value                                        ;helpstring
        "value."                                                ;helpstring
        newline                                                 ;helpstring
    ]                                                           ;helpstring
    if block? pick args 1 [
        attrs: first args 
        args: next args
    ] 
;   if tail? args [exit]                                        ;original
    if tail? args [return helptext] 
    while [not tail? args] [
        item: first args 
        args: next args 
        if :item = /local [break] 
        either not refinement? :item [
            all [set-word? :item :item = to-set-word 'return block? first args rtype: first args] 
            if none? refmode [
;               print "^/ARGUMENTS:"                            ;original
                append helptext rejoin [                        ;helpstring
                    "^/ARGUMENTS:"                              ;helpstring
                    newline                                     ;helpstring
                ]                                               ;helpstring
                refmode: 'args
            ]
        ] [
            if refmode <> 'refs [
;               print "^/REFINEMENTS:"                          ;original
                append helptext rejoin [                        ;helpstring
                    "^/REFINEMENTS:"                            ;helpstring 
                    newline                                     ;helpstring
                ]                                               ;helpstring
                refmode: 'refs
            ]
        ] 
        either refinement? :item [
;           prin [tab mold item]                                ;original
            append helptext rejoin [                            ;helpstring
                tab                                             ;helpstring
                mold item                                       ;helpstring
            ]                                                   ;helpstring
;           if string? pick args 1 [prin [" --" first args] args: next args] ;original
            if string? pick args 1 [
                append helptext rejoin [
                    " -- "
                    first args
                ]
                args: next args
            ]
;           print ""                                            ;original
            append helptext newline                             ;helpstring
        ] [
            if all [any-word? :item not set-word? :item] [
;               if refmode = 'refs [prin tab]                   ;original
                if refmode = 'refs [append helptext tab]        ;helpstring 
;               prin [tab :item "-- "]                          ;original
                append helptext rejoin [                        ;helpstring
                    tab                                         ;helpstring
                    :item                                       ;helpstring
                    " -- "                                      ;helpstring
                ]                                               ;helpstring
                types: if block? pick args 1 [args: next args first back args] 
;               if string? pick args 1 [prin [first args ""] args: next args] ;original
                if string? pick args 1 [
                    append helptext rejoin [
                        first args
                        " "
                    ]
                    args: next args
                ]
                if not types [types: 'any] 
;               prin rejoin ["(Type: " types ")"]               ;original
                append helptext rejoin ["(Type: " types ")"]    ;helpstring 
;               print ""                                        ;original
                append helptext newline                         ;helpstring
            ]
        ]
    ] 
;   if rtype [print ["^/RETURNS:^/^-" rtype]]                   ;original
    if rtype [                                                  ;helpstring
        append helptext rejoin[                                 ;helpstring
            "^/RETURNS:^/^- "                                   ;helpstring
            rtype                                               ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
    ]                                                           ;helpstring
    if attrs [
;       print "^/(SPECIAL ATTRIBUTES)"                          ;original
        append helptext rejoin [                                ;helpstring
            "^/(SPECIAL ATTRIBUTES)"                            ;helpstring
            newline                                             ;helpstring
        ]                                                       ;helpstring
        while [not tail? attrs] [
            value: first attrs 
            attrs: next attrs 
            if any-word? value [
;               prin [tab value]                                ;original
                append helptext rejoin [tab value]              ;helpstring
                if string? pick attrs 1 [
;                   prin [" -- " first attrs]                   ;original
                    append helptext rejoin [" -- " first attrs] ;helpstring
                    attrs: next attrs
                ] 
;               print ""                                        ;original
                append helptext newline                         ;helpstring
            ]
        ]
    ] 
;   exit                                                        ;original
    return helptext                                             ;helpstring
]

;;Uncomment to test
;print "-------------------------------------"
;print HELPSTRING help
;print "-------------------------------------"
;print HELPSTRING print
;print "-------------------------------------"
;print HELPSTRING append
;print "-------------------------------------"
;print HELPSTRING help
;print "-------------------------------------"
;halt

