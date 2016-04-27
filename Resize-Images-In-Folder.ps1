#Function from http://www.lewisroberts.com/2015/01/18/powershell-image-resize-function/
Function ResizeImage() {
    param([String]$ImagePath, [Int]$Quality = 90, [Int]$targetSize, [String]$OutputLocation)
 
    Add-Type -AssemblyName "System.Drawing"
 
    $img = [System.Drawing.Image]::FromFile($ImagePath)
 
    $CanvasWidth = $targetSize
    $CanvasHeight = $targetSize
 
    #Encoder parameter for image quality
    $ImageEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($ImageEncoder, $Quality)
 
    # get codec
    $Codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where {$_.MimeType -eq 'image/jpeg'}
 
    #compute the final ratio to use
    $ratioX = $CanvasWidth / $img.Width;
    $ratioY = $CanvasHeight / $img.Height;
 
    $ratio = $ratioY
    if ($ratioX -le $ratioY) {
        $ratio = $ratioX
    }
 
    $newWidth = [int] ($img.Width * $ratio)
    $newHeight = [int] ($img.Height * $ratio)
 
    $bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graph = [System.Drawing.Graphics]::FromImage($bmpResized)
    $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 
    $graph.Clear([System.Drawing.Color]::White)
    $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
 
    #save to file
    $bmpResized.Save($OutputLocation, $Codec, $($encoderParams))
    $bmpResized.Dispose()
    $img.Dispose()
}

#location of my files
cd C:\Users\Justin\Desktop\testpics

#create a new folder to save my new compressed photos
mkdir newtestpics

$myfiles = ls *.jpg
$myfiles | % { ResizeImage -ImagePath $_.fullname -Quality 40 -targetSize 1000 -OutputLocation "$($pwd)\newtestpics\$($_.name)" }
