REBOL [
    Title: "batgen: generate DOS batch file to run a script."
    Purpose: {Generate a DOS batch file to run the REBOL interpreter,
    to run a selected REBOL script.  Nothing that can't be done almost
    as quickly by hand, but if you have to do a lot of these, then the
    help is appreciated.}
]

;; Change the path below for your specific installation.
REBOL-FILE-ID: "\\cob-apps\vol1\REBOL\rebview.exe"

;; Ask for the name of the script file to run.
if not SCRIPT-FILE-ID: request-file/only [
    alert "No file requested"
    quit
]

;; Take apart the script name to get the name without the dot-r.
set [SCRIPT-FOLDER SCRIPT-FILE] split-path SCRIPT-FILE-ID
SCRIPT-BASE: first parse/all to-string SCRIPT-FILE "."

;; Build the batch file name based on the script name with dot-bat suffix.
BATCH-FILE-ID: to-file rejoin [
    SCRIPT-FOLDER
    SCRIPT-BASE
    ".bat"
]

;; String everything together and write it to the DOS batch file.
write BATCH-FILE-ID rejoin [
    {start "" }
    REBOL-FILE-ID
    " -i -s --script "
    SCRIPT-FILE-ID 
]

;; Give feedback to indicate we are done.
alert "Done."

