import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Logo / Branding widget - hiển thị ở splash, login
class AppLogo extends StatelessWidget {
  final double iconSize;
  final bool showTitle;
  final bool showSubtitle;
  final String? subtitle;

  const AppLogo({
    super.key,
    this.iconSize = AppDimens.iconHero,
    this.showTitle = true,
    this.showSubtitle = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.devices_other,
          size: iconSize,
          color: theme.colorScheme.primary,
        ),
        if (showTitle) ...[
          const SizedBox(height: AppDimens.paddingMD),
          Text(
            'Quản Lý Thiết Bị',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
        if (showSubtitle && subtitle != null) ...[
          const SizedBox(height: AppDimens.paddingSM),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}
