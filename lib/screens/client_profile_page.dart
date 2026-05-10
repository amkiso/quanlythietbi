import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_confirm_dialog.dart';

/// ═══════════════════════════════════════════════════════
///  CLIENT PROFILE PAGE — Hồ sơ cá nhân (vaiTroId=4)
/// ═══════════════════════════════════════════════════════
class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _buildHeader(auth),
                  const SizedBox(height: 16),
                  _buildOrderSection(),
                  const SizedBox(height: 16),
                  _buildMenuItem(context, 'Hồ sơ cá nhân', () {}),
                  const SizedBox(height: 10),
                  _buildMenuItem(context, 'Đổi mật khẩu', () {}),
                  const SizedBox(height: 10),
                  _buildMenuItem(context, 'Góp ý', () {}),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                      context, 'Điều khoảng và chính sách sử dụng', () {}),
                  const SizedBox(height: 16),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Header: Avatar + Tên + SĐT ───
  Widget _buildHeader(AuthProvider auth) {
    final name = auth.hoTen ?? 'Người dùng';
    final phone = auth.maNguoiDung ?? '0123456789';
    final nameEncoded = Uri.encodeComponent(name);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: DecorationImage(
                image: NetworkImage(
                  'https://ui-avatars.com/api/?name=$nameEncoded&background=4A6CF7&color=fff&size=200',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  phone,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Đơn hàng ───
  Widget _buildOrderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Xem lịch sử thuê hàng >',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatus(Icons.assignment_outlined, 'Chờ xét duyệt'),
              _buildOrderStatus(Icons.account_balance_wallet_outlined, 'Cần thanh toán'),
              _buildOrderStatus(Icons.inventory_2_outlined, 'Chờ giao hàng'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Menu Item ───
  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── Đăng xuất ───
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Đăng xuất',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Đăng xuất',
      content: 'Bạn có muốn đăng xuất không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Icons.logout,
      confirmColor: AppColors.error,
    );
    if (confirmed && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
