import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';

/// ═══════════════════════════════════════════════════════
///  ORDER SUMMARY CARD — Chi tiết hóa đơn
///  Hiển thị: Tổng tiền, Tiền cọc, Tháng đầu, Thuế VAT,
///  Phí phạt quá hạn, Phí bồi thường, Thành tiền
/// ═══════════════════════════════════════════════════════
class OrderSummaryCard extends StatefulWidget {
  final OrderSummary? summary;
  final bool hasFullData; // Đã chọn đủ thời lượng + thanh toán

  const OrderSummaryCard({
    super.key,
    this.summary,
    this.hasFullData = false,
  });

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  bool _isExpanded = false;
  final _fmt = NumberFormat('#,###', 'vi_VN');

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

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
      child: Column(
        children: [
          // ── Header (collapsible) ──
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết hóa đơn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.textHint,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Tổng tiền
                _buildRow(
                  'Tổng tiền:',
                  summary != null && widget.hasFullData && summary.tongTien > 0
                      ? '${_fmt.format(summary.tongTien)} đ/ ${summary.tongTienLabel ?? ''}'
                      : 'Không xác định',
                  isHighlight:
                      widget.hasFullData && (summary?.tongTien ?? 0) > 0,
                ),
                const SizedBox(height: 8),

                // Tiền cọc
                _buildRow(
                  'Tiền cọc (1 tháng):',
                  '${_fmt.format(summary?.tienCoc ?? 0)} đ',
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 8),

                // Tháng đầu
                _buildRow(
                  'Tháng đầu:',
                  '${_fmt.format(summary?.thangDau ?? 0)} đ',
                  valueColor: AppColors.primary,
                ),
                const SizedBox(height: 8),

                // Thuế VAT
                _buildRow(
                  'Thuế VAT (10%):',
                  widget.hasFullData && (summary?.thueVAT ?? 0) > 0
                      ? '${_fmt.format(summary!.thueVAT)} đ'
                      : 'Không xác định',
                  isHighlight:
                      widget.hasFullData && (summary?.thueVAT ?? 0) > 0,
                ),
                const SizedBox(height: 12),

                // ── Phí phạt ──
                _buildPenaltyRow(
                  'Phí phạt quá hạn:',
                  'Xem chi tiết ',
                  'hợp đồng',
                ),
                const SizedBox(height: 6),
                _buildPenaltyRow(
                  'Phí bồi thường hư hại thiết bị:',
                  'Xem chi tiết ',
                  'hợp đồng',
                ),

                const SizedBox(height: 12),

                // ── Thành tiền ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thành tiền (tạm tính):',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.hasFullData && (summary?.thanhTien ?? 0) > 0
                          ? '${_fmt.format(summary!.thanhTien)} đ'
                          : '0 đ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: widget.hasFullData && (summary?.thanhTien ?? 0) > 0
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: valueColor ??
                (isHighlight ? AppColors.textPrimary : AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyRow(
    String label,
    String linkPrefix,
    String linkText,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
        ),
        Text(
          linkPrefix,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          linkText,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
