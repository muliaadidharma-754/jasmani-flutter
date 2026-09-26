. "$PSScriptRoot\jas_lib.ps1"

# Ikon 1024x1024: tulisan "JAS" stensil militer hitam + garis tebal di bawahnya,
# latar gradasi biru muda -> tosca, full bleed (tanpa transparansi).
$size = 1024
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'

$c1 = [System.Drawing.Color]::FromArgb(255,135,206,250)
$c2 = [System.Drawing.Color]::FromArgb(255,0,201,190)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0,0),(New-Object System.Drawing.Point $size,$size),$c1,$c2)
$g.FillRectangle($grad,0,0,$size,$size)
Draw-JasLogo $g $size 0.78 ([System.Drawing.Brushes]::Black)

$outPath = "$PSScriptRoot\app_icon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "Saved: $outPath"
