import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';

/// ═══════════════════════════════════════════════════════
///  PAYMENT METHOD SELECTOR — Chọn phương thức thanh toán
///  Hiển thị phương thức đã chọn và mở BottomSheet để thay đổi
/// ═══════════════════════════════════════════════════════
class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentMethod> methods;
  final PaymentMethodType? selectedType;
  final ValueChanged<PaymentMethodType> onSelected;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMethod = methods.firstWhere(
      (m) => m.type == selectedType,
      orElse: () => methods.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentMethodBottomSheet(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getMethodColor(selectedMethod.type).withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: _getMethodIcon(selectedMethod.type),
                  ),
                ),
                const SizedBox(width: 12),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phương thức thanh toán',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedType != null ? selectedMethod.name : 'Chọn phương thức',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedType != null ? AppColors.textPrimary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...methods.map((method) => _buildBottomSheetTile(ctx, method)),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetTile(BuildContext context, PaymentMethod method) {
    final isSelected = selectedType == method.type;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _getMethodColor(method.type).withValues(alpha: 0.1),
        ),
        child: Center(
          child: _getMethodIcon(method.type),
        ),
      ),
      title: Text(
        method.name,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        onSelected(method.type);
        Navigator.pop(context);
      },
    );
  }

  Color _getMethodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.momo:
        return const Color(0xFFAE2070);
      case PaymentMethodType.zalopay:
        return const Color(0xFF008FE5);
      case PaymentMethodType.cash:
        return const Color(0xFF4CAF50); // Green for cash
    }
  }

  Widget _getMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.momo:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFAE2070),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'M',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case PaymentMethodType.zalopay:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF008FE5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Text(
              'Z',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case PaymentMethodType.cash:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
    }
  }
}
