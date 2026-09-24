import 'renang_tables.dart';

/// Kategori umur untuk perhitungan renang (sama untuk pria & wanita).
/// Mengembalikan 0 jika umur belum valid (< 10).
int kategoriUmurRenang(int umur) {
  if (umur < 10) return 0;
  if (umur <= 21) return 1;
  if (umur <= 25) return 2;
  if (umur <= 29) return 3;
  if (umur <= 33) return 4;
  if (umur <= 37) return 5;
  if (umur <= 41) return 6;
  if (umur <= 45) return 7;
  if (umur <= 49) return 8;
  if (umur <= 53) return 9;
  return 10;
}

/// Mencari nilai dasar dari waktu yang diketik (format `menit.detik`, mis. `0.33`).
/// Kunci tabel ada yang ditulis `0.33` dan ada yang `00.33`, jadi beberapa
/// bentuk penulisan dicoba. Mengembalikan null jika waktu tidak ada di tabel.
int? nilaiDasarRenang(Map<String, int> tabel, String waktu) {
  final t = waktu.trim();
  if (t.isEmpty) return null;
  if (tabel.containsKey(t)) return tabel[t];

  final parts = t.split('.');
  if (parts.length != 2) return null;
  final menit = int.tryParse(parts[0]);
  final detikTeks = parts[1];
  final detik = int.tryParse(detikTeks);
  if (menit == null || detik == null) return null;

  final dd = detik.toString().padLeft(2, '0');
  final kandidat = <String>[
    '$menit.$dd',
    '${menit.toString().padLeft(2, '0')}.$dd',
    if (detik == 0) '$menit.0',
  ];
  for (final k in kandidat) {
    if (tabel.containsKey(k)) return tabel[k];
  }
  return null;
}

/// Hasil perhitungan satu peserta.
class HasilRenang {
  final int kategori;
  final int? nilaiDasar;

  /// Nilai dasar + tambahan kategori umur (3 poin per tingkat kategori).
  final int? hasilNilai;

  /// Hasil nilai dibatasi ke rentang 0..100.
  final int? nilaiAkhir;

  const HasilRenang({
    required this.kategori,
    this.nilaiDasar,
    this.hasilNilai,
    this.nilaiAkhir,
  });
}

HasilRenang hitungRenang({
  required Map<String, int> tabel,
  required String umurTeks,
  required String waktuTeks,
}) {
  final umur = int.tryParse(umurTeks.trim()) ?? 0;
  final kategori = kategoriUmurRenang(umur);
  final dasar = nilaiDasarRenang(tabel, waktuTeks);
  if (kategori == 0 || dasar == null) {
    return HasilRenang(kategori: kategori, nilaiDasar: dasar);
  }
  final hasil = dasar + 3 * (kategori - 1);
  final akhir = hasil < 0 ? 0 : (hasil > 100 ? 100 : hasil);
  return HasilRenang(
    kategori: kategori,
    nilaiDasar: dasar,
    hasilNilai: hasil,
    nilaiAkhir: akhir,
  );
}

/// Konfigurasi satu jenis tes renang (dasar / militer dasar).
class RenangConfig {
  final String judul;
  final Map<String, int> priaTable;
  final Map<String, int> wanitaTable;

  const RenangConfig({
    required this.judul,
    required this.priaTable,
    required this.wanitaTable,
  });
}

const renangDasarConfig = RenangConfig(
  judul: 'RENANG DASAR',
  priaTable: renangPriaTable,
  wanitaTable: renangWanitaTable,
);

const renmilConfig = RenangConfig(
  judul: 'RENANG MILITER DASAR',
  priaTable: renmilPriaTable,
  wanitaTable: renmilWanitaTable,
);
