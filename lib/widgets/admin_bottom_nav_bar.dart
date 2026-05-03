import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════
///  Admin Bottom Navigation Bar
/// ═══════════════════════════════════════════════════
///
/// Custom bottom nav bar cho Admin với:
/// - 5 tab: Trang chủ, Danh mục, Quét QR (center floating), Lịch sử GD, Hồ sơ Ad
/// - Nút giữa (Quét QR) nổi lên trên nav bar với viền tròn
/// - Tab được chọn có icon và text màu xanh, text đậm
/// - Hiệu ứng chuyển đổi mượt mà

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // ── Màu sắc cho nav bar ──
  static const Color _activeColor = Color(0xFF4A6CF7);
  static const Color _inactiveColor = Color(0xFFB0B5C9);
  static const Color _navBarBg = Color(0xFFF2F3F8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Nav bar background ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: _navBarBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Tab 0: Trang chủ
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Trang chủ',
                    ),
                    // Tab 1: Danh mục
                    _buildNavItem(
                      index: 1,
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      label: 'Danh mục',
                    ),
                    // Tab 2: Spacer cho nút giữa
                    const SizedBox(width: 64),
                    // Tab 3: Lịch sử GD
                    _buildNavItem(
                      index: 3,
                      icon: Icons.access_time_outlined,
                      activeIcon: Icons.access_time_filled,
                      label: 'Lịch sử GD',
                    ),
                    // Tab 4: Hồ sơ Ad
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Hồ sơ Ad',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating Center Button (Quét QR) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Vòng tròn nổi ──
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _activeColor.withValues(alpha: 0.35),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _activeColor.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 30,
                        color: _activeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ── Label Quét QR ──
                    Text(
                      'Quét QR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: currentIndex == 2
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: currentIndex == 2
                            ? _activeColor
                            : _inactiveColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng một item nav bar thông thường (không phải nút giữa)
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon với animation ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey<bool>(isActive),
                  size: isActive ? 26 : 24,
                  color: isActive ? _activeColor : _inactiveColor,
                ),
              ),
              const SizedBox(height: 4),
              // ── Label ──
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? _activeColor : _inactiveColor,
                  height: 1.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
