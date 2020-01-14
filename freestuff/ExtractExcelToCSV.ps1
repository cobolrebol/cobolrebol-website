################################################################################
#
# This powershell script accepts two file names.  The first one should be   
# the name of an Excel spreadsheet file.  The second should be the name of
# a "csv" file (ending in dot-csv).  When the script runs, it will extract
# the rows of the spreadsheet file and write them in csv format in to the
# csv file.
#
# To make this script useful, the spreadsheet file should have one row,
# the first row, that contains column headings in the form of a one-word
# title for each column, starting with a letter, no embedded spaces.
# The resulting csv file then will be in a format that could be useful to
# a REBOL program, or for importing into SQL Server tables, and so on.
#
# To use this in REBOL, if it would be called ExtractExcelToCSV.ps1,
# you could code something like this:
#
#     INPUT-FILE: %inputfile.xlsx
#     OUTPUT-FILE: %outputfile.csv
#     call reduce [
#         "powershell -Command ./ExtractExcelToCSV.ps1 "
#         to-file INPUT-FILE
#         " "
#         to-file OUTPUT-FILE
#     ]
#
# You could obtain the input and output file names with request-file,
# or by some other programmatic method.  Or hard-code them.  Depends.     
#
# The above sample coding was arrived at by trial and error.
# I wanted to use call/wait, which I had used successfully before, to wait
# until the extraction was done, but the REBOL part of the operation did
# not seem to continue after the output file came into existence.     
# Works in one case, not in another; who has time to debug that stuff. 
#
################################################################################

param ($EXCELFILE, $CSVFILE)

$saveascode=6 
$spreadsheet=New-Object -comobject "Excel.Application" 
$workbook=$spreadsheet.workbooks.open($EXCELFILE)
$worksheet=$workbook.worksheets.item(2) 
$spreadsheet.displayalerts=$False 
$workbook.SaveAs($CSVFILE,$saveascode) 
$workbook.close()
$spreadsheet.quit() 

if (ps excel) { kill -name excel}

################################################################################

