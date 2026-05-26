import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'contract_detail_screen.dart';

/// Màn hình thành công sau khi tạo hợp đồng
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon thành công ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                ),
                const SizedBox(height: 24),

                // ── Tiêu đề ──
                const Text(
                  'Đặt hợp đồng thành công!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Mã hợp đồng ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    maHopDong,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Thông báo trạng thái ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFF9A825), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hợp đồng đang ở trạng thái "Chờ xác nhận".\n'
                          'Nhân viên sẽ xem xét và liên hệ bạn sớm nhất.\n'
                          'Bạn có thể theo dõi trong mục "Đơn hàng".',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown[700],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Nút Xem chi tiết ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContractDetailScreen(hopDongId: hopDongId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.description_rounded, size: 20),
                    label: const Text('Xem chi tiết hợp đồng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Nút Về trang chủ ──
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text('Về trang chủ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
