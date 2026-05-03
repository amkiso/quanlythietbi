import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget hiển thị trạng thái rỗng (không có dữ liệu)
class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
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
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppDimens.paddingMD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppDimens.paddingMD),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: AppDimens.iconSM),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
