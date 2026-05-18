import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Màn hình danh sách thông báo — placeholder
class ClientNotificationPage extends StatelessWidget {
  const ClientNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
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
                decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text('Tính năng đang phát triển', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Chúng tôi đang hoàn thiện tính năng "Thông báo".\nVui lòng quay lại sau!', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
