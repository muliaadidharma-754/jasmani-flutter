// Fungsi bantu untuk menghitung skor tes jasmani, mereplikasi persis
// logika di aplikasi Android asli (com.xrb21.jasmani).

/// Cari skor dari tabel rentang [lo, hi, skor]. Balik 0 kalau tidak ketemu
/// (sama seperti clear() di aplikasi asli).
int lookupRange(List<List<int>> table, int value) {
  for (final row in table) {
    if (value >= row[0] && value <= row[1]) return row[2];
  }
  return 0;
}

/// Cari skor dari tabel berbasis waktu (string persis, misal "13.15").
/// Balik 0 kalau format/nilai tidak ada di tabel.
int lookupTime(Map<String, int> table, String key) {
  return table[key.trim()] ?? 0;
}

/// Tentukan kategori umur (1-10) dari tabel kategori.
int kategoriUmur(List<List<int>> kategoriTable, int umur) {
  return lookupRange(kategoriTable, umur);
}

/// Bonus skor per kategori umur: kategori 1 = +0, kategori 2 = +5, dst.
int bonusKategori(int kategori) => (kategori - 1) * 5;

/// Terapkan bonus kategori lalu batasi maksimum 100 (tidak dibatasi minimum,
/// persis seperti logika asli yang membiarkan nilai negatif lewat).
int hasilDenganKategori(int nilaiMentah, int kategori) {
  final hasil = nilaiMentah + bonusKategori(kategori);
  return hasil >= 101 ? 100 : hasil;
}

/// Nilai akhir gabungan: rata-rata (pushup+situp+shuttle+pullup)/4,
/// lalu dirata-rata lagi dengan nilai lari (lari berbobot 50%).
double nilaiAkhir({
  required int lari,
  required int pushup,
  required int situp,
  required int shuttle,
  required int pullup,
}) {
  final rataB = (pushup + situp + shuttle + pullup) / 4;
  return (rataB + lari) / 2;
}

/// Kesimpulan huruf dari nilai akhir, persis kategori militer asli.
String kesimpulanAkhir(double nilaiAkhir) {
  if (nilaiAkhir < 21) return 'KS';
  if (nilaiAkhir <= 40) return 'K';
  if (nilaiAkhir <= 60) return 'C';
  if (nilaiAkhir <= 80) return 'B';
  return 'BS';
}

/// Deskripsi lengkap dari kode kesimpulan.
String kesimpulanLabel(String kode) {
  switch (kode) {
    case 'KS':
      return 'Kurang Sekali';
    case 'K':
      return 'Kurang';
    case 'C':
      return 'Cukup';
    case 'B':
      return 'Baik';
    case 'BS':
      return 'Baik Sekali';
    default:
      return '-';
  }
}
