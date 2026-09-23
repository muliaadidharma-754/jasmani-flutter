import '../screens/fitness_test_screen.dart';
import 'score_tables.dart';
import 'time_tables.dart';

final testPria12 = FitnessTestConfig(
  title: 'Jasmani Pria — 12 Menit',
  kategoriTable: kategori12Menit,
  pushupTable: pushupPria12,
  situpTable: situpPria12,
  pullupTable: pullupPria12,
  shuttleTable: shuttlePria12,
  lariMode: LariMode.jarak,
  lariRangeTable: lariPria12,
  lariLabel: 'Jarak Lari 12 Menit (meter)',
  lariHint: 'contoh: 2800',
);

final testWanita12 = FitnessTestConfig(
  title: 'Jasmani Wanita — 12 Menit',
  kategoriTable: kategori12Menit,
  pushupTable: pushupWanita12,
  situpTable: situpWanita12,
  pullupTable: pullupWanita12,
  shuttleTable: shuttleWanita12,
  lariMode: LariMode.jarak,
  lariRangeTable: lariWanita12,
  lariLabel: 'Jarak Lari 12 Menit (meter)',
  lariHint: 'contoh: 2200',
);

final testPria3200 = FitnessTestConfig(
  title: 'Jasmani Pria — 3200 Meter',
  kategoriTable: kategori3200m,
  pushupTable: pushupPria3200,
  situpTable: situpPria3200,
  pullupTable: pullupPria3200,
  shuttleTable: shuttlePria3200,
  lariMode: LariMode.waktu,
  lariTimeTable: lariPria3200,
  lariLabel: 'Waktu Lari 3200m (menit.detik)',
  lariHint: 'contoh: 14.30',
);

final testWanita3200 = FitnessTestConfig(
  title: 'Jasmani Wanita — 3200 Meter',
  kategoriTable: kategori3200m,
  pushupTable: pushupWanita3200,
  situpTable: situpWanita3200,
  pullupTable: pullupWanita3200,
  shuttleTable: shuttleWanita3200,
  lariMode: LariMode.waktu,
  lariTimeTable: lariWanita3200,
  lariLabel: 'Waktu Lari 3200m (menit.detik)',
  lariHint: 'contoh: 16.45',
);
