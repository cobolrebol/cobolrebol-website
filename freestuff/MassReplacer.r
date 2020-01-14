REBOL [
    Title: "Mass replacer"
    Purpose: {Find and replace multiple items in a text file.}
]

;; [---------------------------------------------------------------------------]
;; [ Normally, finding and replacing text in a text file is done handily       ]
;; [ with a text editor.  However, there can be times when it is a bit         ]
;; [ difficult, for example, if the find/replace strings are long and they     ]
;; [ must be applied to several files.  In such a case, a dedicated program    ]
;; [ might be helpful.                                                         ]
;; [ This program uses a file of find/replace items in the following format:   ]
;; [ " <find-text-1> " " <replace-text-1> "                                    ]
;; [ " <find-text-2> " " <replace-text-2> "                                    ]
;; [ ...                                                                       ]
;; [ " <find-text-n> " " <replace-text-n> "                                    ]
;; [ It asks for the name of this file, plus the name of a file to modify,     ]
;; [ and applies all those find/replace changes to the specified file.         ]
;; [---------------------------------------------------------------------------]

alert "MAKE A COPY OF THE FILE YOU ARE ABOUT TO MODIFY!"

alert "First we need the name of the file to modify."

if not MODFILE: request-file/only [
    alert "No file specified."
    quit
]

alert "Next we need a file of items to change."

if not CHGFILE: request-file/only [
    alert "No file specified."
    quit
]

MODTEXT: read/binary MODFILE

CHGITEMS: load CHGFILE 

foreach [FINDITEM REPLACEITEM] CHGITEMS [
    replace/all MODTEXT FINDITEM REPLACEITEM
]

write/binary MODFILE MODTEXT

alert "Done."

