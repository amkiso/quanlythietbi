import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/dashboard_data.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/checkout_service.dart';
import '../widgets/cloud_image.dart';
import 'client_notification_page.dart';
import 'placeholder_dev_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const AdminDashboardPage({super.key, this.onNavigateToProfile});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final CheckoutService _checkoutService = CheckoutService();
  int _notificationCount = 0;
  bool _showRevenue = false;

  late final PageController _panelController;
  int _currentPanel = 0;

  @override
  void initState() {
    super.initState();
    _panelController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final dio = _checkoutService.dio;
      final response = await dio.get('/thong-bao/chua-doc');
      final data = response.data;
      if (data['success'] == true && mounted) {
        setState(() => _notificationCount = (data['data'] ?? 0) as int);
      }
    } catch (_) {}
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      context.read<DashboardProvider>().loadDashboard(),
      _loadNotificationCount(),
    ]);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  String _maskCurrency(double amount) {
    return '*** *** *** VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          return RefreshIndicator(
            onRefresh: _refreshAll,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverHeader(dashboard),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hành động nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _buildActionGrid(),
                        const SizedBox(height: 24),
                        const Text('Nhắc nhở hôm nay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        _buildRemindersList(dashboard),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverHeader(DashboardProvider d) {
    final auth = context.watch<AuthProvider>();
    final nameEncoded = Uri.encodeComponent(auth.hoTen ?? 'Admin');

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B72F0), Color(0xFF7B8FF7)],
          ),
          // Không bo góc theo yêu cầu
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: Logo + Notification + Avatar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Xypher logo
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text('X', style: TextStyle(color: Color(0xFF5B72F0), fontSize: 18, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Xypher',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification bell
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientNotificationPage()));
                            },
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                                  if (_notificationCount > 0)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                                        child: Text(
                                          _notificationCount > 9 ? '9+' : '$_notificationCount',
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Avatar
                          GestureDetector(
                            onTap: widget.onNavigateToProfile,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipOval(
                                child: (auth.avt != null && auth.avt!.trim().isNotEmpty)
                                    ? CloudImage(imageUrl: Uri.encodeFull(auth.avt!.trim()), width: 42, height: 42, fit: BoxFit.cover)
                                    : Image.network('https://ui-avatars.com/api/?name=$nameEncoded&background=4A6CF7&color=fff&size=200', fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stat panels (Lướt ngang như trước)
                SizedBox(
                  height: 160,
                  child: PageView(
                    controller: _panelController,
                    onPageChanged: (i) => setState(() => _currentPanel = i),
                    children: [
                      _buildRevenuePanel(d),
                      _buildMaintenancePanel(d),
                      _buildContractPanel(d),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dot indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPanel == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPanel == i ? Colors.white : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPanel({required Widget child, Color? baseColor}) {
    final color = baseColor ?? Colors.white.withValues(alpha: 0.15);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildRevenuePanel(DashboardProvider d) {
    final growth = d.tiLeTangTruong;
    final isPositive = growth >= 0;

    return _buildGlassPanel(
      baseColor: const Color(0xFF3B52D0).withValues(alpha: 0.8), // Xanh đậm hơn nền
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Doanh thu\ntháng này', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              ),
              GestureDetector(
                onTap: () => setState(() => _showRevenue = !_showRevenue),
                child: Icon(
                  _showRevenue ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 22,
                ),
              ),
            ],
          ),
          Text(
            _showRevenue ? '${_formatCurrency(d.doanhThuThangNay)} VNĐ' : _maskCurrency(d.doanhThuThangNay),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: isPositive ? Colors.greenAccent : Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('so với tháng trước', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenancePanel(DashboardProvider d) {
    return _buildGlassPanel(
      baseColor: Colors.red.withValues(alpha: 0.8), // Màu đỏ
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Thiết bị\ncần bảo trì', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              ),
            ],
          ),
          Text(
            '${d.soThietBiDangBaoTri.toString().padLeft(2, '0')} thiết bị',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text('Xem danh sách bảo trì', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractPanel(DashboardProvider d) {
    return _buildGlassPanel(
      baseColor: Colors.orange.shade600.withValues(alpha: 0.9), // Vàng cam
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Hợp đồng\nđến hạn', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
              ),
            ],
          ),
          Text(
            '${d.soHopDongDenHan.toString().padLeft(2, '0')} hợp đồng',
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text('Xem chi tiết hợp đồng', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {'icon': Icons.description_outlined, 'title': 'Hợp đồng', 'color': AppColors.primary},
      {'icon': Icons.settings_outlined, 'title': 'Bảo trì', 'color': Colors.orange},
      {'icon': Icons.people_outline, 'title': 'Khách hàng', 'color': Colors.purple},
      {'icon': Icons.inventory_2_outlined, 'title': 'Kho', 'color': Colors.green},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) => GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceholderDevPage(title: a['title'] as String, icon: a['icon'] as IconData)));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(a['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildRemindersList(DashboardProvider d) {
    // 1. Phê duyệt đơn hàng
    // 2. Giao hàng cho hóa đơn đến hạn
    // 3. Thu hồi thiết bị trong hợp đồng hết/đến hạn
    // 4. Yêu cầu bảo trì thiết bị trong lúc sử dụng của hợp đồng
    
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Phê duyệt\nđơn hàng',
        'desc': '3 chờ duyệt',
        'icon': Icons.assignment_turned_in_outlined,
        'color': Colors.blue,
      },
      {
        'title': 'Giao hàng\nđến hạn',
        'desc': '2 đơn hàng',
        'icon': Icons.local_shipping_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Thu hồi\nthiết bị',
        'desc': '${d.soHopDongDenHan} hợp đồng',
        'icon': Icons.assignment_return_outlined,
        'color': Colors.redAccent,
      },
      {
        'title': 'Yêu cầu\nbảo trì',
        'desc': '${d.soThietBiDangBaoTri} thiết bị',
        'icon': Icons.build_circle_outlined,
        'color': Colors.purple,
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final r = tasks[index];
          final color = r['color'] as Color;
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceholderDevPage(title: r['title'].toString().replaceAll('\n', ' '), icon: r['icon'] as IconData)));
            },
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(r['icon'] as IconData, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(r['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(r['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
