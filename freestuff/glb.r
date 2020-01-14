TITLE
Global services module

SUMMARY
This is a file of functions that are so common that practically every
other script will use them.

DOCUMENTATION
Include this module in your program as follows:

do %glb.r

Then use the procedures as necessary.  The services available are:

GLB-NOW:  This is a word that references the date and time your program
started running.

GLB-YYYYMMDD:  This is a string containing the current date in yyyymmdd
format.

GLB-MMDDYY:  This is a string containing the current date in mmddyy format.

GLB-HHMMSS:  This is the current time in hhmmss format.  This, and the above
two dates, can be useful for date-time stamps.

GLB-SUBSTRING input-string start-position end-position
This is a function that returns a substring of the string provided as input.
Along with the input string, provide a starting position and an ending
position.  If the ending position is -1, the procedure will return a substring
to the end of the input string.  It actually is not much more complicated to
use regular commands to do this operation. I just can't remember how.

GLB-BASE-FILENAME input-file-name
This procedure accepts a file name (a string or a file name) as a parameter
and returns everything except the "extension" which is the stuff after a
dot.  The procedure assumes it is getting a name in the common format of
a bunch of stuff, a single dot, and the a short extension like txt, html, 
and so on.  The purpose of this procedure is to get that base name so that
you can add your own extension.

GLB-FILLER number-of-spaces
This procedure returns a string that is all spaces, with a length equal to
the number-of-spaces parameter supplied to the procedure.  The original use
of this procedure was for building up fixed-length lines.

GLB-ZEROFILL input-string final-size
This is a procedure that was created for taking any input number and
creating a fixed-length number with an assumed decimal point.  In other
words, it strips out every character except the digits, and pads it on the
left with leading zeros.  This makes a "cobol-like" number out of a
"display-like" number.

GLB-INSERT-DECIMAL input-string decimal-places
This is a procedure to fix up a string of digits with a decimal point
inserted a desired number of places from the right end.  This procedure
exists because decimal numbers in REBOL don't always print nicely, so it
seems; sometimes they come out in "scientific notation."
Call the procedure with a string of digits and a desired number of
decimal places, and the procedure will return that string with a decimal
point inserted.  If the input string is shorter than the desired number
of decimal places, it will be padded with leading zeros.

GLB-SPACEFILL input-string final-size
This procedure accepts a string and trims the leading spaces, and pads it
with trailing spaces out to the indicated length.  It was created for making
fixed-format lines.

GLB-TRACE-EMIT block-of-anything
This procedre accepts a block of anything that the caller might want to
put into a trace file.  The procedure will reduce the block and add a
sequence number, and then store it in a larger block.  This larger block
will eventually contain only the last 100 items added to it, since after
each call the procedure chops off the oldest entry (if there are more 
than 100).  This procedure is mainly a debugging tool.  If your script
crashes somewhere, start tracing at some appropriate point, get the 
script to halt, and then examine what you have traced.

GLB-TRACE-PRINT
This procedure will display the contents of the trace block you built up with
repeated calls of GLB-TRACE-EMIT.

GLB-TRACE-SAVE
This procedure will convert the trace block to a series of text lines and 
save it in a file.  The file has a default name which you may change by
change the value of GLB-TRACE-FILE-ID.

GLB-LOG-EMIT log-file-name logging-data
This procedure, copied from the rebol cookbook, accepts a file name and
a string or block of anything, and adds that anything to the end of the
indicated file.  The purpose of this procedure is to write to any specified
log file.

GLB-LIFOLOG-EMIT log-file-name logging-data
This procedure is very similar to GLB-LOG-EMIT except that it puts the
data line at the front of the file instead of at the end.  It can be
used in situations where you want to read a log sequentially but want
the most recent items to show up at the top.

GLB-PAUSE pause-prompt
This procedure will cause your script to stop, display the pause-prompt, and
wait for you to type something.  At this point, you should some rebol command
which the procedure will try to execute.  Normally, that would be some command
to view the values of words in your script, in an attempt to track down a bug.

GLB-COPY-DIR source-dir/ destination-dir/
This procedure recursively copies the source-dir to the destination-dir.

GLB-IS-NUMERIC number-string
This procedure expects a string and returns a true or false if the number
is or is not all digits.  This is like the COBOL NUMERIC test.

GLB-IS-ALPHABETIC letter-string
This procedure expects a string and returns a true or false if the string
is or is not all letters.  This is like the COBOL ALPHABETIC test.

GLB-CHECK-MMDDYYYY mm/dd/yyyy-date-string
This procedure is a very restrictive date editing procedure.
It expects a date in mm/dd/yyyy format, with slashes, and returns true
or false if the date is or is not in exactly that format.
The procedure was created for checking dates entered in forms.
It also loads text error messages in GLB-CHECK-MMDDYYYY-MSG.

GLB-EDIT-X input-string edit-mask
This procedure does a COBOL-like editing of a string, using a
COBOL-like edit picture.  For example, editing a social security number
could look like this:
GLB-EDIT-X "111223333" "XXX-XX-XXXX"
would produce "111-22-3333".
The function starts with the mask and for each "X" emits the next
characer in line from the input string, or, of the mask character is
not "X", emits the mask character.
The function was written with the assumption that the caller would
know what he is doing and not supply junk data or a junk mask.

SCRIPT
REBOL [
    Title:  "COB global services module"
]

;; [---------------------------------------------------------------------------]
;; [ This is a file of global definitions that will be loaded                  ]
;; [ as the very first thing in a REBOL script.                                ]
;; [ This is done with:                                                        ]
;; [     do %glb.r                                                             ]
;; [ If this file is in its regular location, the above line will              ]
;; [ be:                                                                       ]
;; [     do %/L/COB_REBOL_modules/glb.r                                        ]
;; [---------------------------------------------------------------------------] 

;; [---------------------------------------------------------------------------]
;; [ Get the current date and time from the OS and format it in                ]
;; [ some assorted ways that we have found useful.                             ]
;; [ The method of getting a two-digit month or day might seem a               ]
;; [ bit obscure.  Take the month/day, add a zero to be sure it is             ]
;; [ at least two digits, reverse it, pick off two digits, and                 ]
;; [ reverse it again.  We store YYYYMMDD as a string because                  ]
;; [ it usually is used in a file name.                                        ]
;; [---------------------------------------------------------------------------]

GLB-NOW: now
GLB-YYYYMMDD: to-string rejoin [
    GLB-NOW/year
    reverse copy/part reverse join 0 GLB-NOW/month 2
    reverse copy/part reverse join 0 GLB-NOW/day 2
]
GLB-MMDDYY: to-string rejoin [
    reverse copy/part reverse join 0 GLB-NOW/month 2
    reverse copy/part reverse join 0 GLB-NOW/day 2
    reverse copy/part reverse to-string GLB-NOW/year 2
]

;; [---------------------------------------------------------------------------]
;; [ LIke the above procedure, get a yyyymmdd date, but refresh the date       ]
;; [ with each call.                                                           ]
;; [---------------------------------------------------------------------------]

GLB-DATESTAMP: does [
    GLB-TEMP-DATE: now
    GLB-TEMP-YYYYMMDD: to-string rejoin [
        GLB-TEMP-DATE/year
        reverse copy/part reverse join 0 GLB-TEMP-DATE/month 2
        reverse copy/part reverse join 0 GLB-TEMP-DATE/day 2
    ]
    return GLB-TEMP-YYYYMMDD
]

;; [---------------------------------------------------------------------------]
;; [ LIke the above procedure, but get a date of the operator-s choosing.      ]
;; [---------------------------------------------------------------------------]

GLB-GET-YYYYMMDD: does [
    GLB-TEMP-DATE: request-date
    either GLB-TEMP-DATE [
        GLB-TEMP-YYYYMMDD: to-string rejoin [
            GLB-TEMP-DATE/year
            reverse copy/part reverse join 0 GLB-TEMP-DATE/month 2
            reverse copy/part reverse join 0 GLB-TEMP-DATE/day 2
        ]
    ] [
        GLB-TEMP-YYYYMMDD: "00000000"
    ]
    return GLB-TEMP-YYYYMMDD
]

;; [---------------------------------------------------------------------------]
;; [ Get the current time, strip out the colons, add a leading zero            ]
;; [ if necessary, and return hhmmss.  This can be used for a time             ]
;; [ stamp.                                                                    ]
;; [ Get the time and trim out the colons.                                     ]
;; [ Put a zero on the front end in case one is needed.                        ]
;; [ Reverse the resulting string.                                             ]
;; [ Copy off six characters from the left, which now is the back              ]
;; [ end after the above reversal.                                             ]
;; [ Reverse it again to put the hours on the front.                           ]
;; [---------------------------------------------------------------------------]

GLB-HHMMSS: to-string rejoin [
    reverse copy/part reverse join "0" trim/with to-string now/time ":" 6
]

;; [---------------------------------------------------------------------------]
;; [ This is like the above procedure, but refreshes the time, whereas the     ]
;; [ above procedure gets the time when this module is loaded, and never       ]
;; [ again.                                                                    ]
;; [---------------------------------------------------------------------------]

GLB-TIMESTAMP: does [
    GLB-TEMP-TIME: to-string rejoin [
        reverse copy/part reverse join "0" trim/with to-string now/time ":" 6
    ]
    return GLB-TEMP-TIME
]

;; [---------------------------------------------------------------------------]
;; [ This date variant accepts a REBOL date as an argument and generates       ]
;; [ a string of YYYYMMDDHHMMSS which can be used, for example, as a sort      ]
;; [ key for sorting dates.  REBOL dates can be sorted just fine, but          ]
;; [ because of the format, 01-DEC will sort out before 31-JAN.                ]
;; [ REBOL is very "helpful" with date and time formatting, specifically,      ]
;; [ in the area of suppressing leading zeros or, in the case of a time,       ]
;; [ suppressing the seconds if they are 00.  Sometimes we do not want that.   ]
;; [ The time could be:                                                        ]
;; [     H:MM        length is 3 with colon trimmed                            ]
;; [     H:MM:SS     length is 5 with colon trimmed                            ]
;; [     HH:MM       length is 4 with colon trimmed                            ]
;; [     HH:MM:SS    length is 6 with colon trimmed                            ]
;; [ So, we will try to fix up the time to HHMMSS based on the length          ]
;; [ of what we get to start with.                                             ]
;; [---------------------------------------------------------------------------]

GLB-GEN-YYYYMMDDHHMMSS: func [
    REBOL-DATE
    /local
        GLB-TEMP-YYYYMMDDHHMMSS
        GLB-TEST-TIME
        GLB-TIME-LENGTH
        GLB-TEMP-TIME 
] [
    GLB-TEMP-YYYYMMDDHHMMSS: to-string rejoin [
        REBOL-DATE/year
        reverse copy/part reverse join 0 REBOL-DATE/month 2
        reverse copy/part reverse join 0 REBOL-DATE/day 2
    ]
    either REBOL-DATE/time [   ;; time is none if not present 
        GLB-TEST-TIME: copy trim/with to-string REBOL-DATE/time ":"
        GLB-TIME-LENGTH: length? GLB-TEST-TIME 
        GLB-TEMP-TIME: copy GLB-TEST-TIME  ;; Default case
        if equal? 4 GLB-TIME-LENGTH [
            GLB-TEMP-TIME: rejoin [GLB-TEST-TIME "00"]
        ]
        if equal? 5 GLB-TIME-LENGTH [
            GLB-TEMP-TIME: rejoin ["0" GLB-TEST-TIME]
        ]
        if equal? 3 GLB-TIME-LENGTH [
            GLB-TEMP-TIME: rejoin ["0" GLB-TEST-TIME "00"]
        ]
        append GLB-TEMP-YYYYMMDDHHMMSS GLB-TEMP-TIME 
    ] [
        append GLB-TEMP-YYYYMMDDHHMMSS "000000"
    ]
    return GLB-TEMP-YYYYMMDDHHMMSS
]

;; [---------------------------------------------------------------------------]
;; [ This function accepts a string, a starting position, and an               ]
;; [ ending position, and returns a substring from the starting                ]
;; [ position to the ending position.  If the ending position is -1,           ]
;; [ the procedure returns the substring from the starting position            ]
;; [ to the end of the string.                                                 ]
;; [---------------------------------------------------------------------------]

GLB-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

;; [---------------------------------------------------------------------------]
;; [ This is a function that accepts a file name (string or file)              ]
;; [ and picks off the extension (the dot followed by stuff) and               ]
;; [ returns everything up to the dot.                                         ]
;; [ This can be done in a one-liner, but I have trouble remembering           ]
;; [ that one line, and also had a little trouble making it work               ]
;; [ at one point, so I made this procedure that works all the time.           ]
;; [---------------------------------------------------------------------------]

GLB-BASE-FILENAME: func [
    "Returns a file name without the extension"
    INPUT-STRING [series! file!] "File name"
    /local FILE-STRING REVERSED-NAME REVERSED-BASE BASE-FILENAME
] [
    FILE-STRING: copy ""
    FILE-STRING: to-string INPUT-STRING
    REVERSED-NAME: reverse FILE-STRING
    REVERSED-BASE: copy ""
    REVERSED-BASE: next find REVERSED-NAME "."
    BASE-FILENAME: copy ""
    BASE-FILENAME: reverse REVERSED-BASE
    return BASE-FILENAME
]

;; [---------------------------------------------------------------------------]
;; [ For use in creating fixed-length lines of text (perhaps for               ]
;; [ printing), this function accepts an integer and returns a                 ]
;; [ string of blanks that many blanks long.  This filler can                  ]
;; [ be joined with other strings to space things out to a certain             ]
;; [ number of characters.  This would be useful mainly when                   ]
;; [ printing in a fixed-width font.                                           ]
;; [---------------------------------------------------------------------------]

GLB-FILLER: func [
    "Return a string of a given number of spaces"
    SPACE-COUNT [integer!]
    /local FILLER 
] [
    FILLER: copy ""
    loop SPACE-COUNT [
        append FILLER " "
    ]
    return FILLER
]

;; [---------------------------------------------------------------------------]
;; [ This is a procedure written for converting a number, which                ]
;; [ could be a decimal number, currency, string with commas and               ]
;; [ dollar signs, and so on, into an output string which is just              ]
;; [ the digits, padded on the left with leading zeros out to a                ]
;; [ specified length.  It was written as an aid in creating a                 ]
;; [ fixed-format text file.                                                   ]
;; [ The procedure works in a way that might not be immediatedly               ]
;; [ obvious.  It uses the trim function on a copy of the input                ]
;; [ string to filter OUT everything but digits.  The result of                ]
;; [ this first trimming will be any invalid characters in the                 ]
;; [ input string.  Then it trims the real input string to filter              ]
;; [ out all the non-numeric characters captured in the first                  ]
;; [ trim.  After the procedure gets a trimmed string of digits                ]
;; [ only, it reverses it and adds enough zeros on the right to                ]
;; [ pad it out to the desired length.  Then it reverses the                   ]
;; [ result again to get the extra zeros on the left and returns               ]
;; [ this final result to the caller.                                          ]
;; [---------------------------------------------------------------------------]

GLB-ZEROFILL: func [
    "Convert number to string, pad with leading zeros"
    INPUT-STRING
    FINAL-LENGTH
    /local ALL-DIGITS 
           LENGTH-OF-ALL-DIGITS
           NUMER-OF-ZEROS-TO-ADD
           REVERSED-DIGITS 
           FINAL-PADDED-NUMBER
] [
    ALL-DIGITS: copy ""
    ALL-DIGITS: trim/with to-string INPUT-STRING trim/with 
        copy to-string INPUT-STRING "0123456789"
    LENGTH-OF-ALL-DIGITS: length? ALL-DIGITS
    if (LENGTH-OF-ALL-DIGITS <= FINAL-LENGTH) [
        NUMBER-OF-ZEROS-TO-ADD: (FINAL-LENGTH - LENGTH-OF-ALL-DIGITS)
        REVERSED-DIGITS: copy ""
        REVERSED-DIGITS: reverse ALL-DIGITS    
        loop NUMBER-OF-ZEROS-TO-ADD [
            append REVERSED-DIGITS "0"
        ]
        FINAL-PADDED-NUMBER: copy ""
        FINAL-PADDED-NUMBER: copy/part reverse REVERSED-DIGITS FINAL-LENGTH
    ]
    return FINAL-PADDED-NUMBER
]

;; [---------------------------------------------------------------------------]
;; [ This is a procedure written to create a displayable decimal number.       ]
;; [ It seems that, in REBOL, in certain situations, a decimal number gets     ]
;; [ displayed in "scientific notation" rather than in a human-friendly way    ]
;; [ of a bunch of digits and a decimal point.  This procedure takes a string  ]
;; [ of any characters (normally one would use digits), plus a number that     ]
;; [ represents a desired number of decimal places, and inserts a decimal      ]
;; [ point into the string such that it shows the desired number of decimal    ]
;; [ places.  So, if you supplied "123456789" and a three (3), you would       ]
;; [ get "123456.789" as a result.                                             ]
;; [---------------------------------------------------------------------------]

GLB-INSERT-DECIMAL: func [
    "Insert a decimal point into a string of digits"
    INPUT-STRING
    DECIMAL-PLACES
    /local FINAL-DECIMAL-NUMBER
           NUMBER-OF-ZEROS-TO-ADD
           REVERSED-INPUT
           LENGTH-OF-INPUT
] [
    REVERSED-INPUT: copy ""
    REVERSED-INPUT: reverse to-string INPUT-STRING
    LENGTH-OF-INPUT: length? REVERSED-INPUT
    if (DECIMAL-PLACES > LENGTH-OF-INPUT) [
        NUMBER-OF-ZEROS-TO-ADD: (DECIMAL-PLACES - LENGTH-OF-INPUT)
        loop NUMBER-OF-ZEROS-TO-ADD [
            append REVERSED-INPUT "0"
        ]
    ]
;;  -- REVERSED-INPUT now is long enough for inserting a decimal point
    REVERSED-INPUT: head REVERSED-INPUT
;;  REVERSED-INPUT: at REVERSED-INPUT DECIMAL-PLACES
    REVERSED-INPUT: skip REVERSED-INPUT DECIMAL-PLACES
    insert REVERSED-INPUT "."
    REVERSED-INPUT: head REVERSED-INPUT
    FINAL-DECIMAL-NUMBER: reverse REVERSED-INPUT
]    

;; [---------------------------------------------------------------------------]
;; [ This is a function to take a string, and a length, and pad the            ]
;; [ string with trailing spaces.  It also, as a byproduct, trims off          ]
;; [ leading spaces based on the idea that this opertion would be              ]
;; [ the most commonly-wanted.                                                 ]
;; [---------------------------------------------------------------------------]

GLB-SPACEFILL: func [
    "Left justify a string, pad with spaces to specified length"
    INPUT-STRING
    FINAL-LENGTH
    /local TRIMMED-STRING
           LENGTH-OF-TRIMMED-STRING
           NUMBER-OF-SPACES-TO-ADD
           FINAL-PADDED-STRING
] [
    TRIMMED-STRING: copy ""
    TRIMMED-STRING: trim INPUT-STRING
    LENGTH-OF-TRIMMED-STRING: length? TRIMMED-STRING
    either (LENGTH-OF-TRIMMED-STRING < FINAL-LENGTH) [
        NUMBER-OF-SPACES-TO-ADD: (FINAL-LENGTH - LENGTH-OF-TRIMMED-STRING)
        FINAL-PADDED-STRING: copy TRIMMED-STRING
        loop NUMBER-OF-SPACES-TO-ADD [
            append FINAL-PADDED-STRING " "
        ]
    ] [
        FINAL-PADDED-STRING: COPY ""
        FINAL-PADDED-STRING: GLB-SUBSTRING TRIMMED-STRING 1 FINAL-LENGTH
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function is similar to GLB-SPACEFILL except that it adds             ]
;; [ spaces to the left and returns a string of a specified size.              ]
;; [ This procedure could be used to, in effect, right-justify a number        ]
;; [ for printing.  Convert the number to a string and then run it through     ]
;; [ this function to get it right-justified inside a string of a specified    ]
;; [ length.                                                                   ]
;; [---------------------------------------------------------------------------]

GLB-SPACEFILL-LEFT: func [
    "Right justify a string, pad with spaces to specified length"
    INPUT-STRING
    FINAL-LENGTH
    /local TRIMMED-STRING
           LENGTH-OF-TRIMMED-STRING
           NUMBER-OF-SPACES-TO-ADD
           FINAL-PADDED-STRING
] [
    TRIMMED-STRING: copy ""
    TRIMMED-STRING: trim INPUT-STRING
    LENGTH-OF-TRIMMED-STRING: length? TRIMMED-STRING
    either (LENGTH-OF-TRIMMED-STRING < FINAL-LENGTH) [
        NUMBER-OF-SPACES-TO-ADD: (FINAL-LENGTH - LENGTH-OF-TRIMMED-STRING)
        FINAL-PADDED-STRING: copy TRIMMED-STRING
        loop NUMBER-OF-SPACES-TO-ADD [
            insert head FINAL-PADDED-STRING " "
        ]
    ] [
;;      -- Do same as GLB-SPACEFILL for now, maybe cut off left end later
        FINAL-PADDED-STRING: COPY ""
        FINAL-PADDED-STRING: GLB-SUBSTRING TRIMMED-STRING 1 FINAL-LENGTH
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function (and supporting data) to provide a finite              ]
;; [ trace of whatever a caller wants to trace.                                ]
;; [ Trace lines will be stored in a block of numbered entries,                ]
;; [ up to a certain size.  After that certain size is reached,                ]
;; [ the oldest entry will be dropped.                                         ]
;; [ This was created originally as a debugging trace.                         ]
;; [---------------------------------------------------------------------------]

GLB-TRACE: []
GLB-TRACE-SIZE: 100
GLB-TRACE-SEQ: 0
GLB-TRACE-FILE-ID: %glb-trace.txt
GLB-TRACE-FILE-BUFFER: ""
GLB-TRACE-EMIT: func [
    "Emit a submitted line to the finite trace block"
    TRACE-LINE [block!]
] [
    GLB-TRACE-SEQ: GLB-TRACE-SEQ + 1
    insert tail GLB-TRACE reform [GLB-TRACE-SEQ remold TRACE-LINE]
    head GLB-TRACE
    if > GLB-TRACE-SEQ GLB-TRACE-SIZE [
        remove GLB-TRACE
    ]
]
GLB-TRACE-PRINT: does [
    foreach TRACE-LINE GLB-TRACE [
        print TRACE-LINE
    ]
]
GLB-TRACE-SAVE: does [
    GLB-TRACE-FILE-BUFFER: copy ""
    foreach TRACE-LINE GLB-TRACE [
        append GLB-TRACE-FILE-BUFFER TRACE-LINE
        append GLB-TRACE-FILE-BUFFER newline
    ]
    write/lines GLB-TRACE-FILE-ID GLB-TRACE-FILE-BUFFER
]

;; [---------------------------------------------------------------------------]
;; [ This function, copied from the REBOL cookbook, provides a                 ]
;; [ logging file.  Actually, it provides several logging files                ]
;; [ since it is called with a file name as one of the parameters.             ]
;; [ This allows a program to write to any number of log files.                ]
;; [ Because the procedure appends a log line to a file, the file              ]
;; [ will remain if the program crashes.                                       ]
;; [---------------------------------------------------------------------------]

GLB-LOG-LINE: ""
GLB-LOG-EMIT: func [
    FILE-ID
    LOG-DATA
] [
    GLB-LOG-LINE: copy ""
    GLB-LOG-LINE: append trim/lines reform [	  
        rejoin [now/year "-" now/month "-" now/day]
	now/time 
	reform LOG-DATA
    ] newline
    attempt [write/append FILE-ID GLB-LOG-LINE]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is similar to the one above except that it firsts          ]
;; [ reads in the log file, and then inserts the new line at the front         ]
;; [ before writing back the file.                                             ]
;; [ This is for a situation where you might want to display a log file        ]
;; [ sequentially and have the most recent entries at the front.               ]
;; [---------------------------------------------------------------------------]

GLB-LIFOLOG-LINE: ""
GLB-LIFOLOG-EMIT: func [
    FILE-ID
    LOG-DATA
    /local FILE-LINES
] [
    if exists? FILE-ID [
        GLB-LIFOLOG-LINE: copy ""
        GLB-LIFOLOG-LINE: trim/lines reform [now/date now/time reform LOG-DATA] 
        FILE-LINES: read/lines FILE-ID
        insert head FILE-LINES GLB-LIFOLOG-LINE
        write/lines FILE-ID FILE-LINES
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function that can be used to pause a program and allow          ]
;; [ commands to be entered at the pause prompt.                               ]
;; [ To use, call GLB-PAUSE with a string parameter.  The string parameter     ]
;; [ will be displayed as a prompt, and the program will wait for input.       ]
;; [ Enter any REBOL command at the prompt, and the function will try          ]
;; [ to execute it.  To display a data value, just type the word whose         ]
;; [ value you want displayed.  To continue with the program, press the        ]
;; [ "enter" key with no input.                                                ]
;; [---------------------------------------------------------------------------]

GLB-PAUSE: func [GLB-PAUSE-PROMPT /local GLB-PAUSE-INPUT][
  GLB-PAUSE-INPUT: "none"
  while ["" <> trim/lines GLB-PAUSE-INPUT][
  GLB-PAUSE-INPUT: ask join GLB-PAUSE-PROMPT " >> "
  attempt [probe do GLB-PAUSE-INPUT]
  ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function harvested from the internet, by Gregg Irwin, who       ]
;; [ seems to be a notable REBOL expert.  It copies a specified directory      ]
;; [ to another directory of a specified name, and does it recursively.        ]
;; [ The original name was "copy-dir" but I changed it to "GLB-COPY-DIR"       ]
;; [ to match my naming scheme (which is not very REBOL-ish, but helps me      ]
;; [ keep track).                                                              ]
;; [---------------------------------------------------------------------------]

GLB-COPY-DIR: func [source dest] [
    if not exists? dest [make-dir/deep dest]
    foreach file read source [
        either find file "/" [
            GLB-COPY-DIR source/:file dest/:file
        ][
            print file
            write/binary dest/:file read/binary source/:file
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a copy of the above function with one difference.                 ]
;; [ After copying the file, the procedure removes it from the source folder.  ]
;; [ Obviously, this must be used with care.                                   ]
;; [---------------------------------------------------------------------------]

GLB-MOVE-DIR: func [source dest] [
    if not exists? dest [make-dir/deep dest]
    foreach file read source [
        either find file "/" [
            GLB-MOVE-DIR source/:file dest/:file
        ][
            print ["copying " file]
            write/binary dest/:file read/binary source/:file
            delete source/:file
            print [file " removed"] 
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This function takes a string parameter and returns "true" if the          ]
;; [ string contains only digits, or "false" otherwise.                        ]
;; [ It is the COBOL concept of checking if something is NUMERIC.              ]
;; [ Note the string conversion of TEST-BYTE; won't work without it.           ]
;; [---------------------------------------------------------------------------]

GLB-IS-NUMERIC: func [
    NUMERIC-TEST-DATA [string!] 
    /local INPUT-SIZE DIGIT-COUNT TEST-BYTE INPUT-SUB
] [
    INPUT-SIZE: length? NUMERIC-TEST-DATA
    if equal? INPUT-SIZE 0 [
        return false
    ]
    DIGIT-COUNT: 0
    INPUT-SUB: 1
    loop INPUT-SIZE [
        TEST-BYTE: copy ""
        TEST-BYTE: to-string pick NUMERIC-TEST-DATA INPUT-SUB
        if 
           (TEST-BYTE = "0") or
           (TEST-BYTE = "1") or
           (TEST-BYTE = "2") or
           (TEST-BYTE = "3") or
           (TEST-BYTE = "4") or
           (TEST-BYTE = "5") or
           (TEST-BYTE = "6") or
           (TEST-BYTE = "7") or
           (TEST-BYTE = "8") or
           (TEST-BYTE = "9")  [
            DIGIT-COUNT: DIGIT-COUNT + 1
        ]
        INPUT-SUB: INPUT-SUB + 1
    ]
    either (DIGIT-COUNT = INPUT-SIZE) [
        return true
    ] [
        return false
    ]      
]     

;; [---------------------------------------------------------------------------]
;; [ This function takes a string parameter and returns "true" if the          ]
;; [ string contains only letters, or "false" otherwise.                       ]
;; [ It is the COBOL concept of checking if something is ALHPABETIC.           ]
;; [ Note the string conversion of TEST-BYTE; won't work without it.           ]
;; [---------------------------------------------------------------------------]

GLB-IS-ALPHABETIC: func [
    ALHPABETIC-TEST-DATA [string!] 
    /local INPUT-SIZE LETTER-COUNT TEST-BYTE INPUT-SUB
] [
    INPUT-SIZE: length? ALHPABETIC-TEST-DATA
    LETTER-COUNT: 0
    INPUT-SUB: 1
    loop INPUT-SIZE [
        TEST-BYTE: copy ""
        TEST-BYTE: to-string pick ALHPABETIC-TEST-DATA INPUT-SUB
        if 
           (TEST-BYTE = "A") or
           (TEST-BYTE = "B") or
           (TEST-BYTE = "C") or
           (TEST-BYTE = "D") or
           (TEST-BYTE = "E") or
           (TEST-BYTE = "F") or
           (TEST-BYTE = "G") or
           (TEST-BYTE = "H") or
           (TEST-BYTE = "I") or
           (TEST-BYTE = "J") or
           (TEST-BYTE = "K") or
           (TEST-BYTE = "L") or
           (TEST-BYTE = "M") or
           (TEST-BYTE = "N") or
           (TEST-BYTE = "O") or
           (TEST-BYTE = "P") or
           (TEST-BYTE = "Q") or
           (TEST-BYTE = "R") or
           (TEST-BYTE = "S") or
           (TEST-BYTE = "T") or
           (TEST-BYTE = "U") or
           (TEST-BYTE = "V") or
           (TEST-BYTE = "W") or
           (TEST-BYTE = "X") or
           (TEST-BYTE = "Y") or
           (TEST-BYTE = "Z") or
           (TEST-BYTE = "a") or
           (TEST-BYTE = "b") or
           (TEST-BYTE = "c") or
           (TEST-BYTE = "d") or
           (TEST-BYTE = "e") or
           (TEST-BYTE = "f") or
           (TEST-BYTE = "g") or
           (TEST-BYTE = "h") or
           (TEST-BYTE = "i") or
           (TEST-BYTE = "j") or
           (TEST-BYTE = "k") or
           (TEST-BYTE = "l") or
           (TEST-BYTE = "m") or
           (TEST-BYTE = "n") or
           (TEST-BYTE = "o") or
           (TEST-BYTE = "p") or
           (TEST-BYTE = "q") or
           (TEST-BYTE = "r") or
           (TEST-BYTE = "s") or
           (TEST-BYTE = "t") or
           (TEST-BYTE = "u") or
           (TEST-BYTE = "v") or
           (TEST-BYTE = "w") or
           (TEST-BYTE = "x") or
           (TEST-BYTE = "y") or
           (TEST-BYTE = "z") or 
           (TEST-BYTE = " ")  [
            LETTER-COUNT: LETTER-COUNT + 1
        ]
        INPUT-SUB: INPUT-SUB + 1
    ]
    either (LETTER-COUNT = INPUT-SIZE) [
        return true
    ] [
        return false
    ]      
]     

;; [---------------------------------------------------------------------------]
;; [ This is a function that accepts a date in mm/dd/yyyy format               ]
;; [ (with the slashes) and checks almost everything possible to make sure     ]
;; [ it is a real date.  A date of this format might be entered by a person    ]
;; [ filling out a form.                                                       ]
;; [ The procedure is NOT designed to be "intelligent" enough to allow         ]
;; [ a variety of date formats.  Instead, it allows only ONE format.           ]
;; [ This is a feature, not a bug.                                             ]
;; [---------------------------------------------------------------------------]

GLB-CHECK-MMDDYYYY-MSG: ""
GLB-CHECK-MMDDYYYY-MM: ""
GLB-CHECK-MMDDYYYY-DD: ""
GLB-CHECK-MMDDYYYY-YYYY: ""
GLB-CHECK-MMDDYYYY-S1: ""
GLB-CHECK-MMDDYYYY-S2: ""
GLB-CHECK-MMDDYYYY-OK: true
GLB-CHECK-MMDDYYYY: func [
    GLB-CHECK-MMDDYYYY-INPUT [string!]
    /local INT-MM INT-DD INT-YYYY
] [
    GLB-CHECK-MMDDYYYY-OK: true
    GLB-CHECK-MMDDYYYY-MSG: copy ""
    GLB-CHECK-MMDDYYYY-MM: copy ""
    GLB-CHECK-MMDDYYYY-DD: copy ""
    GLB-CHECK-MMDDYYYY-YYYY: copy ""
    GLB-CHECK-MMDDYYYY-S1: copy ""
    GLB-CHECK-MMDDYYYY-S2: copy ""
    either ((length? GLB-CHECK-MMDDYYYY-INPUT) = 10) [
        GLB-CHECK-MMDDYYYY-MM: GLB-SUBSTRING GLB-CHECK-MMDDYYYY-INPUT 1 2
        GLB-CHECK-MMDDYYYY-S1: GLB-SUBSTRING GLB-CHECK-MMDDYYYY-INPUT 3 3
        GLB-CHECK-MMDDYYYY-DD: GLB-SUBSTRING GLB-CHECK-MMDDYYYY-INPUT 4 5
        GLB-CHECK-MMDDYYYY-S2: GLB-SUBSTRING GLB-CHECK-MMDDYYYY-INPUT 6 6
        GLB-CHECK-MMDDYYYY-YYYY: GLB-SUBSTRING GLB-CHECK-MMDDYYYY-INPUT 7 10

        either (GLB-IS-NUMERIC GLB-CHECK-MMDDYYYY-MM) [
            INT-MM: to-integer GLB-CHECK-MMDDYYYY-MM
            if (INT-MM = 0) or
               (INT-MM > 12) [
                append GLB-CHECK-MMDDYYYY-MSG
                    "Month part of date is out of range. "
                GLB-CHECK-MMDDYYYY-OK: false
            ]
        ] [
            append GLB-CHECK-MMDDYYYY-MSG 
                "Month part of date is not numeric. "
            GLB-CHECK-MMDDYYYY-OK: false
        ]

        either (GLB-IS-NUMERIC GLB-CHECK-MMDDYYYY-DD) [
            INT-DD: to-integer GLB-CHECK-MMDDYYYY-DD
            if (INT-DD = 0) or
               (INT-DD > 31) [
                append GLB-CHECK-MMDDYYYY-MSG
                    "Day part of date is out of range. "
                GLB-CHECK-MMDDYYYY-OK: false
            ]
        ] [
            append GLB-CHECK-MMDDYYYY-MSG 
                "Day part of date is not numeric. "
            GLB-CHECK-MMDDYYYY-OK: false
        ]

        either (GLB-IS-NUMERIC GLB-CHECK-MMDDYYYY-YYYY) [
            INT-YYYY: to-integer GLB-CHECK-MMDDYYYY-YYYY
            if (INT-YYYY > 3000) [
                append GLB-CHECK-MMDDYYYY-MSG
                    "Year part of date is out of range. "
                GLB-CHECK-MMDDYYYY-OK: false
            ]
        ] [
            append GLB-CHECK-MMDDYYYY-MSG 
                "Year part of date is not numeric. "
            GLB-CHECK-MMDDYYYY-OK: false
        ]

    ] [
        append GLB-CHECK-MMDDYYYY-MSG 
            "Alleged date is not ten characters (mm/dd/yyyy with slashes). "
        GLB-CHECK-MMDDYYYY-OK: false 
    ]
    either GLB-CHECK-MMDDYYYY-OK [
        return true
    ] [
        return false
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is a function for a COBOL-like editing of a data item                ]
;; [ with an "X" picture.                                                      ]
;; [ Call the function with a string and a mask, and the function              ]
;; [ will return a string that has the format of the mask with                 ]
;; [ any character "X" replaced by a character of the input string.            ]
;; [ For example:                                                              ]
;; [ SSN: "111223333"                                                          ]
;; [ GLB-EDIT-X SSN "XXX-XX-XXXX"                                              ]
;; [ and the result will be "111-22-3333".                                     ]
;; [ Note the line of code that compares the character from the mask to        ]
;; [ the letter X.  In REBOL, "X" is a string and #"X" is a character,         ]
;; [ and they are not the same.                                                ]
;; [---------------------------------------------------------------------------]

GLB-EDIT-X: func ["COBOL-like edit of string using mask"
    XSTRING XMASK   
    /local 
        XINPUT   ; trimmed input work area
        XINLGH   ; length of trimmed input
        XINSUB   ; subscript for trimmed input
        XOUTPUT  ; final output area, returned to caller
        XMASKLGH ; length of edit mask from caller
        XMASKSUB ; subscript for mask   
    ] [
    XINPUT: trim XSTRING
    XINLGH: length? XINPUT
    XMASKLGH: length? XMASK
    XINSUB: 1
    XMASKSUB: 1
    XOUTPUT: copy ""
    if equal? XINPUT "" [
        return XOUTPUT
    ]
    while [<= XMASKSUB XMASKLGH] [
        either (XMASK/:XMASKSUB = #"X") [  ;; potential "gotcha" 
            if (XINSUB <= XINLGH) [
                append XOUTPUT XINPUT/:XINSUB
                XINSUB: XINSUB + 1
            ]
        ] [
            append XOUTPUT XMASK/:XMASKSUB
        ]
        XMASKSUB: XMASKSUB + 1 
    ]
    return XOUTPUT 
]

;; #####################################################################

