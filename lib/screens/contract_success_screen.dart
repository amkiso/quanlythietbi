import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'contract_view_screen.dart';

/// ═══════════════════════════════════════════════════════
///  CONTRACT SUCCESS SCREEN — Màn hình gửi hợp đồng thành công
///  Hiển thị: Icon check + Thông báo + Nút Về trang chủ / Xem HD
/// ═══════════════════════════════════════════════════════
class ContractSuccessScreen extends StatelessWidget {
  final String maHopDong;
  final int hopDongId;

  const ContractSuccessScreen({
    super.key,
    required this.maHopDong,
    required this.hopDongId,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Main content ──
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Animated check icon ──
                      _buildSuccessIcon(),
                      const SizedBox(height: 32),

                      // ── Title ──
                      const Text(
                        'Đã gửi hợp đồng thành công',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chờ xét duyệt nhé!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Warning note ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Lưu ý: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        TextSpan(
                          text: 'Liên hệ để được xét duyệt sớm',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Bottom buttons ──
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPadding),
              child: Row(
                children: [
                  // Về Trang chủ
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(0, 0),
                        ),
                        child: const Text(
                          'Về Trang chủ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Xem HD
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pop toàn bộ checkout flow về trang chủ, rồi push ContractView
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContractViewScreen(hopDongId: hopDongId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(0, 0),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Xem HD',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Animated success checkmark icon with radiating circles
  Widget _buildSuccessIcon() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Middle ring
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          // Inner circle with checkmark
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
