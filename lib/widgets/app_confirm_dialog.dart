import 'package:flutter/material.dart';

/// Dialog xác nhận hành động - tái sử dụng
/// Trả về true nếu xác nhận, false nếu hủy
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.confirmColor,
    this.icon,
  });

  /// Helper method: show dialog và trả kết quả
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null
          ? Icon(icon, color: confirmColor, size: 32)
          : null,
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: confirmColor != null
              ? TextButton.styleFrom(foregroundColor: confirmColor)
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
