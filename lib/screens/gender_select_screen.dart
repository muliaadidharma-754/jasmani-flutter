import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'fitness_test_screen.dart';

class GenderSelectScreen extends StatelessWidget {
  final String title;
  final FitnessTestConfig priaConfig;
  final FitnessTestConfig wanitaConfig;

  const GenderSelectScreen({
    super.key,
    required this.title,
    required this.priaConfig,
    required this.wanitaConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GenderCard(
                  label: 'PRIA',
                  icon: Icons.male,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FitnessTestScreen(config: priaConfig),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                _GenderCard(
                  label: 'WANITA',
                  icon: Icons.female,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FitnessTestScreen(config: wanitaConfig),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.neonCyanDim),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 48),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
