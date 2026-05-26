import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../services/checkout_service.dart';
import 'contract_view_screen.dart';

/// Màn hình Chi tiết Hợp đồng — Hiển thị thông tin + nút hành động dynamic
class ContractDetailScreen extends StatefulWidget {
  final int hopDongId;
  const ContractDetailScreen({super.key, required this.hopDongId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final CheckoutService _service = CheckoutService();
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');
  final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  bool _isProcessing = false;

  // ── Trạng thái mapping ──
  static const Map<int, _StatusStyle> _statusStyles = {
    1: _StatusStyle('Chờ xác nhận', Icons.hourglass_top_rounded, Color(0xFFFFA726), Color(0xFFFFF3E0)),
    2: _StatusStyle('Chờ thanh toán cọc', Icons.payment_rounded, Color(0xFF26A69A), Color(0xFFE0F2F1)),
    3: _StatusStyle('Chờ nhận thiết bị', Icons.local_shipping_outlined, Color(0xFF5C6BC0), Color(0xFFE8EAF6)),
    4: _StatusStyle('Đang cho thuê', Icons.check_circle_outline, Color(0xFF66BB6A), Color(0xFFE8F5E9)),
    5: _StatusStyle('Vi phạm - chấm dứt', Icons.gavel_rounded, Color(0xFFD32F2F), Color(0xFFFFEBEE)),
    6: _StatusStyle('Quá hạn thanh toán', Icons.warning_amber_rounded, Color(0xFFFF7043), Color(0xFFFBE9E7)),
    7: _StatusStyle('Đã hủy bởi KH', Icons.cancel_outlined, Color(0xFF9E9E9E), Color(0xFFF5F5F5)),
    8: _StatusStyle('Đã thu hồi TB', Icons.assignment_return_rounded, Color(0xFF78909C), Color(0xFFECEFF1)),
    9: _StatusStyle('Đang kiểm tra', Icons.search_rounded, Color(0xFF7E57C2), Color(0xFFEDE7F6)),
    10: _StatusStyle('Chờ thanh toán nợ', Icons.account_balance_wallet_rounded, Color(0xFFEF5350), Color(0xFFFFEBEE)),
    11: _StatusStyle('Đã hủy', Icons.block_rounded, Color(0xFFBDBDBD), Color(0xFFF5F5F5)),
    12: _StatusStyle('Hoàn tất', Icons.verified_rounded, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  };

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final detail = await _service.getContractDetail(widget.hopDongId);
      if (mounted) setState(() { _detail = detail; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  int get _statusId => _detail?['trangThaiId'] ?? 0;
  _StatusStyle get _style => _statusStyles[_statusId] ?? const _StatusStyle('N/A', Icons.help, Colors.grey, Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
      const SizedBox(height: 8),
      const Text('Không thể tải hợp đồng', style: TextStyle(color: AppColors.textHint)),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _loadDetail,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        child: const Text('Thử lại'),
      ),
    ]));
  }

  Widget _buildContent() {
    final d = _detail!;
    final chiPhi = d['chiPhi'] as Map<String, dynamic>? ?? {};
    final khachHang = d['khachHang'] as Map<String, dynamic>? ?? {};
    final chiTietTB = d['chiTietThietBi'] as List? ?? [];
    final maHD = d['maHopDong'] ?? '';
    final tongTien = (chiPhi['tongTienThue'] ?? 0).toDouble();
    final tienCoc = (chiPhi['tienCoc'] ?? 0).toDouble();
    final thueVAT = (chiPhi['thueVAT'] ?? 0).toDouble();
    final phiHoaToc = (d['phiHoaToc'] ?? 0).toDouble();
    final laHoaToc = d['laHoaToc'] == true;
    final loaiHD = d['loaiHopDong'] ?? 'Cá nhân';
    final ngayLap = DateTime.tryParse(d['ngayLap']?.toString() ?? '');
    final ngayBD = DateTime.tryParse(d['ngayBatDauThue']?.toString() ?? '');
    final ngayKT = DateTime.tryParse(d['ngayDuKienTra']?.toString() ?? '');
    final hanTT = DateTime.tryParse(d['hanThanhToan']?.toString() ?? '');

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ═══ SliverAppBar ═══
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: _style.color,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_style.color, _style.color.withValues(alpha: 0.7)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(children: [
                        Icon(_style.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                        Text(_style.label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        if (laHoaToc) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('🔥 Hỏa tốc', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
            title: Text(maHD, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ═══ 1. Thông tin tổng quan ═══
            _buildSection('Thông tin hợp đồng', Icons.description_rounded, [
              _infoRow('Mã hợp đồng', maHD),
              _infoRow('Loại hợp đồng', loaiHD),
              _infoRow('Trạng thái', _style.label),
              if (ngayLap != null) _infoRow('Ngày lập', _dateFmt.format(ngayLap)),
              if (ngayBD != null) _infoRow('Ngày bắt đầu thuê', _dateFmt.format(ngayBD)),
              if (ngayKT != null) _infoRow('Ngày dự kiến trả', _dateFmt.format(ngayKT)),
              _infoRow('Thời hạn', '${d['soThangThue'] ?? 0} tháng'),
              _infoRow('Địa điểm giao', d['diaDiemGiao'] ?? ''),
              if (hanTT != null) _infoRow('Hạn thanh toán', _dateFmt.format(hanTT)),
            ]),
            const SizedBox(height: 12),

            // ═══ 2. Thông tin khách hàng ═══
            _buildSection('Bên B — Khách hàng', Icons.person_rounded, [
              _infoRow('Họ tên', khachHang['hoTen'] ?? ''),
              _infoRow('Email', khachHang['email'] ?? ''),
              _infoRow('SĐT', khachHang['soDienThoai'] ?? ''),
              _infoRow('CCCD', khachHang['cccd'] ?? ''),
              if ((khachHang['donViCongTac'] ?? '').isNotEmpty)
                _infoRow('Đơn vị', khachHang['donViCongTac']),
            ]),
            const SizedBox(height: 12),

            // ═══ 3. Danh sách thiết bị ═══
            _buildSection('Thiết bị cho thuê', Icons.devices_rounded,
              chiTietTB.map<Widget>((tb) {
                final ten = tb['tenThietBi'] ?? 'N/A';
                final serial = tb['soSerial'] ?? '';
                final gia = (tb['giaThueThang'] ?? 0).toDouble();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ten, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('SN: $serial', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                    ])),
                    Text('${_fmt.format(gia)} đ/tháng', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // ═══ 4. Chi phí ═══
            _buildSection('Chi phí', Icons.receipt_long_rounded, [
              _costRow('Tổng tiền thuê', tongTien),
              _costRow('Tiền đặt cọc', tienCoc),
              _costRow('Thuế VAT', thueVAT),
              if (laHoaToc) _costRow('Phí hỏa tốc (+10%)', phiHoaToc, highlight: true),
              const Divider(height: 16),
              _costRow('Tổng thanh toán', tongTien + thueVAT + phiHoaToc, isBold: true),
            ]),
            const SizedBox(height: 12),

            // ═══ 5. Điều 2 — Tiền cọc ═══
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFF9A825), size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Điều 2: Tiền đặt cọc sẽ được khấu trừ vào tổng số tiền hợp đồng còn lại cần thanh toán khi kết thúc hợp đồng.',
                  style: TextStyle(fontSize: 12, color: Colors.brown[700], height: 1.4),
                )),
              ]),
            ),
            const SizedBox(height: 12),

            // ═══ 6. Lý do hủy (nếu có) ═══
            if (d['lyDoHuy'] != null && (d['lyDoHuy'] as String).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Lý do hủy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 4),
                    Text(d['lyDoHuy'], style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ])),
                ]),
              ),
              const SizedBox(height: 12),
            ],

            // ═══ 7. Xem bản in ═══
            InkWell(
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ContractViewScreen(hopDongId: widget.hopDongId)),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Row(children: [
                  Icon(Icons.print_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 12),
                  Expanded(child: Text('Xem bản in hợp đồng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                ]),
              ),
            ),

            const SizedBox(height: 20),

            // ═══ 8. Nút hành động ═══
            ..._buildActionButtons(),

            const SizedBox(height: 30),
          ]),
        )),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  WIDGETS — Sections & Cards
  // ═══════════════════════════════════════════════════════

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textHint))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      ]),
    );
  }

  Widget _costRow(String label, double amount, {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: highlight ? Colors.orange[800] : AppColors.textSecondary,
        ))),
        Text(
          '${_fmt.format(amount)} đ',
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: highlight ? Colors.orange[800] : (isBold ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ACTION BUTTONS — Dynamic theo trạng thái
  // ═══════════════════════════════════════════════════════

  List<Widget> _buildActionButtons() {
    final List<Widget> buttons = [];

    // Hủy hợp đồng — chỉ khi chờ xác nhận (1)
    if (_statusId == 1) {
      buttons.add(_actionButton(
        label: 'Hủy hợp đồng',
        icon: Icons.cancel_rounded,
        color: Colors.red,
        onTap: _onCancelContract,
      ));
    }

    // Thanh toán cọc — chỉ khi chờ thanh toán cọc (2)
    if (_statusId == 2) {
      buttons.add(_actionButton(
        label: 'Thanh toán cọc',
        icon: Icons.payment_rounded,
        color: const Color(0xFF26A69A),
        onTap: _onPayDeposit,
      ));
    }

    // Liên hệ bảo trì — chỉ khi đang cho thuê (4)
    if (_statusId == 4) {
      buttons.add(_actionButton(
        label: 'Liên hệ bảo trì',
        icon: Icons.build_rounded,
        color: const Color(0xFF7E57C2),
        onTap: _onRequestMaintenance,
      ));
    }

    // Thanh toán nợ — chỉ khi chờ thanh toán nợ (10)
    if (_statusId == 10) {
      buttons.add(_actionButton(
        label: 'Thanh toán nợ',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFFEF5350),
        onTap: _onPayDebt,
      ));
    }

    // Yêu cầu hỗ trợ — mọi trạng thái (trừ đã kết thúc: 7, 11, 12)
    if (![7, 11, 12].contains(_statusId)) {
      buttons.add(_actionButton(
        label: 'Yêu cầu hỗ trợ',
        icon: Icons.support_agent_rounded,
        color: AppColors.primary,
        onTap: _onRequestSupport,
        isOutlined: true,
      ));
    }

    return buttons;
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: isOutlined
            ? OutlinedButton.icon(
                onPressed: _isProcessing ? null : onTap,
                icon: Icon(icon, size: 20),
                label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _isProcessing ? null : onTap,
                icon: _isProcessing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(icon, size: 20),
                label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HANDLERS — Xử lý sự kiện
  // ═══════════════════════════════════════════════════════

  Future<void> _onCancelContract() async {
    final reason = await _showInputDialog(
      title: 'Hủy hợp đồng',
      hint: 'Nhập lý do hủy (không bắt buộc)...',
      confirmLabel: 'Xác nhận hủy',
      confirmColor: Colors.red,
      warningText: 'Bạn có chắc chắn muốn hủy hợp đồng này?\nThao tác này không thể hoàn tác.',
    );

    if (reason == null) return; // User dismissed

    setState(() => _isProcessing = true);
    try {
      await _service.cancelContract(widget.hopDongId, lyDoHuy: reason.isEmpty ? null : reason);
      if (!mounted) return;
      _showSnackBar('Đã hủy hợp đồng thành công', Colors.green);
      _loadDetail();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onPayDeposit() async {
    final confirmed = await _showConfirmDialog(
      title: 'Thanh toán cọc',
      message: 'Xác nhận thanh toán tiền cọc ${_fmt.format((_detail?['chiPhi']?['tienCoc'] ?? 0).toDouble())} đ?\n\n(Đây là chế độ demo — thanh toán sẽ được ghi nhận tự động)',
      confirmLabel: 'Thanh toán',
      confirmColor: const Color(0xFF26A69A),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _service.demoPayment(widget.hopDongId);
      if (!mounted) return;
      _showSnackBar('Thanh toán cọc thành công!', Colors.green);
      _loadDetail();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onPayDebt() async {
    final confirmed = await _showConfirmDialog(
      title: 'Thanh toán nợ',
      message: 'Xác nhận thanh toán số tiền còn nợ?\n\n(Đây là chế độ demo — thanh toán sẽ được ghi nhận tự động)',
      confirmLabel: 'Thanh toán',
      confirmColor: const Color(0xFFEF5350),
    );
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _service.demoPayment(widget.hopDongId);
      if (!mounted) return;
      _showSnackBar('Thanh toán nợ thành công!', Colors.green);
      _loadDetail();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onRequestMaintenance() async {
    final content = await _showInputDialog(
      title: 'Yêu cầu bảo trì',
      hint: 'Mô tả tình trạng thiết bị cần bảo trì...',
      confirmLabel: 'Gửi yêu cầu',
      confirmColor: const Color(0xFF7E57C2),
    );
    if (content == null || content.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      await _service.requestSupport(widget.hopDongId, noiDung: content, loaiYeuCau: 2);
      if (!mounted) return;
      _showSnackBar('Đã gửi yêu cầu bảo trì!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onRequestSupport() async {
    final content = await _showInputDialog(
      title: 'Yêu cầu hỗ trợ',
      hint: 'Mô tả vấn đề bạn cần hỗ trợ...',
      confirmLabel: 'Gửi yêu cầu',
      confirmColor: AppColors.primary,
    );
    if (content == null || content.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      await _service.requestSupport(widget.hopDongId, noiDung: content, loaiYeuCau: 1);
      if (!mounted) return;
      _showSnackBar('Đã gửi yêu cầu hỗ trợ!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  DIALOGS
  // ═══════════════════════════════════════════════════════

  Future<String?> _showInputDialog({
    required String title,
    required String hint,
    required String confirmLabel,
    required Color confirmColor,
    String? warningText,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (warningText != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(warningText, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: confirmColor)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmLabel, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmLabel, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _StatusStyle(this.label, this.icon, this.color, this.bgColor);
}
