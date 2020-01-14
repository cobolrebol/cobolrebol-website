################################################################################
#
# This function is a modified version of something harvested from the internet.
# The function saves the contents of the clipboard into an image file.
# The file has a hard-coded path name and a file name based on the date and
# time.  
#
# ##############################################################################
#
Function Save-Clipboardimage {

# I don't know what "ApartmentState is, but it can be invoked if you
# start powershell with the -sta runtime switch.
If ($host.Runspace.ApartmentState -ne "STA") {
    Write-Warning "You must run this in a PowerShell session with an apartment state of STA"
    Return
}

# Build the name of the saved file 
$Time = (Get-Date)
[string]$Path = "I:\clipboard"
$Path += ".jpg"

#load the necessary assemblies
Add-Type -AssemblyName "System.Drawing","System.Windows.Forms"

#create bitmap object from the screenshot
$bitmap = [Windows.Forms.Clipboard]::GetImage()  

#split off the file extension and use it as the type
[string]$filename=Split-Path -Path $Path -Leaf
[string]$FileExtension= $Filename.Split(".")[1].Trim()

#get the right format value based on the file extension
Switch ($FileExtension) {
    "png"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Png}
    "bmp"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Bmp}
    "gif"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Gif}
    "emf"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Emf}
    "jpg"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Jpeg}
    "tiff" {$FileType=[System.Drawing.Imaging.ImageFormat]::Tiff}
    "wmf"  {$FileType=[System.Drawing.Imaging.ImageFormat]::Wmf}
    "exif" {$FileType=[System.Drawing.Imaging.ImageFormat]::Exif}

    Default {
      Write-Warning "Failed to find a valid graphic file type"
      $FileType=$False
      }
} #switch

#Save the file if a valid file type was determined
if ($FileType) {
    Try {
        $bitmap.Save($Path.Trim(),$FileType)
    } #try
    Catch {
        Write-Warning "Failed to save screen capture. $($_.Exception.Message)"
    } #catch
} #if $filetype

#clear the clipboard
[Windows.Forms.Clipboard]::Clear()

} #end function

# Save the current clipboard image and exit.

Save-Clipboardimage

