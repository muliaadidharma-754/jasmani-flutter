Add-Type -AssemblyName System.Drawing

# Ikon 1024x1024: tulisan "JAS" hitam + garis tebal di bawahnya,
# latar gradasi biru muda -> tosca, full bleed (tanpa transparansi).
$size = 1024
$widthFrac = 0.78
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'

$c1 = [System.Drawing.Color]::FromArgb(255,135,206,250)
$c2 = [System.Drawing.Color]::FromArgb(255,0,201,190)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Point 0,0),(New-Object System.Drawing.Point $size,$size),$c1,$c2)
$g.FillRectangle($grad,0,0,$size,$size)

$fam = New-Object System.Drawing.FontFamily("Arial Black")
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddString("JAS", $fam, 0, 1000, (New-Object System.Drawing.PointF 0,0), [System.Drawing.StringFormat]::GenericTypographic)
$b = $path.GetBounds()
$w = $size * $widthFrac
$s = $w / $b.Width
$t = $w * 0.1053     # tebal garis = tebal batang huruf
$gap = $w * 0.0414
$m = New-Object System.Drawing.Drawing2D.Matrix
$m.Translate(-($b.X + $b.Width/2), -($b.Y + $b.Height/2))
$m.Scale($s, $s, 'Append')
$m.Translate($size/2, $size/2 - ($gap + $t)/2, 'Append')
$path.Transform($m)
$g.FillPath([System.Drawing.Brushes]::Black, $path)
$nb = $path.GetBounds()
$g.FillRectangle([System.Drawing.Brushes]::Black, $nb.X, $nb.Bottom + $gap, $nb.Width, $t)

$outPath = "D:\jasmani_flutter\assets\icon\app_icon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "Saved: $outPath"
