# Menggambar tulisan "JAS" bergaya stensil militer (huruf sans tebal + celah/jembatan stensil).
# Dipakai oleh buat_jas.ps1 (gambar), buat_ikon.ps1 (ikon Android) dan generate_icon.ps1 (ikon Flutter).
Add-Type -AssemblyName System.Drawing

function Exclude-Rect($g, [System.Drawing.RectangleF]$r) {
    $g.ExcludeClip((New-Object System.Drawing.Region($r)))
}

# Menggambar JAS terpusat di ($cx,$cy) selebar $w piksel. Mengembalikan batas tulisan dan tebal batang huruf.
function Draw-JasStencil($g, [double]$cx, [double]$cy, [double]$w, $brush) {
    $fam = New-Object System.Drawing.FontFamily("Arial Black")
    $fmt = [System.Drawing.StringFormat]::GenericTypographic
    $origin = New-Object System.Drawing.PointF 0,0
    $huruf = @("J","A","S")
    $spasi = 80.0
    $paths = @(); $x = 0.0
    foreach ($h in $huruf) {
        $p = New-Object System.Drawing.Drawing2D.GraphicsPath
        $p.AddString($h, $fam, 0, 1000, $origin, $fmt)
        $b = $p.GetBounds()
        $m = New-Object System.Drawing.Drawing2D.Matrix; $m.Translate($x - $b.X, 0)
        $p.Transform($m); $paths += $p
        $x += $b.Width + $spasi
    }
    $total = $x - $spasi
    $top = ($paths | ForEach-Object { $_.GetBounds().Y } | Measure-Object -Minimum).Minimum
    $bot = ($paths | ForEach-Object { $_.GetBounds().Bottom } | Measure-Object -Maximum).Maximum
    $tinggi = $bot - $top
    $s = $w / $total
    # tebal batang huruf, diukur dari huruf I
    $ip = New-Object System.Drawing.Drawing2D.GraphicsPath
    $ip.AddString("I", $fam, 0, 1000, $origin, $fmt)
    $stem = $ip.GetBounds().Width * $s

    $gz = 0.045 * $tinggi * $s   # lebar celah stensil (piksel)
    $union = $null
    for ($i = 0; $i -lt 3; $i++) {
        $p = $paths[$i]
        $m = New-Object System.Drawing.Drawing2D.Matrix
        $m.Translate(-$total / 2, -($top + $tinggi / 2))
        $m.Scale($s, $s, 'Append')
        $m.Translate($cx, $cy, 'Append')
        $p.Transform($m)
        $lb = $p.GetBounds()
        $union = if ($union) { [System.Drawing.RectangleF]::Union($union, $lb) } else { $lb }

        $g.ResetClip()
        switch ($huruf[$i]) {
            "J" { # celah vertikal memisahkan kait bawah dari batang
                Exclude-Rect $g (New-Object System.Drawing.RectangleF ($lb.X + 0.27 * $lb.Width), ($lb.Y + 0.55 * $lb.Height), $gz, (0.5 * $lb.Height)) }
            "A" { # celah vertikal di puncak
                Exclude-Rect $g (New-Object System.Drawing.RectangleF ($lb.X + $lb.Width / 2 - $gz / 2), ($lb.Y - 2), $gz, (0.40 * $lb.Height)) }
            "S" { # dua celah horizontal di sisi kiri dan kanan
                Exclude-Rect $g (New-Object System.Drawing.RectangleF ($lb.X - 2), ($lb.Y + 0.36 * $lb.Height), (0.58 * $lb.Width), $gz)
                Exclude-Rect $g (New-Object System.Drawing.RectangleF ($lb.X + 0.42 * $lb.Width), ($lb.Y + 0.64 * $lb.Height - $gz), (0.58 * $lb.Width + 2), $gz) }
        }
        $g.FillPath($brush, $p)
        $g.ResetClip()
    }
    return [pscustomobject]@{ Bounds = $union; Stem = $stem }
}

# Tulisan JAS stensil + garis tebal di bawahnya (setebal batang huruf), grup dipusatkan pada kanvas $size x $size.
function Draw-JasLogo($g, [double]$size, [double]$widthFrac, $brush) {
    $w = $size * $widthFrac
    $dummy = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap 8,8))
    $probe = Draw-JasStencil $dummy 0 0 $w $brush
    $dummy.Dispose()
    $t = $probe.Stem; $gap = $t * 0.4
    $cy = $size / 2 - ($gap + $t) / 2
    $r = Draw-JasStencil $g ($size / 2) $cy $w $brush
    $g.FillRectangle($brush, $r.Bounds.X, $r.Bounds.Bottom + $gap, $r.Bounds.Width, $t)
}
