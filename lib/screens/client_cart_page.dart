import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/cart_provider.dart';
import '../models/gio_hang_item.dart';
import '../widgets/cloud_image.dart';
import 'client_checkout_page.dart';

/// ═══════════════════════════════════════════════════════
///  CART PAGE — Giỏ hàng (Client)
///  KHÔNG dùng Scaffold riêng vì embed trong IndexedStack
///  → tránh lỗi unconstrained width từ nested Scaffold
/// ═══════════════════════════════════════════════════════
class ClientCartPage extends StatefulWidget {
  final bool isEmbedded;
  const ClientCartPage({super.key, this.isEmbedded = false});

  @override
  State<ClientCartPage> createState() => _ClientCartPageState();
}

class _ClientCartPageState extends State<ClientCartPage> {
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');

  /// Set chứa gioHangId được chọn
  final Set<int> _selectedIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>();
      if (!cart.isInitialized) cart.loadCart();
    });
  }

  Future<void> _refreshCart() async {
    await context.read<CartProvider>().loadCart();
  }

  // ── Toggle chọn item ──
  void _toggleItem(int gioHangId) {
    setState(() {
      if (_selectedIds.contains(gioHangId)) {
        _selectedIds.remove(gioHangId);
      } else {
        _selectedIds.add(gioHangId);
      }
      _syncSelectAll();
    });
  }

  // ── Toggle chọn tất cả ──
  void _toggleSelectAll(List<GioHangItem> items) {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedIds.addAll(items.map((e) => e.gioHangId));
      } else {
        _selectedIds.clear();
      }
    });
  }

  void _syncSelectAll() {
    final items = context.read<CartProvider>().items;
    _selectAll = items.isNotEmpty && items.every((e) => _selectedIds.contains(e.gioHangId));
  }

  // ── Tính tổng tiền items được chọn ──
  double _selectedTotal(List<GioHangItem> items) {
    return items
        .where((item) => _selectedIds.contains(item.gioHangId))
        .fold(0.0, (sum, item) => sum + item.thanhTien);
  }

  int _selectedQuantity(List<GioHangItem> items) {
    return items
        .where((item) => _selectedIds.contains(item.gioHangId))
        .fold(0, (sum, item) => sum + item.soLuong);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        // Clean up selected IDs that no longer exist
        _selectedIds.removeWhere(
            (id) => !cart.items.any((item) => item.gioHangId == id));

        return Column(
          children: [
            // ═══ App Bar ═══
            _buildAppBar(),

            // ═══ Body ═══
            Expanded(
              child: _buildBody(cart),
            ),

            // ═══ Bottom bar: Chọn tất cả + Tổng tiền + Đặt thuê ═══
            if (cart.items.isNotEmpty)
              _buildBottomBar(cart, bottomPadding),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  //  APP BAR — Custom (không dùng Scaffold AppBar)
  // ═══════════════════════════════════════════════════

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!widget.isEmbedded)
                Positioned(
                  left: 4,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              const Text(
                'Giỏ hàng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  BODY — Nội dung chính
  // ═══════════════════════════════════════════════════

  Widget _buildBody(CartProvider cart) {
    if (cart.isLoading && !cart.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (cart.error != null && cart.items.isEmpty) {
      return _buildErrorState(cart);
    }

    if (cart.items.isEmpty) {
      return _buildEmptyCart();
    }

    return RefreshIndicator(
      onRefresh: _refreshCart,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Lưu ý banner
          _buildNoticeBanner(),
          const SizedBox(height: 12),
          // Cart items
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCartItemCard(item),
              )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  BOTTOM BAR — Tổng tiền + Đặt thuê
  //  KHÔNG dùng Expanded trong Row → tránh infinite width
  // ═══════════════════════════════════════════════════

  Widget _buildBottomBar(CartProvider cart, double bottomPadding) {
    final selectedTotal = _selectedTotal(cart.items);
    final selectedQty = _selectedQuantity(cart.items);
    final hasSelection = _selectedIds.isNotEmpty;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Checkbox chọn tất cả ──
          GestureDetector(
            onTap: () => _toggleSelectAll(cart.items),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _selectAll,
                    onChanged: (_) => _toggleSelectAll(cart.items),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Tổng tiền ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tạm tính:',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                hasSelection
                    ? '${_fmt.format(selectedTotal)} đ'
                    : '0 đ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: hasSelection
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
          const Spacer(),
          // ── Nút Đặt thuê ──
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: hasSelection
                  ? () {
                      final selectedItems = cart.items
                          .where((item) =>
                              _selectedIds.contains(item.gioHangId))
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientCheckoutPage(
                            selectedItems: selectedItems,
                            tongTamTinh: selectedTotal,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.textDisabled,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: hasSelection ? 2 : 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: Text(
                hasSelection
                    ? 'Đặt thuê ($selectedQty)'
                    : 'Chọn thiết bị',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  CART ITEM CARD — Với checkbox chọn
  // ═══════════════════════════════════════════════════

  Widget _buildCartItemCard(GioHangItem item) {
    final isSelected = _selectedIds.contains(item.gioHangId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Checkbox ──
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleItem(item.gioHangId),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            // ── Ảnh sản phẩm ──
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CloudImage(
                  imageUrl: item.anhDaiDien,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.devices_rounded,
                  fallbackIconSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // ── Thông tin — dùng Flexible thay Expanded ──
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tên + nút xóa
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          item.tenLoaiThietBi,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () async {
                          final cart = context.read<CartProvider>();
                          final name = item.tenLoaiThietBi;
                          await cart.removeItem(item.gioHangId);
                          _selectedIds.remove(item.gioHangId);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa "$name"'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Giá thuê
                  Text(
                    '${_fmt.format(item.giaThueThamKhao)} đ / tháng',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Quantity controls + thành tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Thành tiền
                      Text(
                        '${_fmt.format(item.thanhTien)} đ',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      // Quantity buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQtyBtn(
                            icon: Icons.remove,
                            onTap: () => context
                                .read<CartProvider>()
                                .decreaseQuantity(item.gioHangId),
                            enabled: item.soLuong > 1,
                          ),
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                '${item.soLuong}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          _buildQtyBtn(
                            icon: Icons.add,
                            onTap: () => context
                                .read<CartProvider>()
                                .increaseQuantity(item.gioHangId),
                            enabled: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySurface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider,
          ),
        ),
        child: Icon(icon, size: 14,
            color: enabled ? AppColors.primary : AppColors.textDisabled),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  NOTICE BANNER
  // ═══════════════════════════════════════════════════

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Lưu ý: Thiết bị chưa được giữ chỗ cho đến khi bạn xác nhận tạo Hợp đồng và được công ty phê duyệt.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  ERROR STATE
  // ═══════════════════════════════════════════════════

  Widget _buildErrorState(CartProvider cart) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            const Text('Không thể tải giỏ hàng',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(cart.error ?? 'Đã xảy ra lỗi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                cart.clearError();
                cart.loadCart();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  EMPTY CART
  // ═══════════════════════════════════════════════════

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text('Giỏ hàng trống',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm thiết bị vào giỏ hàng\nđể bắt đầu đặt thuê',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
