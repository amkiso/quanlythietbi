import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';
import '../services/checkout_service.dart';

/// ═══════════════════════════════════════════════════════
///  ADD ADDRESS SCREEN — Thêm / Chỉnh sửa địa chỉ nhận hàng
///  Tích hợp API: POST /api/dia-chi & PUT /api/dia-chi/{id}
/// ═══════════════════════════════════════════════════════
class AddAddressScreen extends StatefulWidget {
  final DeliveryAddress? existingAddress; // null = thêm mới

  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _checkoutService = CheckoutService();

  late TextEditingController _tenController;
  late TextEditingController _sdtController;
  late TextEditingController _tinhThanhController;
  late TextEditingController _phuongXaController;
  late TextEditingController _diaChiController;
  late TextEditingController _donViController;

  AddressType _loaiDiaChi = AddressType.office;
  bool _laMacDinh = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAddress;
    _tenController =
        TextEditingController(text: existing?.tenNguoiNhan ?? '');
    _sdtController =
        TextEditingController(text: existing?.soDienThoai ?? '');
    _tinhThanhController =
        TextEditingController(text: existing?.tinhThanhPho ?? '');
    _phuongXaController =
        TextEditingController(text: existing?.phuongXa ?? '');
    _diaChiController =
        TextEditingController(text: existing?.diaChiChiTiet ?? '');
    _donViController =
        TextEditingController(text: existing?.donVi ?? '');

    if (existing != null) {
      _loaiDiaChi = existing.loaiDiaChi;
      _laMacDinh = existing.laMacDinh;
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _sdtController.dispose();
    _tinhThanhController.dispose();
    _phuongXaController.dispose();
    _diaChiController.dispose();
    _donViController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final address = DeliveryAddress(
      diaChiId: widget.existingAddress?.diaChiId,
      tenNguoiNhan: _tenController.text.trim(),
      soDienThoai: _sdtController.text.trim(),
      tinhThanhPho: _tinhThanhController.text.trim(),
      phuongXa: _phuongXaController.text.trim(),
      diaChiChiTiet: _diaChiController.text.trim(),
      donVi: _donViController.text.trim().isEmpty
          ? null
          : _donViController.text.trim(),
      loaiDiaChi: _loaiDiaChi,
      laMacDinh: _laMacDinh,
    );

    setState(() => _isLoading = true);

    try {
      DeliveryAddress saved;
      if (widget.existingAddress?.diaChiId != null) {
        saved = await _checkoutService.updateAddress(
          widget.existingAddress!.diaChiId!,
          address,
        );
      } else {
        saved = await _checkoutService.createAddress(address);
      }

      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Địa chỉ nhận hàng',
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══ Section 1: Thông tin cá nhân ═══
                    _buildSection(
                      children: [
                        _buildField(
                          label: 'Tên người nhận',
                          controller: _tenController,
                          hint: 'Nhập họ tên người nhận',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Số điện thoại',
                          controller: _sdtController,
                          hint: 'Nhập số điện thoại',
                          keyboardType: TextInputType.phone,
                          validator: _requiredValidator,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ═══ Section 2: Địa chỉ ═══
                    _buildSection(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Tỉnh/ Thành phố',
                                controller: _tinhThanhController,
                                hint: 'Thành phố Hồ Chí Mi...',
                                validator: _requiredValidator,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Phường/ Xã',
                                controller: _phuongXaController,
                                hint: 'Phường 12',
                                validator: _requiredValidator,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Địa chỉ chi tiết',
                          controller: _diaChiController,
                          hint: '201B Nguyễn Chí Thanh, Quận 5',
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Đơn vị',
                          controller: _donViController,
                          hint: 'Bệnh viện Chợ Rẫy - Khoa Hồi sức tích cực (ICU)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ═══ Section 3: Loại địa chỉ + Mặc định ═══
                    _buildSection(
                      children: [
                        // Loại địa chỉ
                        Row(
                          children: [
                            Text(
                              'Loại địa chỉ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            _buildAddressTypeChip(
                              label: 'Nhà riêng',
                              type: AddressType.personal,
                            ),
                            const SizedBox(width: 8),
                            _buildAddressTypeChip(
                              label: 'Văn phòng',
                              type: AddressType.office,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Địa chỉ mặc định
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Địa chỉ mặc định',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Switch(
                              value: _laMacDinh,
                              onChanged: (value) {
                                setState(() => _laMacDinh = value);
                              },
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══ Bottom: Nút "Hoàn thành" ═══
          Container(
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
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBg,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Hoàn thành',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Wrapper Section ──
  Widget _buildSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Text Field ──
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  // ── Address Type Chip ──
  Widget _buildAddressTypeChip({
    required String label,
    required AddressType type,
  }) {
    final isSelected = _loaiDiaChi == type;

    return GestureDetector(
      onTap: () => setState(() => _loaiDiaChi = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Validators ──
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trường này là bắt buộc';
    }
    return null;
  }
}
