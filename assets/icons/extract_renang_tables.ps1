# Mengekstrak tabel waktu -> nilai renang dari kode Android ke Dart.
$dir = "D:\jas2025\app\src\main\java\com\xrb21\jasmani"
$out = New-Object System.Text.StringBuilder
[void]$out.AppendLine("// GENERATED oleh assets/icons/extract_renang_tables.ps1 dari activityRenang/activityRenmil.java.")
[void]$out.AppendLine("// Kunci = waktu seperti diketik pengguna (mis. `"0.33`", `"1.05`"); nilai = nilai dasar.")
[void]$out.AppendLine("// Entri yang muncul belakangan menimpa yang sama (sama seperti urutan `if` di Android).")
[void]$out.AppendLine("")
function Section($lines, $from, $to, $name) {
    $map = [ordered]@{}
    $rx = 'equalsIgnoreCase\(\s*"([^"]+)"\s*\)\s*\)\s*\w+\.setText\("(-?\d+)"\)'
    for ($i = $from - 1; $i -lt $to - 1; $i++) {
        foreach ($m in [regex]::Matches($lines[$i], $rx)) { $map[$m.Groups[1].Value] = [int]$m.Groups[2].Value }
    }
    [void]$out.AppendLine("const Map<String, int> $name = {")
    foreach ($k in $map.Keys) { [void]$out.AppendLine("  '$k': $($map[$k]),") }
    [void]$out.AppendLine("};")
    [void]$out.AppendLine("")
    "$name : $($map.Count) entri"
}
$a = Get-Content "$dir\activityRenang.java"
Section $a 201 414 'renangPriaTable'
Section $a 510 723 'renangWanitaTable'
$b = Get-Content "$dir\activityRenmil.java"
Section $b 198 353 'renmilPriaTable'
Section $b 449 608 'renmilWanitaTable'
[System.IO.File]::WriteAllText("D:\jasmani_flutter\lib\data\renang_tables.dart", $out.ToString(), (New-Object System.Text.UTF8Encoding($false)))
