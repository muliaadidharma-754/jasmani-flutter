import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/berat_ideal_table.dart';
import '../theme/app_theme.dart';

class BeratScreen extends StatefulWidget {
  const BeratScreen({super.key});

  @override
  State<BeratScreen> createState() => _BeratScreenState();
}

class _BeratScreenState extends State<BeratScreen> {
  final _tinggiCtrl = TextEditingController();
  List<double>? _row;

  @override
  void initState() {
    super.initState();
    _tinggiCtrl.addListener(_hitung);
  }

  @override
  void dispose() {
    _tinggiCtrl.dispose();
    super.dispose();
  }

  void _hitung() {
    final tinggi = double.tryParse(_tinggiCtrl.text.trim());
    if (tinggi == null) {
      setState(() => _row = null);
      return;
    }
    // Cocokkan ke baris tabel terdekat (step 0.1 cm), sama seperti pencarian
    // exact-match pada aplikasi asli, dibulatkan ke 1 desimal terdekat.
    final target = (tinggi * 10).round() / 10;
    List<double>? found;
    for (final row in beratIdealTable) {
      if ((row[0] - target).abs() < 0.05) {
        found = row;
        break;
      }
    }
    setState(() => _row = found);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berat Ideal')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _tinggiCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  hintText: 'contoh: 170 (rentang 150-200 cm)',
                ),
              ),
              const SizedBox(height: 20),
              if (_row == null)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      'Masukkan tinggi badan 150-200 cm',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                _buildLadder(_row!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLadder(List<double> row) {
    // Kolom: [tinggi, hA1,hA2, hB1,hB2, nA1,nA2, nB1,nB2, lA1,lA2, lB1,lB2, llA1, llB1, ideA1,ideA2, ideB1,ideB2]
    final hA1 = row[1], hA2 = row[2];
    final hB1 = row[3], hB2 = row[4];
    final nA1 = row[5], nA2 = row[6];
    final nB1 = row[7], nB2 = row[8];
    final lA1 = row[9], lA2 = row[10];
    final lB1 = row[11], lB2 = row[12];
    final llA1 = row[13];
    final llB1 = row[14];
    final ideA2 = row[16];
    final ideB1 = row[17];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            _tier('Luar Limit Atas', 'KEATAS dari ${llA1.toStringAsFixed(1)} kg'),
            _tier('Limit Atas', '${lA1.toStringAsFixed(1)} - ${lA2.toStringAsFixed(1)} kg'),
            _tier('Normal Atas', '${nA1.toStringAsFixed(1)} - ${nA2.toStringAsFixed(1)} kg'),
            _tier('Harmonis Atas', '${hA1.toStringAsFixed(1)} - ${hA2.toStringAsFixed(1)} kg'),
            _tier(
              'IDEAL',
              '${ideB1.toStringAsFixed(1)} - ${ideA2.toStringAsFixed(1)} kg',
              highlight: true,
            ),
            _tier('Harmonis Bawah', '${hB1.toStringAsFixed(1)} - ${hB2.toStringAsFixed(1)} kg'),
            _tier('Normal Bawah', '${nB1.toStringAsFixed(1)} - ${nB2.toStringAsFixed(1)} kg'),
            _tier('Limit Bawah', '${lB1.toStringAsFixed(1)} - ${lB2.toStringAsFixed(1)} kg'),
            _tier('Luar Limit Bawah', 'KEBAWAH dari ${llB1.toStringAsFixed(1)} kg'),
          ],
        ),
      ),
    );
  }

  Widget _tier(String label, String value, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.neonCyan.withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(10),
        border: highlight
            ? Border.all(color: AppColors.neonCyan, width: 1.2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? AppColors.neonCyan : AppColors.textMuted,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.neonCyan : AppColors.textPrimary,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
