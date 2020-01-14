REBOL [
    Title: "Simple Electronic List of Every Name and Address"
]

;; [---------------------------------------------------------------------------]
;; [ This is a simple name and address list with the addition of the           ]
;; [ ability to store and show a picture.                                      ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These items are coded here at the front so you can find and change them   ]
;; [ for your own installation.                                                ]
;; [---------------------------------------------------------------------------]

DATA-FILE-ID: %SELENA-DATA.txt
DATA-PHOTO-FOLDER: %SELENA-PICTURES/
DATA-CSV-ID: %SELENA-DATA.csv

;; [---------------------------------------------------------------------------]
;; [ This is a hard-coded photo of "nobody" that we will put on the screen     ]
;; [ when no data is showing, or when no photo exists for a person.            ]
;; [---------------------------------------------------------------------------]

NOBODY-PHOTO:     
64#{
/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkS
Ew8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJ
CQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy
MjIyMjIyMjIyMjIyMjL/wAARCAEAAQADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEA
AAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIh
MUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6
Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZ
mqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx
8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREA
AgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAV
YnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hp
anN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPE
xcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3
GiiigYUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFA
BRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRUcsqQxtJI4RVG
STwKAJKrXN9bWa5nmVT2Xua5/UfEckhaOz+ROnmHqawmZnYs7FmPJJOSaBHSz+KI
1JFvbs/oznANUX8S3zH5BGg9Auax6KANT/hINS/57J/37FSJ4lvlPziNx6FcVj0U
AdNB4ojYgXFuyerIcgVsW19bXi5gmVj3XuK4GlVmRgyMVYcgg4IoA9GorltO8RyR
lY7z506eYOorpYpUmjWSNw6sMgjkUDJKKKKACiiigAooooAKKKKACiiigAooooAK
KKKACiiigAooooAKKKKAI5547eFppWCooySa4vU9Ul1GY5ysIPyJU+u6mby4MMbf
uIzgY7msmgQUUUUgCiiigAooooAKKKKACr+mapLp0wxloSfnSqFFAHocE8dxCs0T
BkYZBFSVx2hambO4EMjfuJDg57GuxpjCiiigAooooAKKKKACiiigAooooAKKKKAC
iiigAooooAKy9dvTZ2DBDiSX5V9R61qVx3iK5M+pmMHKxKFA7ZoEZNFFFIAooooA
KKKKACiiigAooooAKKKKACuz0K9N5YKHOZIvlb1PpXGVreHbkwamIycLKpUjtmmB
2NFFFAwooooAKKKKACiiigAooooAKKKKACiiigAooooAQnaCT2Ga8+uZDLdSyE53
OTXfynEMh9Eb+RrzvOefXmgQUUUUgCiiigAooooAKKKKACiiigAooooAKltpDFdR
SA42uDUVGcc+nNAHowO4AjuM0tMiOYYz6ov8hT6YwooooAKKKKACiiigAooooAKK
KKACiiigAooooAZKMwyD/Yb+RrzvGOPSvRWG5WHqpFeeSjbNIvoxFAhtFFFIAooo
oAKKKKACiiigAooooAKKKKACjGePWinRDdNGvqwFAHoUQxDGP9hf5Cn01RtVR6KB
TqYwooooAKKKKACiiigAooooAKKKKACiiigAooooAQdRXB6jH5WpXCdMOT+dd7XH
eI4vL1Vn7SKGzQIyaKKKQBRRRQAUUUUAFFFFABRRRQAUUUUAFWtOj83UrdOuXB/K
qta3hyLzNVV+0als0AdgeppaKKYwooooAKKKKACiiigAooooAKKKKACiiigAoooo
AK5/xRBughnA+4xUn610FVNRthdafND3Kkr+FAHB0Ucg4IwRwRRSEFFFFABRRRQA
UUUUAFFFFABRRRQAV0/heDbBNOR99goP0rmOScAZJ4ArvNOtha6fDD3Cgt+NMC3R
RRQMKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigDiNbtPsmpOAMJJ8y1n
12Ov2X2uxMiDMkXzD1I71x1AgooopAFFFFABRRRQAUUUUAFFFFAGholp9r1JARlI
/mau3rJ0Cy+yWIkcYkl+Y+oHatamAUUUUDCiiigAooooAKKKKACiiigAooooAKKK
KACiiigAooooAQgEYPOeoritZsDY3p2j91JlkPp7V21U9RsU1C0aFuGHKN6GgDhK
KfLE8EzRSKQynBBplIQUUUUAFFFFABRRRQAVo6NYG+vRuH7qPDOfX2qjFE88yxRq
SzHAAruNOsU0+0WFeWPLt6mmBbAAGBxjoKWiigYUUUUAFFFFABRRRQAUUUUAFFFF
ABRRRQAUUUUAFFFFABRRRQAUUUUAYPiSyia1+1jiVSFJH8VctXTeJ7kCKK2B+Ync
w9K5mgQUUUUgCiiigAooooA6nw3ZRLa/azzKxKgn+Gt6ue8MXIMUtsT8wO5R610N
MAooooGFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUU13VFLOwVR1L
HAoAdVS/v4dPgMkhyx+4g6ms2/8AEcMIaO0Hmv03n7ormZ7iW5laSZy7HqTQIW5u
ZLu4eaU5Zjk+gqKiikAUUUUAFFFFABRRRQBLbXMlpcJNEcMpyPQ129hfw6hAJIzh
h99D1FcHUkFxLbSrJC5Rh0IoA9DorCsPEcMwWO7HlP03j7prbR1dQyMGU9CpyKYx
1FFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFISACTwB1NZl5rtnaZUP5sg/hTkfnQB
qVXub22tATNMqexOTXK3fiC9uMiNhCh7L1/OstmZmJZiSepJyaBHR3ficDK2kWfR
5On5Vh3N9c3jZnlZh2XoBVeikAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAVYtr65
s2zBKyjuvUGq9FAHSWnicHC3cWPV4+n5Vt217bXYBhmV/YHBrgKVWZWBViCOhBwa
YHo1FcbaeIL23wJGEyDs3X863rPXbO7wpfypD/C/A/OgDUopAQQCOQehpaBhRRRQ
AUUUUAFUNQ1W305f3jbpD0QdarazrAsV8mEg3DDr1C1yTu0js8jFmJySeSaBF2+1
e6viQz7I+yLwKoUUUgCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKK
KACiiigAooooAv2Or3ViQFffH3RuRXU6fqtvqK/u22yDqh61w9OR2jdXjYqwOQRw
RTA9ForH0bWBfL5MxAuFHXoGrYoGFVr26Wzs5J2/hHyj1NWa53xTORHBADwSWYet
AHOyyvPK0sjZZiSaZRRSEFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQA
UUUUAFFFFABRRRQAUUUUAFFFFAD4pXglWWNsMpBFd3ZXS3lnHOv8Q+Yehrga6Xwt
OTHPATwCGUelMDoq5TxST9vgHbys/qa6uuU8U/8AIQh/65f1NAGHRRRSAKKKKACi
iigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACt
zwsT9vnHbys/qKw63PC3/IQm/wCuX9RTA//Z
}

;; [---------------------------------------------------------------------------]
;; [ Note the folder we are running from in case we have to "cd" out and       ]
;; [ get back.                                                                 ]
;; [---------------------------------------------------------------------------]

HOME-DIR: what-dir

;; [---------------------------------------------------------------------------]
;; [ The data file will be a block that we load into memory.                   ]
;; [ We will need data when we build the window, so that the "extract"         ]
;; [ function that builds the moniker list will have something to extract.     ]
;; [ So, to accomplish that and to provide a little documentation,             ]
;; [ we will start the data block with one dummy item.  This dummy item        ]
;; [ can be viewed to understand how the program works, and then can be        ]
;; [ deleted when more data is present.                                        ]
;; [ One item in the name-and-address list will be two items in the data       ]
;; [ block.  This first will be a "moniker" which will be a string to          ]
;; [ use to refer to the person.  These items will be in a list on the         ]
;; [ main window, in alphabetical order, so normally one would use a first     ]
;; [ or last name.  These items should be unique because there will be         ]
;; [ some selecting done on them, and if you have duplicates, the second       ]
;; [ never will get selected.  The second item will be a block which will      ]
;; [ contain the data about the person, as shown below.                        ]
;; [---------------------------------------------------------------------------]

DATA-BLOCK: [
    "A-MODEL" [                              ;; code name/nickname/sort code
        "Mister"                             ;; first name
        "John"                               ;; middle name
        "Smith"                              ;; last name
        "100 Main Street"                    ;; address
        "Duluth"                             ;; city
        "MN"                                 ;; state
        "55803"                              ;; postal code
        "111-111-1111"                       ;; home phone
        "222-222-2222"                       ;; work phone
        "333-333-3333"                       ;; cell phone number
        "444-444-4444"                       ;; other phone number
        "This a demo person you may delete"  ;; comment
    ]
]
DATA-RECORD: []  ;; attribute block of address book entry 
DATA-LOAD: does [
    DATA-BLOCK: copy []
    DATA-BLOCK: load DATA-FILE-ID
]
DATA-SAVE: does [
    sort/skip DATA-BLOCK 2
    save DATA-FILE-ID DATA-BLOCK
]
;; Not necessary, but if we copy data items to these words, it will be
;; easier to probe around for debugging.
;; These items will be loaded when we select a record from the data block,
;; they will be loaded with screen data when we click any of the update
;; buttons, they will be blanked out when the screen is cleared. 
;; Note that KEY-MONIKER is not part of the attribute block and that is
;; why the name is KEY-MONITOR and not REC-MONIKER. 
;; The items REC-* are the ones that go into the attribute block of an 
;; item in the DATA-BLOCK
KEY-MONIKER: ""
REC-FIRST-NAME: ""
REC-MIDDLE-NAME: ""
REC-LAST-NAME: ""
REC-ADDRESS: ""
REC-CITY: ""
REC-STATE: ""
REC-POSTAL-CODE: ""
REC-HOME-PHONE: ""
REC-WORK-PHONE: ""
REC-CELL-PHONE: ""
REC-OTHER-PHONE: ""
REC-COMMENT: ""

;; Build the attribute block of an item in DATA-BLOCK.
REC-LOAD: does [
    DATA-RECORD: copy []
    append DATA-RECORD REC-FIRST-NAME
    append DATA-RECORD REC-MIDDLE-NAME
    append DATA-RECORD REC-LAST-NAME
    append DATA-RECORD REC-ADDRESS
    append DATA-RECORD REC-CITY
    append DATA-RECORD REC-STATE
    append DATA-RECORD REC-POSTAL-CODE
    append DATA-RECORD REC-HOME-PHONE
    append DATA-RECORD REC-WORK-PHONE
    append DATA-RECORD REC-CELL-PHONE
    append DATA-RECORD REC-OTHER-PHONE
    append DATA-RECORD REC-COMMENT
]

;; Unload the attribute block of an item in DATA-BLOCK
REC-UNLOAD: does [
    REC-FIRST-NAME: copy ""
    REC-MIDDLE-NAME: copy ""
    REC-LAST-NAME: copy ""
    REC-ADDRESS: copy ""
    REC-CITY: copy ""
    REC-STATE: copy ""
    REC-POSTAL-CODE: copy ""
    REC-HOME-PHONE: copy ""
    REC-WORK-PHONE: copy ""
    REC-CELL-PHONE: copy ""
    REC-OTHER-PHONE: copy ""
    REC-COMMENT: copy ""
    REC-FIRST-NAME: copy DATA-RECORD/1
    REC-MIDDLE-NAME: copy DATA-RECORD/2
    REC-LAST-NAME: copy DATA-RECORD/3
    REC-ADDRESS: copy DATA-RECORD/4
    REC-CITY: copy DATA-RECORD/5
    REC-STATE: copy DATA-RECORD/6
    REC-POSTAL-CODE: copy DATA-RECORD/7
    REC-HOME-PHONE: copy DATA-RECORD/8
    REC-WORK-PHONE: copy DATA-RECORD/9
    REC-CELL-PHONE: copy DATA-RECORD/10
    REC-OTHER-PHONE: copy DATA-RECORD/11
    REC-COMMENT: copy DATA-RECORD/12
]

REC-CLEAR: does [
    REC-FIRST-NAME: copy ""
    REC-MIDDLE-NAME: copy ""
    REC-LAST-NAME: copy ""
    REC-ADDRESS: copy ""
    REC-CITY: copy ""
    REC-STATE: copy ""
    REC-POSTAL-CODE: copy ""
    REC-HOME-PHONE: copy ""
    REC-WORK-PHONE: copy ""
    REC-CELL-PHONE: copy ""
    REC-OTHER-PHONE: copy ""
    REC-COMMENT: copy ""
] 

SET-SCREEN: does [
    set-face DATA-MONIKER KEY-MONIKER
    set-face DATA-FIRST-NAME REC-FIRST-NAME
    set-face DATA-MIDDLE-NAME REC-MIDDLE-NAME
    set-face DATA-LAST-NAME REC-LAST-NAME
    set-face DATA-ADDRESS REC-ADDRESS
    set-face DATA-CITY REC-CITY
    set-face DATA-STATE REC-STATE
    set-face DATA-POSTAL-CODE REC-POSTAL-CODE
    set-face DATA-HOME-PHONE REC-HOME-PHONE
    set-face DATA-WORK-PHONE REC-WORK-PHONE
    set-face DATA-CELL-PHONE REC-CELL-PHONE
    set-face DATA-OTHER-PHONE REC-OTHER-PHONE
    set-face DATA-COMMENT REC-COMMENT
]

GET-SCREEN: does [
    KEY-MONIKER: trim  get-face DATA-MONIKER
    REC-FIRST-NAME: trim  get-face DATA-FIRST-NAME
    REC-MIDDLE-NAME: trim  get-face DATA-MIDDLE-NAME
    REC-LAST-NAME: trim  get-face DATA-LAST-NAME
    REC-ADDRESS: trim  get-face DATA-ADDRESS
    REC-CITY: trim  get-face DATA-CITY
    REC-STATE: trim  get-face DATA-STATE
    REC-POSTAL-CODE: trim  get-face DATA-POSTAL-CODE
    REC-HOME-PHONE: trim  get-face DATA-HOME-PHONE
    REC-WORK-PHONE: trim  get-face DATA-WORK-PHONE
    REC-CELL-PHONE: trim  get-face DATA-CELL-PHONE
    REC-OTHER-PHONE: trim  get-face DATA-OTHER-PHONE
    REC-COMMENT: trim  get-face DATA-COMMENT
]

;; Create a new item in the list, only after we have determined that
;; an item with this moniker is not present.
ADD-NEW-ITEM: does [
    append DATA-BLOCK KEY-MONIKER
    REC-LOAD
    append/only DATA-BLOCK DATA-RECORD
]

;; [---------------------------------------------------------------------------]
;; [ Since a photo is optional, we will have this separate procedure for       ]
;; [ putting a photo on the screen, or clearing the photo on the screen.       ]
;; [ A photo will be in a special folder, and the name will be:                ]
;; [     <moniker>.jpg                                                         ]
;; [ This allows for just one photo.  That is a feature not a bug.             ]
;; [ If you want more you could modify the program to suite yourself.          ]
;; [ We will show the photo for whatever value is in KEY-MONIKER,              ]
;; [ and since we have a hard-coded blank photo, this procedure will work      ]
;; [ if KEY-MONIKER has a valid value or has nothing.                          ]
;; [---------------------------------------------------------------------------]

SHOW-PHOTO: does [
    PHOTO-FILE-ID: to-file rejoin [
       DATA-PHOTO-FOLDER
       KEY-MONIKER
       ".jpg"
    ]
    either exists? PHOTO-FILE-ID [
        DATA-PHOTO-IMAGE/image: load PHOTO-FILE-ID
    ] [
        DATA-PHOTO-IMAGE/image: load NOBODY-PHOTO
    ]
    show DATA-PHOTO-IMAGE
]

;; [---------------------------------------------------------------------------]
;; [ This function is performed when a name is selected from the list.         ]
;; [ MONIKER-LIST/picked will be the selected name.  Use it with the           ]
;; [ "select" function to find the data items.                                 ]
;; [---------------------------------------------------------------------------]

SHOW-SELECTED-PERSON: does [
    KEY-MONIKER: MONIKER-LIST/picked
    either DATA-RECORD: select DATA-BLOCK KEY-MONIKER [
        REC-UNLOAD
        SET-SCREEN 
        SHOW-PHOTO
    ] [
        alert rejoin [
            "Error: '"
            KEY-MONIKER
            "' is not in the data"
        ]
        exit
    ]
]

;; [---------------------------------------------------------------------------]
;; [ "Add/Update" button.                                                      ]
;; [ An item in the file is identified by the moniker.                         ]
;; [ We will take advantage of that to simplify the programming.               ]
;; [ If the moniker is present in the file, update that item.                  ]
;; [ If the moniker is not present, add the item.                              ]
;; [ This way, we need just one button, not separate buttons to add            ]
;; [ something new or change something that exists.                            ]
;; [ Remember that every address book entry is identified uniquely by a        ]
;; [ user-supplied key, which we refer to as the "moniker."                    ]
;; [ When we are updating existing data, we could examine each field from      ]
;; [ the screen and update only the data items that have been changed,         ]
;; [ but why suffer.  We will just assume that the operator wants the          ]
;; [ address book entry to be what is visible on the screen, and we will       ]
;; [ replace the attribute block of the address book item with a new block     ]
;; [ assembled from what is on the screen.  So one must be careful.            ]
;; [ If you blank out a field on the screen, you will blank out the data       ]
;; [ in the file.                                                              ]
;; [ What should we do for confirmation?  Personal preference.  For now,       ]
;; [ we will blank the data entry fields and refresh the moniker list.         ]
;; [---------------------------------------------------------------------------]

ADD-OR-UPDATE-BUTTON: does [
    GET-SCREEN
    if equal? KEY-MONIKER "" [
        alert "Moniker field must be filled in"
        exit
    ]
    either UPDATE-POSITION: find DATA-BLOCK KEY-MONIKER [
        UPDATE-POSITION: next UPDATE-POSITION ;; the attribute block
        REC-LOAD  ;; build a new attribute block
        change/only UPDATE-POSITION DATA-RECORD
        DATA-SAVE
        REC-CLEAR
        KEY-MONIKER: copy ""
        SET-SCREEN
        MONIKER-LIST/data: extract DATA-BLOCK 2
        show MONIKER-LIST
        SHOW-PHOTO
    ] [
        ADD-NEW-ITEM
        DATA-SAVE 
        REC-CLEAR
        KEY-MONIKER: copy ""
        SET-SCREEN
        MONIKER-LIST/data: extract DATA-BLOCK 2
        show MONIKER-LIST
        SHOW-PHOTO
    ]
]

;; [---------------------------------------------------------------------------]
;; [ "Delete" button.                                                          ]
;; [ Delete the item represented by the moniker on the screen, if it is        ]
;; [ present.  Remember, the operator could have changed the moniker in        ]
;; [ which case we would not find it in DATA-BLOCK.                            ]
;; [ What the "DELETE-POSITION: find DATA-BLOCK KEY-MONIKER" does is find      ]
;; [ the moniker and create a reference to it in DELETE-POSITION, which may    ]
;; [ be thought of as a sub-series of DATA-BLOCK starting at the position      ]
;; [ where we found the moniker.  Therefore, we can use the "remove"           ]
;; [ function to remove the first item of DELETE-POSITION and then remove      ]
;; [ again to remove the new first item, which will be the attribute block     ]
;; [ after the moniker, and we will have deleted and item from DATA-BLOCK.     ]
;; [ We will have removed the item from DATA-BLOCK because DELETE-POSITION     ]
;; [ was a reference to a spot in DATA-BLOCK and not any sort of copy of       ]
;; [ the data we found in DATA-BLOCK.                                          ]
;; [---------------------------------------------------------------------------]

DELETE-BUTTON: does [
    GET-SCREEN
    if equal? KEY-MONIKER "" [
        alert "Nothing selected to delete"
        exit
    ]
    either DELETE-POSITION: find DATA-BLOCK KEY-MONIKER [
        remove DELETE-POSITION  ;; moniker
        remove DELETE-POSITION  ;; attriubte block
        DATA-SAVE
        REC-CLEAR
        KEY-MONIKER: copy ""
        SET-SCREEN
        MONIKER-LIST/data: extract DATA-BLOCK 2
        show MONIKER-LIST
        SHOW-PHOTO
    ] [
        alert rejoin [
            "Moniker '"
            KEY-MONIKER
            "' not on file"
        ]
        exit
    ]
]

;; [---------------------------------------------------------------------------]
;; [ "Clear" button.                                                           ]
;; [ Clear the window by clearing the REC-* data and then refreshing the       ]
;; [ window from it.                                                           ]
;; [---------------------------------------------------------------------------]

CLEAR-BUTTON: does [
    KEY-MONIKER: copy ""
    REC-CLEAR 
    SET-SCREEN 
    SHOW-PHOTO
]

;; [---------------------------------------------------------------------------]
;; [ "Quit" button.                                                            ]
;; [ Make sure everything is saved and tidied and so on.                       ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ "Export CSV" button.                                                      ]
;; [ Copy the DATA-BLOCK to a csv file so the operator can use the data        ]
;; [ elsewhere, perhaps in a spreadsheet.                                      ]
;; [---------------------------------------------------------------------------]

EXPORT-CSV-BUTTON: does [
    CSV-FILE: copy ""
    append CSV-FILE rejoin [
        "MONIKER,"
        "FIRSTNAME,"
        "MIDDLENAME,"
        "LASTNAME,"
        "ADDRESS,"
        "CITY,"
        "STATE,"
        "POSTALCODE,"
        "HOMEPHONE,"
        "WORKPHONE,"
        "CELLPHONE,"
        "OTHERPHONE," 
        "COMMENT"
        newline
    ]
    foreach [MONIKER ATTRIBUTE-BLOCK] DATA-BLOCK [
        append CSV-FILE MONIKER
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/1
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/2
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/3
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/4
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/5
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/6
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/7
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/8
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/9
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/10
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/11
        append CSV-FILE ","
        append CSV-FILE ATTRIBUTE-BLOCK/12
        append CSV-FILE ","
        append CSV-FILE newline
    ]
    write DATA-CSV-ID CSV-FILE
    alert rejoin [
        "Data exported to "
        DATA-CSV-ID
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Main window and its component panes.                                      ]
;; [---------------------------------------------------------------------------]

MONIKER-PANE: [
    MONIKER-LIST: text-list 150x700 data (extract DATA-BLOCK 2)
        [SHOW-SELECTED-PERSON]
]

DATA-PANE: [
    size 300x700
    across
    lab 100 "Moniker" font [color: red]
    DATA-MONIKER: field 300
    return 
    lab 100 "First name"
    DATA-FIRST-NAME: field 300
    return
    lab 100 "Middle name"
    DATA-MIDDLE-NAME: field 300
    return
    lab 100 "Last name"
    DATA-LAST-NAME: field 300
    return
    lab 100 "Address"
    DATA-ADDRESS: field 300
    return
    lab 100 "City"
    DATA-CITY: field 300
    return
    lab 100 "State"
    DATA-STATE: field 300
    return
    lab 100 "Postal code"
    DATA-POSTAL-CODE: field 300
    return 
    lab 100 "Home phone"
    DATA-HOME-PHONE: field 300
    return 
    lab 100 "Work phone"
    DATA-WORK-PHONE: field 300
    return 
    lab 100 "Cell phone"
    DATA-CELL-PHONE: field 300
    return 
    lab 100 "Other phone"
    DATA-OTHER-PHONE: field 300
    return
    lab 100 "Comment"
    DATA-COMMENT: area 300x50
    return
    lab 100 "Photo"
    DATA-PHOTO-IMAGE: image 300x300 (load NOBODY-PHOTO) effect [aspect] 
]

MAIN-WINDOW: layout [
    across
    banner "Simple Electronic List of Every Name and Address"
    return
    panel 170x720 MONIKER-PANE
    panel 320x729 DATA-PANE
    return
    box 555x4 red
    return
    button 180 "Add or update shown" [ADD-OR-UPDATE-BUTTON]
    button 180 "Delete item shown"  [DELETE-BUTTON]
    button 180 "Clear input fields" [CLEAR-BUTTON]
    return
    button "Quit" [QUIT-BUTTON]
    button "Debug" [halt]
    button "Export to CSV" [EXPORT-CSV-BUTTON]
]

if exists? DATA-FILE-ID [
    DATA-LOAD
    MONIKER-LIST/data: extract DATA-BLOCK 2
]
if not exists? DATA-PHOTO-FOLDER [
    make-dir DATA-PHOTO-FOLDER
]

view center-face MAIN-WINDOW 


