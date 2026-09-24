import 'package:flutter_test/flutter_test.dart';
import 'package:jasmani_flutter/data/renang_logic.dart';

void main() {
  test('kategori umur', () {
    expect(kategoriUmurRenang(9), 0);
    expect(kategoriUmurRenang(10), 1);
    expect(kategoriUmurRenang(21), 1);
    expect(kategoriUmurRenang(22), 2);
    expect(kategoriUmurRenang(27), 3);
    expect(kategoriUmurRenang(53), 9);
    expect(kategoriUmurRenang(54), 10);
    expect(kategoriUmurRenang(70), 10);
  });

  test('renang dasar pria: nilai sama dengan aplikasi Android', () {
    final t = renangDasarConfig.priaTable;
    expect(nilaiDasarRenang(t, '1.00'), 73);
    expect(nilaiDasarRenang(t, '1.0'), 73);
    expect(nilaiDasarRenang(t, '2.41'), -28);
    expect(nilaiDasarRenang(t, '00.15'), 100);
    expect(nilaiDasarRenang(t, '9.99'), isNull);
    expect(nilaiDasarRenang(t, ''), isNull);
  });

  test('renang dasar wanita', () {
    final t = renangDasarConfig.wanitaTable;
    expect(nilaiDasarRenang(t, '1.00'), 83);
    expect(nilaiDasarRenang(t, '2.41'), -18);
  });

  test('hasil = nilai + 3 per kategori, akhir dibatasi 0..100', () {
    final r = hitungRenang(
      tabel: renangDasarConfig.priaTable,
      umurTeks: '27',
      waktuTeks: '1.00',
    );
    expect(r.kategori, 3);
    expect(r.nilaiDasar, 73);
    expect(r.hasilNilai, 79);
    expect(r.nilaiAkhir, 79);

    // Renmil pria 0.21 -> 112, umur 20 (kategori 1): hasil 112, akhir 100.
    final m = hitungRenang(
      tabel: renmilConfig.priaTable,
      umurTeks: '20',
      waktuTeks: '0.21',
    );
    expect(m.hasilNilai, 112);
    expect(m.nilaiAkhir, 100);

    // Nilai negatif dibatasi ke 0.
    final n = hitungRenang(
      tabel: renangDasarConfig.priaTable,
      umurTeks: '18',
      waktuTeks: '2.41',
    );
    expect(n.hasilNilai, -28);
    expect(n.nilaiAkhir, 0);
  });

  test('umur belum valid tidak menghasilkan nilai', () {
    final r = hitungRenang(
      tabel: renangDasarConfig.priaTable,
      umurTeks: '5',
      waktuTeks: '1.00',
    );
    expect(r.nilaiAkhir, isNull);
  });
}
