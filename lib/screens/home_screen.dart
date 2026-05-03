import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import '../widgets/app_confirm_dialog.dart';
import 'placeholder_page.dart';
import 'admin_dashboard_page.dart';

/// ═══════════════════════════════════════════════════════
///  HomeScreen — Bottom Navigation theo vai trò (VaiTroID)
/// ═══════════════════════════════════════════════════════
///
/// Đọc tenVaiTro từ AuthProvider và hiển thị Bottom Nav Bar
/// với các tab tương ứng:
///
/// - Khách hàng:   Trang chủ, Danh mục, Giỏ hàng, Hợp đồng, Cá nhân
/// - Thủ kho:      Dashboard, Kho, Hợp đồng, Nhập kho, Cá nhân
/// - Kỹ thuật viên: Dashboard, Giao nhận, Bảo trì, Sự cố, Cá nhân
/// - Admin:        Dashboard, Hợp đồng, Thiết bị, Nhân viên, Báo cáo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tenVaiTro = auth.tenVaiTro ?? '';

    // Admin sử dụng custom nav bar với nút Quét QR nổi
    if (tenVaiTro == 'Admin') {
      return _buildAdminScaffold();
    }

    final config = _getNavConfig(tenVaiTro);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: config.pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
          elevation: 0,
          items: config.items,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  ADMIN SCAFFOLD — Custom floating nav bar
  // ═══════════════════════════════════════════════════

  /// Danh sách các trang cho Admin
  List<Widget> get _adminPages => [
        const AdminDashboardPage(),
        const PlaceholderPage(
          title: 'Danh mục thiết bị',
          icon: Icons.grid_view_rounded,
        ),
        const PlaceholderPage(
          title: 'Quét QR',
          icon: Icons.qr_code_scanner_rounded,
        ),
        const PlaceholderPage(
          title: 'Lịch sử giao dịch',
          icon: Icons.access_time_filled,
        ),
        _buildProfilePage(),
      ];

  Widget _buildAdminScaffold() {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _adminPages,
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  NAVIGATION CONFIG PER ROLE
  // ═══════════════════════════════════════════════════

  _NavConfig _getNavConfig(String tenVaiTro) {
    switch (tenVaiTro) {
      case 'Khách hàng':
        return _NavConfig(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category_rounded),
              label: 'Danh mục',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description_rounded),
              label: 'Hợp đồng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
          pages: [
            const PlaceholderPage(
              title: 'Trang chủ',
              icon: Icons.home_rounded,
            ),
            const PlaceholderPage(
              title: 'Danh mục thiết bị',
              icon: Icons.category_rounded,
            ),
            const PlaceholderPage(
              title: 'Giỏ hàng',
              icon: Icons.shopping_cart_rounded,
            ),
            const PlaceholderPage(
              title: 'Hợp đồng của tôi',
              icon: Icons.description_rounded,
            ),
            _buildProfilePage(),
          ],
        );

      case 'Thủ kho':
        return _NavConfig(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warehouse_outlined),
              activeIcon: Icon(Icons.warehouse_rounded),
              label: 'Kho',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description_rounded),
              label: 'Hợp đồng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.move_to_inbox_outlined),
              activeIcon: Icon(Icons.move_to_inbox_rounded),
              label: 'Nhập kho',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
          pages: [
            const PlaceholderPage(
              title: 'Dashboard',
              icon: Icons.dashboard_rounded,
            ),
            const PlaceholderPage(
              title: 'Quản lý Kho',
              icon: Icons.warehouse_rounded,
            ),
            const PlaceholderPage(
              title: 'Hợp đồng',
              icon: Icons.description_rounded,
            ),
            const PlaceholderPage(
              title: 'Nhập kho',
              icon: Icons.move_to_inbox_rounded,
            ),
            _buildProfilePage(),
          ],
        );

      case 'Kỹ thuật viên':
        return _NavConfig(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping_rounded),
              label: 'Giao nhận',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build_rounded),
              label: 'Bảo trì',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber_rounded),
              label: 'Sự cố',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
          pages: [
            const PlaceholderPage(
              title: 'Dashboard',
              icon: Icons.dashboard_rounded,
            ),
            const PlaceholderPage(
              title: 'Giao nhận',
              icon: Icons.local_shipping_rounded,
            ),
            const PlaceholderPage(
              title: 'Bảo trì',
              icon: Icons.build_rounded,
            ),
            const PlaceholderPage(
              title: 'Sự cố',
              icon: Icons.warning_amber_rounded,
            ),
            _buildProfilePage(),
          ],
        );

      case 'Admin':
        return _NavConfig(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description_rounded),
              label: 'Hợp đồng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices_outlined),
              activeIcon: Icon(Icons.devices_rounded),
              label: 'Thiết bị',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Nhân viên',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Báo cáo',
            ),
          ],
          pages: [
            const PlaceholderPage(
              title: 'Dashboard',
              icon: Icons.dashboard_rounded,
            ),
            const PlaceholderPage(
              title: 'Quản lý Hợp đồng',
              icon: Icons.description_rounded,
            ),
            const PlaceholderPage(
              title: 'Quản lý Thiết bị',
              icon: Icons.devices_rounded,
            ),
            const PlaceholderPage(
              title: 'Quản lý Nhân viên',
              icon: Icons.people_rounded,
            ),
            const PlaceholderPage(
              title: 'Báo cáo & Thống kê',
              icon: Icons.analytics_rounded,
            ),
          ],
        );

      default:
        // Fallback — vai trò không xác định
        return _NavConfig(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Cá nhân',
            ),
          ],
          pages: [
            const PlaceholderPage(
              title: 'Trang chủ',
              icon: Icons.home_rounded,
            ),
            _buildProfilePage(),
          ],
        );
    }
  }

  // ═══════════════════════════════════════════════════
  //  PROFILE / PERSONAL PAGE (shared across roles)
  // ═══════════════════════════════════════════════════

  Widget _buildProfilePage() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── Avatar ──
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Name ──
                  Text(
                    auth.hoTen ?? 'Người dùng',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Role badge ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      auth.tenVaiTro ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Menu Items ──
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      // TODO: Navigate to change password screen
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Thông tin ứng dụng',
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Logout Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textSecondary),
              const SizedBox(width: 14),
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
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  LOGOUT
  // ═══════════════════════════════════════════════════

  Future<void> _handleLogout() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Đăng xuất',
      content: 'Bạn có muốn đăng xuất không?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Icons.logout,
      confirmColor: AppColors.error,
    );

    if (confirmed && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}

// ═══════════════════════════════════════════════════
//  HELPER CLASS
// ═══════════════════════════════════════════════════

class _NavConfig {
  final List<BottomNavigationBarItem> items;
  final List<Widget> pages;

  const _NavConfig({
    required this.items,
    required this.pages,
  });
}
