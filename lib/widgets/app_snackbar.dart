import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// SnackBar helper - hiển thị thông báo nhanh
class AppSnackBar {
  AppSnackBar._();

  /// Thông báo thành công
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppColors.success, Icons.check_circle_outline);
  }

  /// Thông báo lỗi
  static void showError(BuildContext context, String message) {
    _show(context, message, AppColors.error, Icons.error_outline);
  }

  /// Thông báo cảnh báo
  static void showWarning(BuildContext context, String message) {
    _show(context, message, AppColors.warning, Icons.warning_amber);
  }

  /// Thông báo thông tin
  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.info, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppDimens.iconSM),
            const SizedBox(width: AppDimens.paddingSM),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSM),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
