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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 450),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 60,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfileInfoBox(auth),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                                    child: Column(
                                      children: [
                                        _buildMenuItem(Icons.person_outline, 'Hồ sơ cá nhân', () {}),
                                        _buildMenuItem(Icons.lock_outline, 'Đổi mật khẩu', () {}),
                                        _buildManageMenu(context),
                                        _buildMenuItem(Icons.chat_bubble_outline, 'Góp ý', () {}),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
                                    child: _buildLogoutButton(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInfoBox(AuthProvider auth) {
    final name = auth.hoTen?.isNotEmpty == true ? auth.hoTen! : 'Người dùng';
    final nameEncoded = Uri.encodeComponent(name);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF6077FC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6077FC).withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage('https://ui-avatars.com/api/?name=$nameEncoded&background=667eea&color=fff&size=200'),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    auth.maNguoiDung ?? '0123 456 789',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
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

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF999999), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_outlined, color: Color(0xFF667EEA), size: 20),
            ),
            title: const Text(
              'Quản lý',
              style: TextStyle(
                color: Color(0xFF444444),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconColor: const Color(0xFF999999),
            collapsedIconColor: const Color(0xFF999999),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: [
              _buildSubMenuItem(Icons.notifications_outlined, 'Thông báo'),
              _buildSubMenuItem(Icons.people_outline, 'Người dùng'),
              _buildSubMenuItem(Icons.devices_outlined, 'Thiết bị'),
              _buildSubMenuItem(Icons.description_outlined, 'Hợp đồng'),
              _buildSubMenuItem(Icons.article_outlined, 'Điều khoản'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 6),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF6077FC), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _handleLogout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
          ],
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
