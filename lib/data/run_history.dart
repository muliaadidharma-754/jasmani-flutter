import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Satu sesi lari yang disimpan di riwayat.
class RunRecord {
  final DateTime waktuMulai;
  final double jarakKm;
  final int durasiDetik;

  const RunRecord({
    required this.waktuMulai,
    required this.jarakKm,
    required this.durasiDetik,
  });

  /// Pace rata-rata dalam format m'ss" per km.
  String get pace => formatPace(jarakKm, durasiDetik);

  String get durasi => formatDurasi(durasiDetik);

  Map<String, dynamic> toJson() => {
    'waktuMulai': waktuMulai.millisecondsSinceEpoch,
    'jarakKm': jarakKm,
    'durasiDetik': durasiDetik,
  };

  factory RunRecord.fromJson(Map<String, dynamic> j) => RunRecord(
    waktuMulai: DateTime.fromMillisecondsSinceEpoch(j['waktuMulai'] as int),
    jarakKm: (j['jarakKm'] as num).toDouble(),
    durasiDetik: j['durasiDetik'] as int,
  );
}

String formatDurasi(int totalDetik) {
  final jam = totalDetik ~/ 3600;
  final menit = (totalDetik % 3600) ~/ 60;
  final detik = totalDetik % 60;
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(jam)}:${dua(menit)}:${dua(detik)}';
}

String formatPace(double jarakKm, int durasiDetik) {
  if (jarakKm < 0.005) return "0'00\"";
  final paceDetik = durasiDetik / jarakKm;
  final menit = paceDetik ~/ 60;
  final detik = (paceDetik % 60).floor();
  return "$menit'${detik.toString().padLeft(2, '0')}\"";
}

/// Penyimpanan riwayat lari (lokal, di perangkat).
class RunHistory {
  static const _key = 'riwayat_lari';

  static Future<List<RunRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final list = <RunRecord>[];
    for (final s in raw) {
      try {
        list.add(RunRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // abaikan data rusak
      }
    }
    list.sort((a, b) => b.waktuMulai.compareTo(a.waktuMulai));
    return list;
  }

  static Future<void> add(RunRecord r) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    raw.add(jsonEncode(r.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> remove(RunRecord r) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    final target = jsonEncode(r.toJson());
    raw.remove(target);
    await prefs.setStringList(_key, raw);
  }
}
