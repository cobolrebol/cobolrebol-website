REBOL [
    Title: "Personal message of the day"
    Purpose: {Pop up a window at login time showing text from
    a text file.  This is like the unix motd program.
    Put the text into an area so that we can modify it, and
    provide a button to save the modified text.  You would have
    to arrange to have this program run at startup in whatever
    way is appropriate for your computer.}
]

MOTD-FILE: %motd.txt

if not exists? MOTD-FILE [
    write MOTD-FILE rejoin [
        "Message of the day"
        newline
    ]
]

view center-face layout [
    WINDOW-TEXT: area 500x500 (read MOTD-FILE) wrap font [size: 24]
    button 120 "Save and close" [write MOTD-FILE WINDOW-TEXT/text quit]
]

