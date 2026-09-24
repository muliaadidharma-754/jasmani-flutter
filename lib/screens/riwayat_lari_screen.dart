import 'package:flutter/material.dart';

import '../data/run_history.dart';
import '../theme/app_theme.dart';

class RiwayatLariScreen extends StatefulWidget {
  const RiwayatLariScreen({super.key});

  @override
  State<RiwayatLariScreen> createState() => _RiwayatLariScreenState();
}

class _RiwayatLariScreenState extends State<RiwayatLariScreen> {
  late Future<List<RunRecord>> _future = RunHistory.load();

  void _reload() => setState(() => _future = RunHistory.load());

  static const _bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _tanggal(DateTime d) {
    String dua(int n) => n.toString().padLeft(2, '0');
    return '${d.day} ${_bulan[d.month - 1]} ${d.year}, ${dua(d.hour)}:${dua(d.minute)}';
  }

  Future<void> _hapus(RunRecord r) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus riwayat?'),
        content: Text('${r.jarakKm.toStringAsFixed(2)} km • ${r.durasi}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ya == true) {
      await RunHistory.remove(r);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RIWAYAT LARI')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: FutureBuilder<List<RunRecord>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data!;
            if (list.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada riwayat tersimpan',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = list[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.neonCyanDim),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tanggal(r.waktuMulai),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${r.jarakKm.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                color: AppColors.neonCyan,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Waktu ${r.durasi}  •  Pace ${r.pace}/km',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => _hapus(r),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
