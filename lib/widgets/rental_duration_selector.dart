import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';

/// ═══════════════════════════════════════════════════════
///  RENTAL DURATION SELECTOR — Chọn thời lượng thuê
///  Dropdown + Date pickers cho ngày bắt đầu / kết thúc
/// ═══════════════════════════════════════════════════════
class RentalDurationSelector extends StatelessWidget {
  final RentalDuration? selectedDuration;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<RentalDuration> onDurationSelected;
  final VoidCallback? onTapStartDate;
  final VoidCallback? onTapEndDate;

  const RentalDurationSelector({
    super.key,
    this.selectedDuration,
    this.startDate,
    this.endDate,
    required this.onDurationSelected,
    this.onTapStartDate,
    this.onTapEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MM/dd/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──
          Text(
            'thời lượng thuê',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // ── Dropdown ──
          InkWell(
            onTap: () => _showDurationPicker(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDuration?.label ?? '6 tháng, 1 năm,...',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDuration != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Date pickers ──
          Row(
            children: [
              // Từ ngày
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Từ ngày ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '(*)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: onTapStartDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                startDate != null
                                    ? dateFmt.format(startDate!)
                                    : 'mm/dd/yyyy',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: startDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Dự kiến trả
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Dự kiến trả ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '(*)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: onTapEndDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: endDate != null
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: endDate != null
                              ? AppColors.primarySurface.withValues(alpha: 0.3)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                endDate != null
                                    ? dateFmt.format(endDate!)
                                    : 'mm/dd/yyyy',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: endDate != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: endDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: endDate != null
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
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
                'Chọn thời lượng thuê',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...RentalDuration.options.map(
                (option) => ListTile(
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          selectedDuration?.months == option.months
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          selectedDuration?.months == option.months
                              ? AppColors.primary
                              : AppColors.textPrimary,
                    ),
                  ),
                  trailing:
                      selectedDuration?.months == option.months
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                  onTap: () {
                    onDurationSelected(option);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
