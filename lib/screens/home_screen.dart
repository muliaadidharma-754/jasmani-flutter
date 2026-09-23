import 'package:flutter/material.dart';
import '../data/test_configs.dart';
import '../theme/app_theme.dart';
import 'bmi_screen.dart';
import 'berat_screen.dart';
import 'gender_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 12),
              const Text(
                'JASMANI 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: [
                  _DashboardTile(
                    icon: Icons.timer,
                    label: '12 Menit',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenderSelectScreen(
                          title: '12 Menit',
                          priaConfig: testPria12,
                          wanitaConfig: testWanita12,
                        ),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.flag,
                    label: '3200 Meter',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenderSelectScreen(
                          title: '3200 Meter',
                          priaConfig: testPria3200,
                          wanitaConfig: testWanita3200,
                        ),
                      ),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Berat Ideal',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BeratScreen()),
                    ),
                  ),
                  _DashboardTile(
                    icon: Icons.straighten,
                    label: 'BMI',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BmiScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.neonCyanDim),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.amber, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
