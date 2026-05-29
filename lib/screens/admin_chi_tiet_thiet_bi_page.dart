import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/loai_thiet_bi.dart';
import '../providers/danh_muc_provider.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/cloud_image.dart';

/// Màn hình chi tiết loại thiết bị — Xem / Sửa / Xóa
class AdminChiTietThietBiPage extends StatefulWidget {
  final int loaiThietBiId;
  const AdminChiTietThietBiPage({super.key, required this.loaiThietBiId});

  @override
  State<AdminChiTietThietBiPage> createState() => _AdminChiTietThietBiPageState();
}

class _AdminChiTietThietBiPageState extends State<AdminChiTietThietBiPage> {
  bool _isEditing = false;
  late TextEditingController _tenController;
  late TextEditingController _giaController;
  late TextEditingController _thongSoController;

  @override
  void initState() {
    super.initState();
    _tenController = TextEditingController();
    _giaController = TextEditingController();
    _thongSoController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DanhMucProvider>().loadDetail(widget.loaiThietBiId);
    });
  }

  @override
  void dispose() {
    _tenController.dispose();
    _giaController.dispose();
    _thongSoController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  void _startEditing(LoaiThietBi item) {
    _tenController.text = item.tenLoaiThietBi;
    _giaController.text = item.giaThueThamKhao.toStringAsFixed(0);
    _thongSoController.text = item.thongSoKyThuat ?? '';
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    setState(() => _isEditing = false);
  }

  Future<void> _saveChanges(DanhMucProvider provider) async {
    final current = provider.selectedLoaiThietBi;
    if (current == null) return;

    final updated = LoaiThietBi(
      loaiThietBiId: current.loaiThietBiId,
      danhMucId: current.danhMucId,
      nhaCungCapId: current.nhaCungCapId,
      tenLoaiThietBi: _tenController.text.trim(),
      thongSoKyThuat: _thongSoController.text.trim().isEmpty ? null : _thongSoController.text.trim(),
      giaThueThamKhao: double.tryParse(_giaController.text.trim()) ?? current.giaThueThamKhao,
      anhDaiDien: current.anhDaiDien,
    );

    final success = await provider.updateLoaiThietBi(updated);
    if (mounted) {
      if (success) {
        setState(() => _isEditing = false);
        AppSnackBar.showSuccess(context, 'Cập nhật thành công!');
      } else {
        AppSnackBar.showError(context, provider.errorMessage ?? 'Lỗi cập nhật');
      }
    }
  }

  Future<void> _handleDelete(DanhMucProvider provider) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Xóa thiết bị',
      content: 'Bạn có chắc chắn muốn xóa loại thiết bị này? Thao tác không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      icon: Icons.delete_forever_rounded,
      confirmColor: AppColors.error,
    );

    if (confirmed && mounted) {
      final success = await provider.deleteLoaiThietBi(widget.loaiThietBiId);
      if (mounted) {
        if (success) {
          AppSnackBar.showSuccess(context, 'Đã xóa thiết bị');
          Navigator.pop(context);
        } else {
          AppSnackBar.showError(context, provider.errorMessage ?? 'Lỗi xóa');
        }
      }
    }
  }

  Color _getStatusColor(int tinhTrangId) {
    switch (tinhTrangId) {
      case 1: return AppColors.statusAvailable;
      case 2: return AppColors.statusRented;
      case 3: return AppColors.statusMaintenance;
      case 4: return AppColors.statusBroken;
      default: return AppColors.textHint;
    }
  }

  Future<void> _handleGenerateQr(BuildContext context, DanhMucProvider provider, int thietBiId) async {
    final qrUrl = await provider.generateQrCode(thietBiId);
    if (qrUrl != null && mounted) {
      AppSnackBar.showSuccess(context, 'Tạo mã QR thành công!');
    } else if (mounted) {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Không thể tạo mã QR');
    }
  }

  void _showQrDialog(BuildContext context, String maTaiSan, String qrUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 8),
            Text('Mã QR Thiết Bị', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(maTaiSan, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CloudImage(
                  imageUrl: qrUrl,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.qr_code_2_rounded,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQrActionButton(Icons.download_rounded, 'Lưu ảnh', () {
                  Navigator.pop(ctx);
                  AppSnackBar.showSuccess(context, 'Đã lưu ảnh QR vào thiết bị');
                }),
                _buildQrActionButton(Icons.print_rounded, 'In mã', () {
                  Navigator.pop(ctx);
                  AppSnackBar.showInfo(context, 'Chức năng in mã đang phát triển');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DanhMucProvider>(
      builder: (context, provider, _) {
        final item = provider.selectedLoaiThietBi;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: provider.isLoadingDetail
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : item == null
                  ? _buildNotFound()
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildAppBar(item),
                        SliverToBoxAdapter(child: _buildInfoSection(item, provider)),
                        SliverToBoxAdapter(child: _buildSpecsSection(item)),
                        SliverToBoxAdapter(child: _buildSerialListSection(provider)),
                        SliverToBoxAdapter(child: _buildActionButtons(provider)),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
        );
      },
    );
  }

  // ── AppBar with hero image ──
  Widget _buildAppBar(LoaiThietBi item) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.darkBg,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () => _startEditing(item),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Center(
            child: CloudImage(
              imageUrl: item.anhDaiDien,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fallbackIcon: Icons.construction_rounded,
              fallbackIconSize: 64,
              fallbackColor: Colors.transparent,
              showFallbackText: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.construction_rounded, size: 64, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(height: 8),
        Text('Chưa có ảnh', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
      ],
    );
  }

  // ── Info Section ──
  Widget _buildInfoSection(LoaiThietBi item, DanhMucProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: _isEditing ? _buildEditForm(item, provider) : _buildInfoView(item, provider),
    );
  }

  Widget _buildInfoView(LoaiThietBi item, DanhMucProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên
        Text(item.tenLoaiThietBi,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        // Giá thuê
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(_formatCurrency(item.giaThueThamKhao),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const Text(' /ngày', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 12),
        // Details grid
        _buildInfoRow(Icons.category_rounded, 'Danh mục', provider.getTenDanhMuc(item.danhMucId)),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.business_rounded, 'Nhà cung cấp', provider.getTenNhaCungCap(item.nhaCungCapId)),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.qr_code_rounded, 'Mã loại', 'LTB-${item.loaiThietBiId.toString().padLeft(3, '0')}'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(LoaiThietBi item, DanhMucProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Chỉnh sửa thông tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            TextButton(onPressed: _cancelEditing, child: const Text('Hủy', style: TextStyle(color: AppColors.error))),
          ],
        ),
        const SizedBox(height: 16),
        _buildField('Tên thiết bị', _tenController, Icons.devices_rounded),
        const SizedBox(height: 12),
        _buildField('Giá thuê (VNĐ/ngày)', _giaController, Icons.monetization_on_rounded, isNumber: true),
        const SizedBox(height: 12),
        _buildField('Thông số kỹ thuật', _thongSoController, Icons.settings_rounded, maxLines: 4),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: provider.isLoadingDetail ? null : () => _saveChanges(provider),
            icon: provider.isLoadingDetail
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded, size: 20),
            label: const Text('Lưu thay đổi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Specs Section ──
  Widget _buildSpecsSection(LoaiThietBi item) {
    if (item.thongSoKyThuat == null || item.thongSoKyThuat!.isEmpty) {
      return const SizedBox.shrink();
    }
    final specs = item.thongSoKyThuat!.split('\n');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_rounded, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Thông số kỹ thuật', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          ...specs.map((spec) {
            final parts = spec.split(':');
            final key = parts[0].trim();
            final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 10),
                  Text('$key: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Serial List Section ──
  Widget _buildSerialListSection(DanhMucProvider provider) {
    final items = provider.thietBiChiTiet;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.list_alt_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Thiết bị cụ thể', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                child: Text('${items.length} máy', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Chưa có thiết bị cụ thể nào', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
              ),
            )
          else
            ...items.map((tb) {
              final statusId = tb['tinhTrangId'] as int;
              final statusColor = _getStatusColor(statusId);
              final statusName = provider.getTenTinhTrang(statusId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(color: statusColor, width: 3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 22, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tb['maTaiSan'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(tb['khoHienTai'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(statusName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                        ),
                        const SizedBox(height: 6),
                        tb['qrCodeUrl'] == null
                            ? InkWell(
                                onTap: () => _handleGenerateQr(context, provider, tb['thietBiId'] as int),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Tạo QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange)),
                                ),
                              )
                            : InkWell(
                                onTap: () => _showQrDialog(context, tb['maTaiSan'] as String, tb['qrCodeUrl'] as String),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Xem QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Action Buttons ──
  Widget _buildActionButtons(DanhMucProvider provider) {
    if (_isEditing) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  final item = provider.selectedLoaiThietBi;
                  if (item != null) _startEditing(item);
                },
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Sửa', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: provider.isLoadingDetail ? null : () => _handleDelete(provider),
                icon: const Icon(Icons.delete_rounded, size: 20),
                label: const Text('Xóa', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('Không tìm thấy thiết bị', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại')),
        ],
      ),
    );
  }
}
