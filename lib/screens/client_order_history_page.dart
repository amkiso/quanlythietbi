import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../services/checkout_service.dart';
import 'contract_detail_screen.dart';

/// Màn hình Lịch sử đơn hàng — hiển thị tất cả hợp đồng của khách hàng
class ClientOrderHistoryPage extends StatefulWidget {
  final int initialFilter;

  const ClientOrderHistoryPage({
    super.key,
    this.initialFilter = -1,
  });

  @override
  State<ClientOrderHistoryPage> createState() => _ClientOrderHistoryPageState();
}

class _ClientOrderHistoryPageState extends State<ClientOrderHistoryPage> {
  final CheckoutService _service = CheckoutService();
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;
  late int _filterStatus;

  final Map<int, _StatusInfo> _statusMap = {
    1: _StatusInfo('Chờ xác nhận', Icons.hourglass_top_rounded, Color(0xFFFFA726)),
    2: _StatusInfo('Chờ TT cọc', Icons.payment_rounded, Color(0xFF26A69A)),
    3: _StatusInfo('Chờ nhận TB', Icons.local_shipping_outlined, Color(0xFF5C6BC0)),
    4: _StatusInfo('Đang cho thuê', Icons.check_circle_outline, Color(0xFF66BB6A)),
    5: _StatusInfo('Vi phạm', Icons.gavel_rounded, Color(0xFFD32F2F)),
    6: _StatusInfo('Quá hạn TT', Icons.warning_amber_rounded, Color(0xFFFF7043)),
    7: _StatusInfo('Đã hủy (KH)', Icons.cancel_outlined, Color(0xFF9E9E9E)),
    8: _StatusInfo('Đã thu hồi', Icons.assignment_return_rounded, Color(0xFF78909C)),
    9: _StatusInfo('Đang kiểm tra', Icons.search_rounded, Color(0xFF7E57C2)),
    10: _StatusInfo('Chờ TT nợ', Icons.account_balance_wallet_rounded, Color(0xFFEF5350)),
    11: _StatusInfo('Đã hủy', Icons.block_rounded, Color(0xFFBDBDBD)),
    12: _StatusInfo('Hoàn tất', Icons.verified_rounded, Color(0xFF2E7D32)),
  };

  /// Cấu hình filter chips — id, label, statusIds tương ứng
  final List<_FilterChipData> _filterChips = [
    _FilterChipData(-1, 'Tất cả', []),
    _FilterChipData(1, 'Chờ XN', [1]),
    _FilterChipData(2, 'Chờ TT', [2, 10]),
    _FilterChipData(3, 'Chờ giao', [3]),
    _FilterChipData(4, 'Đang thuê', [4]),
    _FilterChipData(12, 'Hoàn tất', [12]),
    _FilterChipData(7, 'Đã hủy', [7, 11]),
  ];

  @override
  void initState() {
    super.initState();
    _filterStatus = widget.initialFilter;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.getMyContracts();
      if (mounted) setState(() { _orders = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_filterStatus == -1) return _orders;
    // Tìm filter chip tương ứng
    final chip = _filterChips.firstWhere((c) => c.id == _filterStatus, orElse: () => _filterChips.first);
    if (chip.statusIds.isEmpty) return _orders;
    return _orders.where((o) => chip.statusIds.contains(o['trangThaiId'])).toList();
  }

  /// Đếm số đơn hàng cho 1 filter chip
  int _countForFilter(_FilterChipData chip) {
    if (chip.statusIds.isEmpty) return _orders.length;
    return _orders.where((o) => chip.statusIds.contains(o['trangThaiId'])).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Lịch sử đơn hàng', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _filterChips.map((chip) {
            final selected = _filterStatus == chip.id;
            final count = _isLoading ? 0 : _countForFilter(chip);
            final labelText = count > 0 ? '${chip.label} ($count)' : chip.label;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                selected: selected,
                onSelected: (_) => setState(() => _filterStatus = chip.id),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        const Text('Không thể tải dữ liệu', style: TextStyle(color: AppColors.textHint)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _loadOrders,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(120, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Thử lại'),
        ),
      ]));
    }
    final items = _filteredOrders;
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.inbox_rounded, size: 56, color: AppColors.textHint),
        const SizedBox(height: 8),
        const Text('Chưa có đơn hàng nào', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildOrderCard(items[i]),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusId = order['trangThaiId'] ?? 1;
    final info = _statusMap[statusId] ?? _StatusInfo('N/A', Icons.help_outline, Colors.grey);
    final maHD = order['maHopDong'] ?? '';
    final tongTien = (order['tongTienThue'] ?? 0).toDouble();
    final soTB = order['soThietBi'] ?? 0;
    final ngayLap = order['ngayLap'] != null ? DateTime.tryParse(order['ngayLap']) : null;
    final ngayDuKienTra = order['ngayDuKienTra'] != null ? DateTime.tryParse(order['ngayDuKienTra']) : null;
    final laHoaToc = order['laHoaToc'] == true;

    return GestureDetector(
      onTap: () => _viewContract(order['hopDongId']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: info.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(info.icon, color: info.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(maHD, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                if (laHoaToc) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                    child: const Text('🔥 Hỏa tốc', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ]),
              Text(info.label, style: TextStyle(fontSize: 11, color: info.color, fontWeight: FontWeight.w600)),
            ])),
            Text('${_fmt.format(tongTien)} đ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Row(children: [
            _infoChip(Icons.devices_rounded, '$soTB thiết bị'),
            const SizedBox(width: 12),
            if (ngayLap != null) _infoChip(Icons.calendar_today_rounded, _dateFmt.format(ngayLap)),
            const Spacer(),
            if (ngayDuKienTra != null) Text('Hạn: ${_dateFmt.format(ngayDuKienTra)}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ]),
        ]),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: AppColors.textHint),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);

  void _viewContract(int? hopDongId) {
    if (hopDongId == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ContractDetailScreen(hopDongId: hopDongId)));
  }
}

class _StatusInfo {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusInfo(this.label, this.icon, this.color);
}

class _FilterChipData {
  final int id;
  final String label;
  final List<int> statusIds;
  const _FilterChipData(this.id, this.label, this.statusIds);
}
