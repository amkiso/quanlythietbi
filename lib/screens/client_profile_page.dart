import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/checkout_service.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/azure_image.dart';
import 'client_order_history_page.dart';
import 'placeholder_dev_page.dart';

/// CLIENT PROFILE PAGE — Hồ sơ cá nhân (vaiTroId=4)
class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final CheckoutService _checkoutService = CheckoutService();
  Map<String, dynamic> _donHangCount = {};

  @override
  void initState() {
    super.initState();
    _loadDonHangCount();
  }

  Future<void> _loadDonHangCount() async {
    try {
      final data = await _checkoutService.getDonHangCount();
      if (mounted) setState(() => _donHangCount = data);
    } catch (_) {}
  }

  void _navigateToHistory({int filter = -1}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientOrderHistoryPage(initialFilter: filter)),
    ).then((_) => _loadDonHangCount());
  }

  void _navigateTo(String title, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderDevPage(title: title, icon: icon)),
    );
  }

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
                  _buildMenuItemIcon(Icons.person_outline_rounded, 'Hồ sơ cá nhân', () => _navigateTo('Hồ sơ cá nhân', Icons.person_rounded)),
                  const SizedBox(height: 10),
                  _buildMenuItemIcon(Icons.lock_outline_rounded, 'Đổi mật khẩu', () => _navigateTo('Đổi mật khẩu', Icons.lock_rounded)),
                  const SizedBox(height: 10),
                  _buildMenuItemIcon(Icons.chat_bubble_outline_rounded, 'Góp ý', () => _navigateTo('Góp ý', Icons.chat_bubble_rounded)),
                  const SizedBox(height: 10),
                  _buildMenuItemIcon(Icons.policy_outlined, 'Điều khoản và chính sách sử dụng', () => _navigateTo('Điều khoản và chính sách sử dụng', Icons.policy_rounded)),
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
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: (auth.avt != null && auth.avt!.isNotEmpty)
                  ? AzureImage(imageUrl: auth.avt!, width: 52, height: 52, fit: BoxFit.cover)
                  : Image.network('https://ui-avatars.com/api/?name=$nameEncoded&background=4A6CF7&color=fff&size=200', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(phone, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    final choXetDuyet = _donHangCount['choXetDuyet'] ?? 0;
    final canThanhToan = _donHangCount['canThanhToan'] ?? 0;
    final choGiaoHang = _donHangCount['choGiaoHang'] ?? 0;

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
              const Text('Đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () => _navigateToHistory(),
                child: const Text('Xem lịch sử thuê hàng >', style: TextStyle(fontSize: 13, color: AppColors.textHint, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatus(Icons.assignment_outlined, 'Chờ xét duyệt', choXetDuyet, 1),
              _buildOrderStatus(Icons.account_balance_wallet_outlined, 'Cần thanh toán', canThanhToan, 2),
              _buildOrderStatus(Icons.inventory_2_outlined, 'Chờ giao hàng', choGiaoHang, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(IconData icon, String label, dynamic count, int filterStatus) {
    final c = (count is int) ? count : (count as num?)?.toInt() ?? 0;
    return GestureDetector(
      onTap: () => _navigateToHistory(filter: filterStatus),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              if (c > 0)
                Positioned(
                  top: -4, right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    child: Text('$c', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuItemIcon(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
        ]),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _handleLogout(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Đăng xuất', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context, title: 'Đăng xuất', content: 'Bạn có muốn đăng xuất không?',
      confirmText: 'Đăng xuất', cancelText: 'Hủy', icon: Icons.logout, confirmColor: AppColors.error,
    );
    if (confirmed && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
