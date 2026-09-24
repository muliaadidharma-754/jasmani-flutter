import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/renang_logic.dart';
import '../theme/app_theme.dart';

/// Perhitungan nilai renang (dasar / militer dasar) untuk pria dan wanita.
class RenangScreen extends StatelessWidget {
  final RenangConfig config;

  const RenangScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(config.judul)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RenangCard(
                judul: '${config.judul} PRIA',
                tabel: config.priaTable,
                hintWaktu: '00.33',
              ),
              const SizedBox(height: 16),
              _RenangCard(
                judul: '${config.judul} WANITA',
                tabel: config.wanitaTable,
                hintWaktu: '00.43',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenangCard extends StatefulWidget {
  final String judul;
  final Map<String, int> tabel;
  final String hintWaktu;

  const _RenangCard({
    required this.judul,
    required this.tabel,
    required this.hintWaktu,
  });

  @override
  State<_RenangCard> createState() => _RenangCardState();
}

class _RenangCardState extends State<_RenangCard> {
  final _umurCtrl = TextEditingController();
  final _waktuCtrl = TextEditingController();
  HasilRenang _hasil = const HasilRenang(kategori: 0);

  @override
  void initState() {
    super.initState();
    _umurCtrl.addListener(_hitung);
    _waktuCtrl.addListener(_hitung);
  }

  @override
  void dispose() {
    _umurCtrl.dispose();
    _waktuCtrl.dispose();
    super.dispose();
  }

  void _hitung() {
    setState(() {
      _hasil = hitungRenang(
        tabel: widget.tabel,
        umurTeks: _umurCtrl.text,
        waktuTeks: _waktuCtrl.text,
      );
    });
  }

  String _teks(int? v) => v?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    final waktuAda = _waktuCtrl.text.trim().isNotEmpty;
    final tidakDitemukan = waktuAda && _hasil.nilaiDasar == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.judul,
              style: const TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _umurCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'UMUR',
                      hintText: '18',
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _waktuCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    maxLength: 5,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'WAKTU (menit.detik)',
                      hintText: widget.hintWaktu,
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            if (tidakDitemukan)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Waktu tidak ada di tabel nilai',
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Info(
                  label: 'KATEGORI',
                  nilai: _hasil.kategori == 0 ? '-' : '${_hasil.kategori}',
                ),
                _Info(label: 'NILAI', nilai: _teks(_hasil.nilaiDasar)),
                _Info(label: 'HASIL', nilai: _teks(_hasil.hasilNilai)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
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
                  const SizedBox(height: 4),
                  Text(
                    _teks(_hasil.nilaiAkhir),
                    style: const TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String nilai;

  const _Info({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
