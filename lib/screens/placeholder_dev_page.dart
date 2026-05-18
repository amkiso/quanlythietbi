import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Placeholder page for features under development
class PlaceholderDevPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderDevPage({
    super.key,
    required this.title,
    this.icon = Icons.construction_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tính năng đang phát triển',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Chúng tôi đang hoàn thiện tính năng "$title".\nVui lòng quay lại sau!',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(160, 46),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
