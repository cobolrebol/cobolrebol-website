TITLE
Show script documentation

SUMMARY
This is a function that shows structured script documentation
in a pop-up window.  The documentation must be in a defined
format before the script header.  This is not necessarily for
documenting the script that contains this function.  It os for
showing structured documentation from any R E B O L script.

DOCUMENTATION
The documentation must be in a particular         
format, inspired by Powershell.  It must precede the R E B O L header,        
and be in four sections.  Each section must have a header which usually  
would be on a line by itself but need not be.  The headers are:          
T I T L E, S U M M A R Y, D O C U M E N T A T I O N, S C R I P T.
In the above, the spaces between the letters are present only because
this is documentation about the documentation, and if the header word
were used here, then this documentation would not display correctly  
They are case-sensitive. A documented script would look like this:                            
                                                                           
T I T L E (Don't use the embedded spaces in the real thing.)                                  
Any title text on one line                                                 
                                                                           
S U M M A R Y (Don't use the embedded spaces in the real thing.)                              
One or more lines of summary text.                                         
                                                                           
D O C U M E N T A T I O N (Don't use the embedded spaces in the real thing.)  
Free-format documentation.                                                 
                                                                           
As many lines as wanted, may include blank lines to make paragraphs.       
Will be displayed as you typed it.                                         
                                                                           
S C R I P T (Don't use the embedded spaces in the real thing.)    
The actual script, starting with the R E B O L header.                     
                                                                           
To use:                                                                    
                                                                           
Put this function into your program with:                                  
    do %ShowScriptDoc.r                                                    
If a situation requires showing the documentation from a known file,       
call the function with that file name as an argument.                      
Note that you have to know the name of the script file, and the script     
must contain documentation as explained above.  This function is for       
use in a disciplined environment.                                          

SCRIPT
REBOL [
    Title: "Show script documentation"
    Purpose: {Pop up a window showing documentation pulled out of
    a script.  This documentation must be in a partiuclar format.}
]

SHOW-SCRIPT-DOC: func [
    DOCUMENTED-SCRIPT-FILE
    /local
    FILE-LINES
    FILE-TITLE
    FILE-SUMMARY
    FILE-DOCUMENTATION
    FILE-SCRIPT
] [
    FILE-LINES: copy []
    FILE-LINES: read DOCUMENTED-SCRIPT-FILE
    parse/case FILE-LINES [thru "TITLE" copy FILE-TITLE to "SUMMARY"]
    parse/case FILE-LINES [thru "SUMMARY" copy FILE-SUMMARY to "DOCUMENTATION"]
    parse/case FILE-LINES [thru "DOCUMENTATION" copy FILE-DOCUMENTATION to "SCRIPT"]
    parse/case FILE-LINES [thru "SCRIPT" copy FILE-SCRIPT to end]
    DOC-WINDOW: layout [
        across 
        banner  600 (trim FILE-TITLE) as-is 
        return
        bar 600
        return
        TSUM: text 600x80 FILE-SUMMARY as-is font [style: 'bold]
        SSUM: scroller 20x80
        [TSUM/para/scroll/y: negate SSUM/data * 
             (max 0 TSUM/user-data - TSUM/size/y) show TSUM]
        return
        bar 600
        return
        TDESC: text 600x200 FILE-DOCUMENTATION as-is font [style: 'bold]
        SDESC: scroller 20x200
        [TDESC/para/scroll/y: negate SDESC/data * 
             (max 0 TDESC/user-data - TDESC/size/y) show TDESC]
        return
        bar 600
        return
        TSCRPT: text 600x300 FILE-SCRIPT as-is font [style: 'bold name: font-fixed]
        SSCRPT: scroller 20x300
        [TSCRPT/para/scroll/y: negate SSCRPT/data * 
             (max 0 TSCRPT/user-data - TSCRPT/size/y) show TSCRPT]
        return
        bar 600
        return
        button "close" [unview]
    ]
    TSUM/para/scroll/y: 0
    TSUM/line-list: none
    TSUM/user-data: second size-text TSUM
    TDESC/para/scroll/y: 0
    TDESC/line-list: none
    TDESC/user-data: second size-text TDESC
    TSCRPT/para/scroll/y: 0
    TSCRPT/line-list: none
    TSCRPT/user-data: second size-text TSCRPT
    view/new DOC-WINDOW
]

;; Uncomment to test
;view center-face layout [
;    button "Show" [SHOW-SCRIPT-DOC %ShowScriptDoc.r]
;    button "Quit" [quit]
;    button "Test" [alert "Still responsive"] 
;]

