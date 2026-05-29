import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/gio_hang_item.dart';
import '../models/checkout_models.dart';
import '../services/checkout_mock_data.dart';
import '../services/checkout_service.dart';
import '../widgets/address_card.dart';
import '../widgets/cloud_image.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/rental_duration_selector.dart';
import '../widgets/order_summary_card.dart';
import 'add_address_screen.dart';
import 'contract_success_screen.dart';

/// ═══════════════════════════════════════════════════════
///  CHECKOUT PAGE — Thanh toán
///  Luồng: Chọn địa chỉ → Sản phẩm → Thanh toán →
///          Thời lượng → Hóa đơn → Đặt thuê → Hợp đồng
/// ═══════════════════════════════════════════════════════
class ClientCheckoutPage extends StatefulWidget {
  final List<GioHangItem> selectedItems;
  final double tongTamTinh;

  const ClientCheckoutPage({
    super.key,
    required this.selectedItems,
    required this.tongTamTinh,
  });

  @override
  State<ClientCheckoutPage> createState() => _ClientCheckoutPageState();
}

class _ClientCheckoutPageState extends State<ClientCheckoutPage> {
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');
  final CheckoutService _checkoutService = CheckoutService();

  // ── State ──
  DeliveryAddress? _address;
  PaymentMethodType? _selectedPaymentMethod;
  RentalDuration? _selectedDuration;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _noteToShop;
  bool _isPlacingOrder = false;

  // ── Danh sách địa chỉ từ API ──
  List<DeliveryAddress> _addresses = [];
  bool _isLoadingAddresses = true;

  // ── Computed ──
  bool get _isReadyToOrder =>
      _address != null &&
      _selectedPaymentMethod != null &&
      _selectedDuration != null &&
      _startDate != null;

  OrderSummary get _orderSummary => CheckoutMockData.calculateOrderSummary(
        items: widget.selectedItems,
        duration: _selectedDuration,
      );

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  /// Load danh sách địa chỉ từ API
  Future<void> _loadAddresses() async {
    try {
      final addresses = await _checkoutService.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _isLoadingAddresses = false;
        // Auto-select địa chỉ mặc định
        final defaultAddr = addresses.where((a) => a.laMacDinh).firstOrNull;
        _address ??= defaultAddr ?? (addresses.isNotEmpty ? addresses.first : null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingAddresses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final summary = _orderSummary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ═══ 1. Địa chỉ nhận hàng ═══
                  AddressCard(
                    address: _address,
                    onTapAddAddress: _navigateToAddAddress,
                    onTapChangeAddress: _showAddressSelector,
                  ),

                  // ═══ 2. Danh sách sản phẩm ═══
                  ...widget.selectedItems.map(
                    (item) => _buildProductCard(item),
                  ),

                  // ═══ 3. Lời nhắn cho Shop ═══
                  _buildNoteSection(),

                  // ═══ 4. Phương thức thanh toán ═══
                  PaymentMethodSelector(
                    methods: CheckoutMockData.paymentMethods,
                    selectedType: _selectedPaymentMethod,
                    onSelected: (type) {
                      setState(() => _selectedPaymentMethod = type);
                    },
                  ),

                  // ═══ 5. Thời lượng thuê ═══
                  RentalDurationSelector(
                    selectedDuration: _selectedDuration,
                    startDate: _startDate,
                    endDate: _endDate,
                    onDurationSelected: _onDurationSelected,
                    onTapStartDate: _pickStartDate,
                    onTapEndDate: _pickEndDate,
                  ),

                  // ═══ 6. Chi tiết hóa đơn ═══
                  OrderSummaryCard(
                    summary: summary,
                    hasFullData: _isReadyToOrder,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ═══ Bottom Bar ═══
          _buildBottomBar(summary, bottomPadding),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  PRODUCT CARD — Card sản phẩm
  // ═══════════════════════════════════════════════════════

  Widget _buildProductCard(GioHangItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Ảnh sản phẩm ──
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CloudImage(
                imageUrl: item.anhDaiDien,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                fallbackIcon: Icons.medical_services_rounded,
                fallbackIconSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Thông tin ──
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.tenLoaiThietBi,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${_fmt.format(item.giaThueThamKhao)} đ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      ' / tháng',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  NOTE SECTION — Lời nhắn cho Shop
  // ═══════════════════════════════════════════════════════

  Widget _buildNoteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showNoteDialog,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lời nhắn cho Shop',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_noteToShop != null && _noteToShop!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _noteToShop!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_noteToShop == null || _noteToShop!.isEmpty) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Để lại lời nhắn',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNoteDialog() async {
    final controller = TextEditingController(text: _noteToShop);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Lời nhắn cho Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập lời nhắn của bạn...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _noteToShop = result);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  BOTTOM BAR — Tổng tiền + Nút Đặt thuê
  // ═══════════════════════════════════════════════════════

  Widget _buildBottomBar(OrderSummary summary, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Tổng tiền ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng tiền (tạm tính cọc):',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isReadyToOrder
                      ? '${_fmt.format(widget.tongTamTinh)} đ/ tháng'
                      : '0 đ',
                  style: TextStyle(
                    fontSize: _isReadyToOrder ? 15 : 16,
                    fontWeight: FontWeight.bold,
                    color: _isReadyToOrder
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // ── Nút đặt thuê ──
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: (_isReadyToOrder && !_isPlacingOrder)
                  ? _onPlaceOrder
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isReadyToOrder ? AppColors.darkBg : AppColors.divider,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.textDisabled,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: _isReadyToOrder ? 2 : 0,
              ),
              child: _isPlacingOrder
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Đặt thuê (${widget.selectedItems.length})',
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

  // ═══════════════════════════════════════════════════════
  //  ACTIONS — Xử lý sự kiện
  // ═══════════════════════════════════════════════════════

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(existingAddress: _address),
      ),
    );

    if (result != null) {
      setState(() => _address = result);
      // Reload danh sách từ API
      _loadAddresses();
    }
  }

  /// Hiển thị bottom sheet chọn địa chỉ từ danh sách
  void _showAddressSelector() {
    if (_addresses.isEmpty) {
      _navigateToAddAddress();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn địa chỉ nhận hàng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToAddAddress();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Thêm mới',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Address list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final addr = _addresses[index];
                  final isSelected = addr.diaChiId == _address?.diaChiId;
                  return _buildAddressItem(ctx, addr, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(
      BuildContext ctx, DeliveryAddress addr, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _address = addr);
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              addr.loaiDiaChi == AddressType.personal
                  ? Icons.home_rounded
                  : Icons.business_rounded,
              color:
                  isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${addr.tenNguoiNhan}  ${addr.soDienThoaiFormatted}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    addr.diaChiDayDu,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (addr.donVi != null && addr.donVi!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      addr.donVi!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  void _onDurationSelected(RentalDuration duration) {
    setState(() {
      _selectedDuration = duration;

      // Auto-set start date nếu chưa có
      _startDate ??= DateTime.now();

      // Tính end date
      _endDate = DateTime(
        _startDate!.year,
        _startDate!.month + duration.months,
        _startDate!.day,
      );
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_selectedDuration != null && _selectedDuration!.days == null) {
          _endDate = DateTime(
            picked.year,
            picked.month + _selectedDuration!.months,
            picked.day,
          );
        } else if (_selectedDuration != null && _selectedDuration!.days != null) {
          _endDate = picked.add(Duration(days: _selectedDuration!.days!));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    _startDate ??= DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 30)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: _startDate!.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        final difference = _endDate!.difference(_startDate!).inDays;
        _selectedDuration = RentalDuration(
          label: 'Tùy chỉnh ($difference ngày)',
          months: 0,
          days: difference,
        );
      });
    }
  }

  /// Gọi API tạo hợp đồng → Chuyển đến màn hình thành công
  Future<void> _onPlaceOrder() async {
    if (!_isReadyToOrder) return;

    setState(() => _isPlacingOrder = true);

    try {
      // Map PaymentMethodType → int (1=MoMo, 2=ZaloPay, 3=Tiền mặt)
      final paymentCode = _mapPaymentMethodCode(_selectedPaymentMethod!);

      // Tính số tháng thuê
      final soThangThue = _selectedDuration!.days != null
          ? (_selectedDuration!.days! / 30).ceil()
          : _selectedDuration!.months;

      // Build danh sách thiết bị cho API
      final danhSachThietBi = widget.selectedItems
          .map((item) => {
                'thietBiId': item.loaiThietBiId,
                'soLuong': item.soLuong,
              })
          .toList();

      // Gọi API tạo hợp đồng
      final apiResponse = await _checkoutService.createContract(
        diaChiGiaoId: _address!.diaChiId!,
        phuongThucThanhToan: paymentCode,
        ngayBatDauThue: _startDate!,
        soThangThue: soThangThue,
        ghiChuKhachHang: _noteToShop,
        danhSachThietBi: danhSachThietBi,
      );

      if (!mounted) return;

      // Lấy thông tin từ response
      final maHD = apiResponse['maHopDong'] ?? '';
      final hopDongId = apiResponse['hopDongId'] as int?;

      // Chuyển đến màn hình thành công (không cần ký hợp đồng nữa)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ContractSuccessScreen(
            maHopDong: maHD,
            hopDongId: hopDongId ?? 0,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  /// Map enum → mã thanh toán theo API
  int _mapPaymentMethodCode(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.momo:
        return 1;
      case PaymentMethodType.zalopay:
        return 2;
      case PaymentMethodType.cash:
        return 3;
    }
  }
}
