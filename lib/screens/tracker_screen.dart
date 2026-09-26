import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/run_history.dart';
import '../theme/app_theme.dart';
import 'riwayat_lari_screen.dart';

/// Pelacak lari mandiri: rute di peta + jarak, waktu, dan pace secara live.
class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final MapController _map = MapController();
  final List<LatLng> _rute = [];
  LatLng _posisi = const LatLng(-6.2, 106.816666); // default: Jakarta
  bool _adaPosisi = false;

  StreamSubscription<Position>? _sub;
  Timer? _timer;
  bool _tracking = false;
  bool _paused = false;
  double _jarakMeter = 0;
  Position? _terakhir;
  DateTime? _waktuMulai;
  final Stopwatch _sw = Stopwatch();

  int get _detik => _sw.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    _ambilPosisiAwal();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> _pastikanIzin() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _pesan('Aktifkan layanan lokasi untuk melacak lari');
      return false;
    }
    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied ||
        izin == LocationPermission.deniedForever) {
      _pesan('Izin lokasi diperlukan untuk melacak lari');
      return false;
    }
    return true;
  }

  Future<void> _ambilPosisiAwal() async {
    final izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied ||
        izin == LocationPermission.deniedForever) {
      return;
    }
    try {
      final p = await Geolocator.getCurrentPosition();
      _geserPeta(LatLng(p.latitude, p.longitude));
    } catch (_) {}
  }

  void _geserPeta(LatLng ll, {double zoom = 17}) {
    if (!mounted) return;
    setState(() {
      _posisi = ll;
      _adaPosisi = true;
    });
    try {
      _map.move(ll, zoom);
    } catch (_) {}
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _mulai() async {
    if (!await _pastikanIzin()) return;
    setState(() {
      _tracking = true;
      _paused = false;
      _jarakMeter = 0;
      _terakhir = null;
      _rute.clear();
      _waktuMulai = DateTime.now();
      _sw
        ..reset()
        ..start();
    });
    _mulaiStream();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _mulaiStream() {
    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2,
      ),
    ).listen(_onPosisi);
  }

  void _onPosisi(Position p) {
    final ll = LatLng(p.latitude, p.longitude);
    if (_terakhir != null) {
      _jarakMeter += Geolocator.distanceBetween(
        _terakhir!.latitude,
        _terakhir!.longitude,
        p.latitude,
        p.longitude,
      );
    }
    _terakhir = p;
    _rute.add(ll);
    _geserPeta(ll);
  }

  void _jeda() {
    _sub?.cancel();
    _sw.stop();
    setState(() => _paused = true);
  }

  void _lanjut() {
    _sw.start();
    _terakhir = null; // hindari lonjakan jarak saat berpindah selama jeda
    _mulaiStream();
    setState(() => _paused = false);
  }

  Future<void> _selesai() async {
    final sudahJalan = _tracking;
    _sub?.cancel();
    _timer?.cancel();
    _sw.stop();
    final detik = _detik;
    final jarakKm = _jarakMeter / 1000.0;
    final mulai = _waktuMulai;
    setState(() {
      _tracking = false;
      _paused = false;
    });
    if (sudahJalan && detik > 0 && mulai != null) {
      await RunHistory.add(
        RunRecord(waktuMulai: mulai, jarakKm: jarakKm, durasiDetik: detik),
      );
      _pesan(
        'Lari selesai: ${jarakKm.toStringAsFixed(2)} km dalam '
        '${formatDurasi(detik)}',
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatLariScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jarakKm = _jarakMeter / 1000.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('JASMANI TRACKER'),
        actions: [
          IconButton(
            tooltip: 'Riwayat Lari',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiwayatLariScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(initialCenter: _posisi, initialZoom: 16),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mulia754.jasmani_flutter',
              ),
              if (_rute.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: List.of(_rute),
                      strokeWidth: 6,
                      color: AppColors.neonCyan,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
              if (_adaPosisi)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _posisi,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.neonCyanDim),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _Stat(
                          label: 'JARAK (KM)',
                          nilai: jarakKm.toStringAsFixed(2),
                          besar: true,
                        ),
                        _Stat(label: 'WAKTU', nilai: formatDurasi(_detik)),
                        _Stat(
                          label: 'PACE',
                          nilai: formatPace(jarakKm, _detik),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: !_tracking
                                ? _mulai
                                : (_paused ? _lanjut : _jeda),
                            icon: Icon(
                              !_tracking || _paused
                                  ? Icons.play_arrow
                                  : Icons.pause,
                            ),
                            label: Text(
                              !_tracking
                                  ? 'Mulai'
                                  : (_paused ? 'Lanjut' : 'Jeda'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _tracking ? _selesai : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Selesai'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neonCyan,
                              side: const BorderSide(
                                color: AppColors.neonCyanDim,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String nilai;
  final bool besar;

  const _Stat({required this.label, required this.nilai, this.besar = false});

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
            style: TextStyle(
              color: besar ? AppColors.neonCyan : AppColors.textPrimary,
              fontSize: besar ? 30 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
