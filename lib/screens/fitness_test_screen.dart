import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/lookup_helpers.dart';
import '../theme/app_theme.dart';

enum LariMode { jarak, waktu }

/// Konfigurasi satu varian tes (Pria/Wanita x 12 Menit/3200m).
class FitnessTestConfig {
  final String title;
  final List<List<int>> kategoriTable;
  final List<List<int>> pushupTable;
  final List<List<int>> situpTable;
  final List<List<int>> pullupTable;
  final Map<String, int> shuttleTable;
  final LariMode lariMode;
  final List<List<int>>? lariRangeTable;
  final Map<String, int>? lariTimeTable;
  final String lariLabel;
  final String lariHint;

  const FitnessTestConfig({
    required this.title,
    required this.kategoriTable,
    required this.pushupTable,
    required this.situpTable,
    required this.pullupTable,
    required this.shuttleTable,
    required this.lariMode,
    this.lariRangeTable,
    this.lariTimeTable,
    required this.lariLabel,
    required this.lariHint,
  });
}

class FitnessTestScreen extends StatefulWidget {
  final FitnessTestConfig config;
  const FitnessTestScreen({super.key, required this.config});

  @override
  State<FitnessTestScreen> createState() => _FitnessTestScreenState();
}

class _FitnessTestScreenState extends State<FitnessTestScreen> {
  final _umurCtrl = TextEditingController();
  final _lariCtrl = TextEditingController();
  final _pushupCtrl = TextEditingController();
  final _situpCtrl = TextEditingController();
  final _pullupCtrl = TextEditingController();
  final _shuttleCtrl = TextEditingController();

  int _kategori = 0;
  int _lariHasil = 0;
  int _pushupHasil = 0;
  int _situpHasil = 0;
  int _pullupHasil = 0;
  int _shuttleHasil = 0;
  double _nilaiAkhir = 0;
  String _kesimpulan = '-';

  @override
  void initState() {
    super.initState();
    for (final c in [
      _umurCtrl,
      _lariCtrl,
      _pushupCtrl,
      _situpCtrl,
      _pullupCtrl,
      _shuttleCtrl,
    ]) {
      c.addListener(_hitungSemua);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _umurCtrl,
      _lariCtrl,
      _pushupCtrl,
      _situpCtrl,
      _pullupCtrl,
      _shuttleCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _readInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void _hitungSemua() {
    final cfg = widget.config;
    final umur = _readInt(_umurCtrl);
    _kategori = umur > 0 ? kategoriUmur(cfg.kategoriTable, umur) : 0;

    int lariMentah = 0;
    if (cfg.lariMode == LariMode.jarak) {
      lariMentah = lookupRange(cfg.lariRangeTable!, _readInt(_lariCtrl));
    } else {
      lariMentah = lookupTime(cfg.lariTimeTable!, _lariCtrl.text);
    }
    _lariHasil = hasilDenganKategori(lariMentah, _kategori);

    final pushupMentah = lookupRange(cfg.pushupTable, _readInt(_pushupCtrl));
    _pushupHasil = hasilDenganKategori(pushupMentah, _kategori);

    final situpMentah = lookupRange(cfg.situpTable, _readInt(_situpCtrl));
    _situpHasil = hasilDenganKategori(situpMentah, _kategori);

    final pullupMentah = lookupRange(cfg.pullupTable, _readInt(_pullupCtrl));
    _pullupHasil = hasilDenganKategori(pullupMentah, _kategori);

    final shuttleMentah = lookupTime(cfg.shuttleTable, _shuttleCtrl.text);
    _shuttleHasil = hasilDenganKategori(shuttleMentah, _kategori);

    _nilaiAkhir = nilaiAkhir(
      lari: _lariHasil,
      pushup: _pushupHasil,
      situp: _situpHasil,
      shuttle: _shuttleHasil,
      pullup: _pullupHasil,
    );
    _kesimpulan = kesimpulanAkhir(_nilaiAkhir);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    return Scaffold(
      appBar: AppBar(title: Text(cfg.title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildField(
                controller: _umurCtrl,
                label: 'Umur (tahun)',
                hint: 'contoh: 28',
                numeric: true,
              ),
              const SizedBox(height: 8),
              _buildKategoriChip(),
              const SizedBox(height: 16),
              _buildField(
                controller: _lariCtrl,
                label: cfg.lariLabel,
                hint: cfg.lariHint,
                numeric: cfg.lariMode == LariMode.jarak,
              ),
              _buildResultRow('Nilai Lari', _lariHasil),
              const SizedBox(height: 12),
              _buildField(
                controller: _pushupCtrl,
                label: 'Push Up (repetisi)',
                hint: 'contoh: 25',
                numeric: true,
              ),
              _buildResultRow('Nilai Push Up', _pushupHasil),
              const SizedBox(height: 12),
              _buildField(
                controller: _situpCtrl,
                label: 'Sit Up (repetisi)',
                hint: 'contoh: 30',
                numeric: true,
              ),
              _buildResultRow('Nilai Sit Up', _situpHasil),
              const SizedBox(height: 12),
              _buildField(
                controller: _pullupCtrl,
                label: 'Pull Up / Chinning (repetisi)',
                hint: 'contoh: 10',
                numeric: true,
              ),
              _buildResultRow('Nilai Pull Up', _pullupHasil),
              const SizedBox(height: 12),
              _buildField(
                controller: _shuttleCtrl,
                label: 'Shuttle Run (detik, mis. 13.5)',
                hint: 'contoh: 15.4',
                numeric: false,
              ),
              _buildResultRow('Nilai Shuttle Run', _shuttleHasil),
              const SizedBox(height: 24),
              _buildFinalCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool numeric,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        keyboardType: numeric
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: numeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  Widget _buildKategoriChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          _kategori > 0 ? 'Kategori umur: $_kategori' : 'Kategori umur: -',
          style: const TextStyle(color: AppColors.bgStart),
        ),
        backgroundColor: AppColors.neonCyan,
      ),
    );
  }

  Widget _buildResultRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(
            value.toString(),
            style: const TextStyle(
              color: AppColors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'NILAI AKHIR',
              style: TextStyle(
                color: AppColors.textMuted,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _nilaiAkhir.toStringAsFixed(2),
              style: const TextStyle(
                color: AppColors.neonCyan,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_kesimpulan — ${kesimpulanLabel(_kesimpulan)}',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
