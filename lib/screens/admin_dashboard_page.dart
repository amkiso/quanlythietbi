import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_data.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

/// Trang chủ Admin — Dashboard
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showRevenue = false;
  late final PageController _panelController;
  int _currentPanel = 0;
  Timer? _reminderTimer;
  late final PageController _reminderController;
  int _currentReminder = 0;

  // Màu sắc dashboard
  static const Color _darkBg = Color(0xFF1F2937);
  static const Color _accentBlue = Color(0xFF4A6CF7);
  static const Color _accentRed = Color(0xFFE85D5D);
  static const Color _accentAmber = Color(0xFFF5A623);
  static const Color _cardBg = Color(0xFFF7F8FC);

  @override
  void initState() {
    super.initState();
    _panelController = PageController(viewportFraction: 0.75);
    _reminderController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard().then((_) {
        _startReminderAutoScroll();
      });
    });
  }

  void _startReminderAutoScroll() {
    final reminders = context.read<DashboardProvider>().nhacNhoHomNay;
    if (reminders.length <= 1) return;
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentReminder + 1) % reminders.length;
      _reminderController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _panelController.dispose();
    _reminderController.dispose();
    _reminderTimer?.cancel();
    super.dispose();
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
      backgroundColor: _cardBg,
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading && dashboard.data == null) {
            return const Center(
              child: CircularProgressIndicator(color: _accentBlue),
            );
          }
          return RefreshIndicator(
            color: _accentBlue,
            onRefresh: dashboard.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(dashboard),
                  _buildActionGrid(),
                  _buildReminderSection(dashboard),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PHẦN ĐẦU — Header + Stat Panels
  // ═══════════════════════════════════════════════════
  Widget _buildHeader(DashboardProvider dashboard) {
    return Container(
      decoration: const BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar: Logo + bell + avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  // Xypher logo
                  _buildXypherLogo(),
                  const Spacer(),
                  // Notification bell
                  _buildIconButton(
                    Icons.notifications_outlined,
                    badge: dashboard.nhacNhoHomNay.length,
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  _buildAvatar(),
                ],
              ),
            ),
            // Stat panels
            SizedBox(
              height: 150,
              child: PageView(
                controller: _panelController,
                onPageChanged: (i) => setState(() => _currentPanel = i),
                children: [
                  _buildRevenuePanel(dashboard),
                  _buildMaintenancePanel(dashboard),
                  _buildContractPanel(dashboard),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPanel == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPanel == i
                        ? _accentBlue
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildXypherLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: const LinearGradient(
              colors: [_accentBlue, Color(0xFF6B7FFF)],
            ),
          ),
          child: const Center(
            child: Text('X',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Xypher',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {int badge = 0}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        if (badge > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: _accentRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge > 9 ? '9+' : '$badge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    final auth = context.watch<AuthProvider>();
    final name = auth.hoTen ?? 'A';
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accentBlue, Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Liquid Glass Panel helper ──
  Widget _buildGlassPanel({
    required Widget child,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Revenue Panel ──
  Widget _buildRevenuePanel(DashboardProvider d) {
    final growth = d.tiLeTangTruong;
    final isPositive = growth >= 0;

    return _buildGlassPanel(
      accentColor: _accentBlue,
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
                  color: _accentBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Doanh thu\ntháng này',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3)),
              ),
              GestureDetector(
                onTap: () => setState(() => _showRevenue = !_showRevenue),
                child: Icon(
                  _showRevenue ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _showRevenue
                ? '${_formatCurrency(d.doanhThuThangNay)} VNĐ'
                : _maskCurrency(d.doanhThuThangNay),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? const Color(0xFF4ADE80) : _accentRed,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${growth.toStringAsFixed(0)}% so với tháng trước',
                style: TextStyle(
                  color: isPositive ? const Color(0xFF4ADE80) : _accentRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to revenue detail
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Maintenance Panel ──
  Widget _buildMaintenancePanel(DashboardProvider d) {
    return _buildGlassPanel(
      accentColor: _accentRed,
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
                  color: _accentRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Thiết bị\ncần bảo trì',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3)),
              ),
            ],
          ),
          Text(
            '${d.soThietBiDangBaoTri.toString().padLeft(2, '0')} thiết bị',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to maintenance list
            },
            child: Row(
              children: [
                Text(
                  'Xem danh sách bảo trì',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Contract Panel ──
  Widget _buildContractPanel(DashboardProvider d) {
    return _buildGlassPanel(
      accentColor: _accentAmber,
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
                  color: _accentAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Hợp đồng\nđến hạn',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3)),
              ),
            ],
          ),
          Text(
            '${d.soHopDongDenHan.toString().padLeft(2, '0')} hợp đồng',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to contract list
            },
            child: Row(
              children: [
                Text(
                  'Xem chi tiết hợp đồng',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.7), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PHẦN GIỮA — Action Grid
  // ═══════════════════════════════════════════════════
  Widget _buildActionGrid() {
    final actions = [
      _ActionItem(Icons.description_outlined, 'Hợp đồng\ncho thuê',
          const Color(0xFF4A6CF7), () {}),
      _ActionItem(Icons.settings_outlined, 'Bảo trì\nthiết bị',
          const Color(0xFF6B7280), () {}),
      _ActionItem(Icons.business_outlined, 'Đơn vị\nthuê',
          const Color(0xFF8B5CF6), () {}),
      _ActionItem(Icons.calendar_month_outlined, 'Lịch trình',
          const Color(0xFF4A6CF7), () {}),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) => _buildActionButton(a)).toList(),
      ),
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(action.icon, color: action.color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A3D4E),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  PHẦN DƯỚI — Reminder Slider
  // ═══════════════════════════════════════════════════
  Widget _buildReminderSection(DashboardProvider dashboard) {
    final reminders = dashboard.nhacNhoHomNay;
    if (reminders.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green.shade400, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Không có nhắc nhở nào hôm nay',
                  style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      height: 90,
      child: PageView.builder(
        controller: _reminderController,
        itemCount: reminders.length,
        onPageChanged: (i) => setState(() => _currentReminder = i),
        itemBuilder: (context, index) {
          final item = reminders[index];
          return _buildReminderCard(item);
        },
      ),
    );
  }

  Widget _buildReminderCard(NhacNhoItem item) {
    final isContract = item.loai == 'HOP_DONG';
    final color = isContract ? _accentAmber : _accentRed;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time + HÔM NAY
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(timeStr,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const Text('HÔM NAY',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280))),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: const Color(0xFFE5E7EB),
          ),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.tieuDe,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(item.moTa,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 24),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionItem(this.icon, this.label, this.color, this.onTap);
}
