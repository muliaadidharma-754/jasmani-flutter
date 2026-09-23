import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _beratCtrl = TextEditingController();
  final _tinggiCtrl = TextEditingController();
  double? _bmi;
  String _kategori = '-';

  @override
  void initState() {
    super.initState();
    _beratCtrl.addListener(_hitung);
    _tinggiCtrl.addListener(_hitung);
  }

  @override
  void dispose() {
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    super.dispose();
  }

  void _hitung() {
    final berat = double.tryParse(_beratCtrl.text.trim());
    final tinggi = double.tryParse(_tinggiCtrl.text.trim());
    if (berat != null && tinggi != null && tinggi > 0) {
      final tinggiM = tinggi / 100;
      final bmi = berat / (tinggiM * tinggiM);
      setState(() {
        _bmi = bmi;
        _kategori = _klasifikasi(bmi);
      });
    } else {
      setState(() {
        _bmi = null;
        _kategori = '-';
      });
    }
  }

  String _klasifikasi(double bmi) {
    if (bmi < 18.5) return 'Berat Badan Kurang';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Berat Badan Berlebih';
    return 'Obesitas';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _beratCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'contoh: 65',
                ),
              ),
              const SizedBox(height: 16),
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
                  hintText: 'contoh: 170',
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'BMI',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _bmi?.toStringAsFixed(2) ?? '-',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _kategori,
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
