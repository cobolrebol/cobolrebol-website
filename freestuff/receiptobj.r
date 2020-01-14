REBOL [
    Title: "Generic receipt object"
    Purpose: {Create a basic printable receipt file from minimal
    generic input.  These constraints create a receipt object that
    can be plugged into many programs that need such functionality.}
]

;; [---------------------------------------------------------------------------]
;; [ This module encapsulates code for producing a basic printed receipt       ]
;; [ for money paid for something; very generic.  This module would be used    ]
;; [ as part of a larger program where it was necessary to produce such a      ]
;; [ a receipt.  One would include it in the larger program by coding:         ]
;; [     do %receiptobj.r                                                      ]
;; [ One then would be able to use the functions in this module.               ]
;; [                                                                           ]
;; [ To use this module, one first would make an instance of the object,       ]
;; [ something like this:                                                      ]
;; [     RCPT: make RECEIPT []                                                 ]
;; [ This declaration is where you could modify the FOLDER and LOG items       ]
;; [ if you wanted the printed receipts and the log to go to some location     ]
;; [ other than the one coded into the module.  Something like this:           ]
;; [     RCPT: make RECEIPT [                                                  ]
;; [         FOLDER: %/I/RECEIPTFILES/                                         ]
;; [         LOG: %/I/RECEIPTFILES/LOG.CSV                                     ]
;; [     ]                                                                     ]
;; [ Note that any folders in the path to the log file must exist.  The        ]
;; [ module will not make them.  You could change that if you wanted to.       ]
;; [                                                                           ]
;; [ There are two functions available.                                        ]
;; [                                                                           ]
;; [ MAKE-RECEIPT:  This function must be provided with a block of             ]
;; [ pre-formatted data items that will apppear on the printed receipt.        ]
;; [ Those items are:  (Note that they all are strings.)                       ]
;; [     Date of the transaction                                               ]
;; [     Name of the person making the payment                                 ]
;; [     Whatever thing the person paid for                                    ]
;; [     The amount of money paid                                              ]
;; [     The payment method (cash, check, etc.)                                ]
;; [     A check number or confirmation number or something like that          ]
;; [     The name of the person taking the payment                             ]
;; [     A short note                                                          ]
;; [ Note that the above items are strings in the form they are to be          ]
;; [ printed.  It would be the job of any calling program to take care of      ]
;; [ appropriate formatting.  This module just prints what it gets.            ]
;; [ The result of this function will be that the infomation supplied will     ]
;; [ be formatted into an html file that could be printed, and that the        ]
;; [ same information will be appended to a log file in the CSV format.        ]
;; [ Also, the function will return the full name of the html file, so one     ]
;; [ could use the "browse" function with that name to show the receipt        ]
;; [ immediately for printing.                                                 ]
;; [                                                                           ]
;; [ SHOW-RECEIPT-WINDOW:  This function is designed to be called from         ]
;; [ a VID window.  It displays a window for entering that same information    ]
;; [ that is printed on the html receipts.  One enters that data into the      ]
;; [ window and clicks a "submit" button, and the code for the "submit"        ]
;; [ button uses the MAKE-RECEIPT function to produce a receipt. This          ]
;; [ structuring of the code allows this module to be used in a program        ]
;; [ with a graphical interface, and in a program that has to print a          ]
;; [ receipt without any graphical interface.                                  ]
;; [---------------------------------------------------------------------------]

RECEIPT: make object! [

;; -- Change these items when you make your own specific receipt object.
    FOLDER: %/C/receipts/             ;; storage for receipt files
    LOG: %/C/receipts/receiptslog.csv ;; one-line-per-receipt log file

;; -- html template for printed receipt.  We could use a text file for
;; -- a printable receipts, but with html we would have the option of
;; -- modifying the template to include some graphics, like a logo.
    HTML: {<html><head><title>Receipt</title></head><body>
    <h1>Receipt</h1><table width="100%" border="1">
    <tr> <td width="50%">Date</td> <td width="50%"> %%DATE%% </td></tr>
    <tr> <td width="50%">From</td> <td width="50%"> %%FROM%% </td></tr>
    <tr> <td width="50%">Received for</td> <td width="50%"> %%FOR%% </td></tr>
    <tr> <td width="50%">Amount</td> <td width="50%"> %%AMOUNT%% </td></tr>
    <tr> <td width="50%">Payment type</td> <td width="50%"> %%TYPE%% </td></tr>
    <tr> <td width="50%">Check/Confirmation</td> <td width="50%"> %%NUMBER%% </td></tr>
    <tr> <td width="50%">Taken by</td> <td width="50%"> %%BY%% </td></tr>
    <tr> <td width="50%">Note</td> <td width="50%"> %%NOTE%% </td></tr>
    </table></body></html>}

;; -- A function to be used later, to make a date-time stamp from
;; -- the current date.  Refer to:
;; -- http://www.rebol.net/cookbook/recipes/0008.html
    MAKE-TIMESTAMP: does [
        TIMESTAMP: copy ""
        DATE-TIME: now
        append TIMESTAMP to-string DATE-TIME/year
        either DATE-TIME/month < 10 [
            append TIMESTAMP rejoin ["0" to-string DATE-TIME/month]
        ] [
            append TIMESTAMP to-string DATE-TIME/month
        ]
        either DATE-TIME/day < 10 [
            append TIMESTAMP rejoin ["0" to-string DATE-TIME/day]
        ] [
            append TIMESTAMP to-string DATE-TIME/day
        ]
;;  -- REBOL uses 24-hour clock.
        append TIMESTAMP trim/with to-string DATE-TIME/time ":"
        return TIMESTAMP
    ]

;; -- A receipts is created by this function.  The reason for using a
;; -- function is so that a receipt can be created by the window that
;; -- is included in this object, or by some other program.
;; -- The function takes a block of pre-fomatted date items to put on
;; -- the receipt.  Those parts, in order, are:
;; -- DATE      ;; Date of receipt
;; -- FROM      ;; Person making payment
;; -- FOR       ;; Reason for payment
;; -- AMOUNT    ;; Amount of money
;; -- TYPE      ;; Method of payment
;; -- NUMBER    ;; Check number, confirmation number, etc.
;; -- BY        ;; Person taking payment
;; -- NOTE      ;; Free-form note
    MAKE-RECEIPT: func [
        PARTS [block!]       
        /local TEMPHTML FILEID FILEPATH
    ] [
        if not exists? FOLDER [
            make-dir FOLDER
        ]
        if not exists? LOG [
            write LOG rejoin [
                "DATE,"
                "FROM,"
                "RECEIVEDFOR,"
                "AMOUNT,"
                "PMTMETHOD,"
                "NUMBER,"
                "BY,"
                "NOTE,"
                "FILEID" newline
            ]
        ]
        TEMPHTML: copy HTML
        replace TEMPHTML "%%DATE%%" PARTS/1
        replace TEMPHTML "%%FROM%%" PARTS/2
        replace TEMPHTML "%%FOR%%" PARTS/3
        replace TEMPHTML "%%AMOUNT%%" PARTS/4
        replace TEMPHTML "%%TYPE%%" PARTS/5
        replace TEMPHTML "%%NUMBER%%" PARTS/6
        replace TEMPHTML "%%BY%%" PARTS/7
        replace TEMPHTML "%%NOTE%%" PARTS/8
        FILEID: rejoin [
            MAKE-TIMESTAMP "-"
            trim/all/with copy PARTS/2 " .,/"
            ".html"
        ]
        FILEPATH: to-file rejoin [
            FOLDER
            FILEID
        ]
        write FILEPATH TEMPHTML
        write/append LOG rejoin [
            mold PARTS/1 ","
            mold PARTS/2 ","
            mold PARTS/3 ","
            mold PARTS/4 ","
            mold PARTS/5 ","
            mold PARTS/6 ","
            mold PARTS/7 ","
            mold PARTS/8 ","
            to-string FILEID newline
        ]
        return FILEPATH
    ]

;; -- This function is called by the window, to create a receipt
;; -- using the data items on the window.
    MAKE-RECEIPT-FROM-WINDOW: does [
        PARTS: copy []
        append PARTS copy get-face WIN-DATE
        append PARTS copy get-face WIN-FROM
        append PARTS copy get-face WIN-FOR
        append PARTS copy get-face WIN-AMOUNT
        append PARTS copy get-face WIN-TYPE
        append PARTS copy get-face WIN-NUMBER
        append PARTS copy get-face WIN-BY
        append PARTS copy get-face WIN-NOTE
        MAKE-RECEIPT PARTS
    ]

;; -- This object includes a window for requesting receipt data
;; -- so it can be used as part of a larger program.
    SHOW-RECEIPT-WINDOW: does [
        view/new layout [
            across 
            text 150 right "Date"
            WIN-DATE: field 200
            return
            text 150 right "Received from"
            WIN-FROM: field 200
            return
            text 150 right "Received for"
            WIN-FOR: field 200
            return
            text 150 right "Amount"
            WIN-AMOUNT: field 200
            return
            text 150 right "Method"
            WIN-TYPE: drop-down "Check" "Credit" "Cash" "Other"
            return
            text 150 right "Check/Conf number"
            WIN-NUMBER: field 200
            return
            text 150 right "Received by" 
            WIN-BY: field 200
            return
            text 150 right "Note"
            WIN-NOTE: field 200
            return
            button "Close" [unview]
            button "Submit" [MAKE-RECEIPT-FROM-WINDOW alert "Done." unview]
        ]
    ]
]

;;Uncomment to test
;RCPT: make RECEIPT []
;RCPT/MAKE-RECEIPT [
;    "2018-03-01"
;    "Mr. Smith"
;    "Room rental"
;    "$25.00"
;    "Check"
;    "1001"
;    "Mr. Jones"
;    "Monthly room rental"
;]
;FILE-NAME: RCPT/MAKE-RECEIPT [
;    "2018-03-01"
;    "Mr. Johnson"
;    "DVD rental"
;    "$2.00"
;    "Cash"
;    ""
;    "Mr. Jones"
;    ""
;]
;print ["Showing " FILE-NAME]
;browse FILE-NAME
;view center-face layout [
;    button 400 "Click this button to bring up window" [RCPT/SHOW-RECEIPT-WINDOW]
;]
;halt

