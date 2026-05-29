import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import '../widgets/app_confirm_dialog.dart';
import 'placeholder_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_danh_muc_page.dart';
import 'client_home_page.dart';
import 'client_cart_page.dart';
import '../widgets/cloud_image.dart';
import 'client_profile_page.dart';
import 'qr_scanner_screen.dart';

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
  final GlobalKey<ClientHomePageState> _clientHomeKey = GlobalKey();

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
      floatingActionButton: (tenVaiTro == 'Thủ kho' || tenVaiTro == 'Kỹ thuật viên')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            )
          : null,
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
            if (index == _currentIndex && index == 0 && tenVaiTro == 'Khách hàng') {
              _clientHomeKey.currentState?.resetState();
            }
            // Reload giỏ hàng khi chuyển sang tab Giỏ hàng
            if (index == 1 && tenVaiTro == 'Khách hàng') {
              context.read<CartProvider>().loadCart();
            }
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

  List<Widget> get _adminPages => [
        const AdminDashboardPage(),
      const AdminDanhMucPage(),
        const QrScannerScreen(),
        const PlaceholderPage(
          title: 'Lịch sử giao dịch',
          icon: Icons.access_time_filled,
        ),
        const ClientProfilePage(),
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, child) => Badge(
                  isLabelVisible: cart.totalQuantity > 0,
                  label: Text('${cart.totalQuantity}',
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: AppColors.error,
                  child: child!,
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Consumer<CartProvider>(
                builder: (_, cart, child) => Badge(
                  isLabelVisible: cart.totalQuantity > 0,
                  label: Text('${cart.totalQuantity}',
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: AppColors.error,
                  child: child!,
                ),
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Giỏ hàng',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Hồ sơ',
            ),
          ],
          pages: [
            ClientHomePage(
              key: _clientHomeKey,
              onNavigateToProfile: () {
                setState(() => _currentIndex = 2);
              },
            ),
            const ClientCartPage(isEmbedded: true),
            const ClientProfilePage(),
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
            const AdminDashboardPage(),
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
            const ClientProfilePage(),
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
            const AdminDashboardPage(),
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
            const ClientProfilePage(),
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
            const ClientProfilePage(),
          ],
        );
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
