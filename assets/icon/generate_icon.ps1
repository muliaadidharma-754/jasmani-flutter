Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

function HexColor($hex) {
    $hex = $hex.TrimStart('#')
    $r = [Convert]::ToInt32($hex.Substring(0,2), 16)
    $gg = [Convert]::ToInt32($hex.Substring(2,2), 16)
    $b = [Convert]::ToInt32($hex.Substring(4,2), 16)
    return [System.Drawing.Color]::FromArgb(255, $r, $gg, $b)
}

$amber = HexColor "FFB74D"
$black = HexColor "141414"

# Background: solid amber/kuning, full bleed (no transparency)
$bgBrush = New-Object System.Drawing.SolidBrush($amber)
$g.FillRectangle($bgBrush, 0, 0, $size, $size)

# Bold "JAS" text, centered, black
$fontFamily = New-Object System.Drawing.FontFamily("Arial")
$font = New-Object System.Drawing.Font($fontFamily, 320, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$textBrush = New-Object System.Drawing.SolidBrush($black)

$text = "JAS"
$format = New-Object System.Drawing.StringFormat
$format.Alignment = [System.Drawing.StringAlignment]::Center
$format.LineAlignment = [System.Drawing.StringAlignment]::Center

$rect = New-Object System.Drawing.RectangleF 0, 0, $size, $size
$g.DrawString($text, $font, $textBrush, $rect, $format)

$outPath = "D:\jasmani_flutter\assets\icon\app_icon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
Write-Output "Saved: $outPath"
