# Mengubah vector drawable Android (ikon menu) menjadi SVG untuk Flutter.
$src = "D:\jas2025\app\src\main\res\drawable"
$dst = "D:\jasmani_flutter\assets\icons"
$ns = "http://schemas.android.com/apk/res/android"
$script:clipId = 0

function Conv-Color([string]$c) {
    $map = @{ '@color/jas_amber'='#FFB74D'; '@color/jas_bg_start'='#0A0F1F'; '@color/jas_neon_cyan'='#2FE6D4' }
    if ($map.ContainsKey($c)) { $c = $map[$c] }
    $h = $c.TrimStart('#')
    if ($h.Length -eq 8) {
        $a = [Convert]::ToInt32($h.Substring(0,2),16) / 255.0
        return @(("#" + $h.Substring(2)), $a)
    }
    return @(("#" + $h), 1.0)
}

function Conv-Node($node, $sb, $defs) {
    foreach ($ch in $node.ChildNodes) {
        if ($ch.NodeType -ne 'Element') { continue }
        if ($ch.LocalName -eq 'group') {
            $attrs = ""
            $px = $ch.GetAttribute('pivotX', $ns); $py = $ch.GetAttribute('pivotY', $ns)
            $rot = $ch.GetAttribute('rotation', $ns)
            $sx = $ch.GetAttribute('scaleX', $ns); $sy = $ch.GetAttribute('scaleY', $ns)
            if ($px -eq '') { $px = 0 }; if ($py -eq '') { $py = 0 }
            $t = ""
            if ($rot -ne '' -or $sx -ne '' -or $sy -ne '') {
                if ($rot -eq '') { $rot = 0 }; if ($sx -eq '') { $sx = 1 }; if ($sy -eq '') { $sy = 1 }
                $t = " transform=`"translate($px $py) rotate($rot) scale($sx $sy) translate(-$px -$py)`""
            }
            $clipAttr = ""
            $first = $ch.ChildNodes | Where-Object { $_.NodeType -eq 'Element' } | Select-Object -First 1
            if ($first -and $first.LocalName -eq 'clip-path') {
                $script:clipId++
                $id = "clip$($script:clipId)"
                [void]$defs.AppendLine("<clipPath id=`"$id`"><path d=`"$($first.GetAttribute('pathData',$ns))`"/></clipPath>")
                $clipAttr = " clip-path=`"url(#$id)`""
            }
            [void]$sb.AppendLine("<g$t$clipAttr>")
            Conv-Node $ch $sb $defs
            [void]$sb.AppendLine("</g>")
        }
        elseif ($ch.LocalName -eq 'path') {
            $d = $ch.GetAttribute('pathData', $ns)
            $fc = $ch.GetAttribute('fillColor', $ns)
            $sc = $ch.GetAttribute('strokeColor', $ns)
            $s = "<path d=`"$d`""
            if ($fc -ne '') { $c = Conv-Color $fc; $s += " fill=`"$($c[0])`""; if ($c[1] -lt 1) { $s += " fill-opacity=`"$([math]::Round($c[1],3))`"" } } else { $s += " fill=`"none`"" }
            if ($sc -ne '') {
                $c = Conv-Color $sc
                $s += " stroke=`"$($c[0])`" stroke-width=`"$($ch.GetAttribute('strokeWidth',$ns))`""
                $cap = $ch.GetAttribute('strokeLineCap',$ns); if ($cap -ne '') { $s += " stroke-linecap=`"$cap`"" }
                $join = $ch.GetAttribute('strokeLineJoin',$ns); if ($join -ne '') { $s += " stroke-linejoin=`"$join`"" }
            }
            $s += "/>"
            [void]$sb.AppendLine($s)
        }
    }
}

foreach ($n in @('ic_12menit','ic_3200','ic_timbangan','ic_lari','ic_bmi')) {
    [xml]$x = Get-Content "$src\$n.xml" -Raw -Encoding UTF8
    $v = $x.DocumentElement
    $vw = $v.GetAttribute('viewportWidth', $ns); $vh = $v.GetAttribute('viewportHeight', $ns)
    $sb = New-Object System.Text.StringBuilder
    $defs = New-Object System.Text.StringBuilder
    Conv-Node $v $sb $defs
    $svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" viewBox=`"0 0 $vw $vh`" width=`"$vw`" height=`"$vh`">`n<defs>`n$($defs.ToString())</defs>`n$($sb.ToString())</svg>`n"
    [System.IO.File]::WriteAllText("$dst\$n.svg", $svg, (New-Object System.Text.UTF8Encoding($false)))
    "$n -> $((Get-Item "$dst\$n.svg").Length) bytes"
}
