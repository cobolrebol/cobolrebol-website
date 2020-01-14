REBOL [
    Title: "Get full file name"
    Purpose: {Request a file, and then load to the clipboard the full
    name of that file.  This was created for a situation where a person
    was required to type full file names for hyperlinks, which is a
    situation where error could be common and undesirable.}
]

WHERE-I-WAS: none

view layout [
    button 100x100 red "Get filename" [
        if WHERE-I-WAS [
            change-dir WHERE-I-WAS
        ]
        if FILENAME: request-file/only [
            write clipboard:// to-string to-local-file FILENAME
            WHERE-I-WAS: first split-path FILENAME
        ] 
    ]
]

    
