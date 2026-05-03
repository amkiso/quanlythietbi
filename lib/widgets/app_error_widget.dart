import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget hiển thị lỗi - tái sử dụng cho mọi màn hình
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String retryText;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryText = 'Thử lại',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimens.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimens.paddingMD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimens.paddingMD),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppDimens.iconSM),
                label: Text(retryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
