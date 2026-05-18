import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';
import '../services/checkout_service.dart';
import '../widgets/reusable_electronic_contract.dart';
import 'contract_success_screen.dart';

/// ═══════════════════════════════════════════════════════
///  ELECTRONIC CONTRACT SCREEN — Màn hình hợp đồng điện tử
///  Bao gồm: Nội dung hợp đồng + Ký tên + PIN xác nhận
///  Tích hợp API: POST /api/hop-dong/{id}/ky-ket
/// ═══════════════════════════════════════════════════════
class ElectronicContractScreen extends StatefulWidget {
  final ElectronicContractData contractData;

  const ElectronicContractScreen({super.key, required this.contractData});

  @override
  State<ElectronicContractScreen> createState() =>
      _ElectronicContractScreenState();
}

class _ElectronicContractScreenState extends State<ElectronicContractScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());

  final CheckoutService _checkoutService = CheckoutService();

  bool _hasAgreed = false;
  bool _hasSigned = false;
  bool _isSigning = false;

  bool get _isComplete => _hasAgreed && _hasSigned;

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      final signed = _signatureController.isNotEmpty;
      if (signed != _hasSigned) setState(() => _hasSigned = signed);
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    for (final c in _pinControllers) { c.dispose(); }
    for (final f in _pinFocusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Hợp đồng điện tử',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ═══ Contract Content ═══
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ReusableElectronicContract(data: widget.contractData),
                  ),

                  // ═══ Signature Section ═══
                  _buildSignatureSection(),

                  // ═══ Agreement Checkbox ═══
                  _buildAgreementCheckbox(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ═══ Bottom: Confirm Button ═══
          _buildBottomBar(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.draw_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Chữ ký của Bên B',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ]),
              if (_hasSigned)
                GestureDetector(
                  onTap: () { _signatureController.clear(); setState(() => _hasSigned = false); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight, borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Ký lại', style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Ký tên vào ô bên dưới', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          const SizedBox(height: 12),

          // Signature pad
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: _hasSigned ? AppColors.success : AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          if (_hasSigned) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 4),
              Text('Đã ký', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value: _hasAgreed,
              onChanged: (v) => setState(() => _hasAgreed = v ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Tôi đã đọc, hiểu và đồng ý với toàn bộ ',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                TextSpan(text: 'điều khoản hợp đồng',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                TextSpan(text: ' và cam kết thực hiện đúng các nghĩa vụ nêu trên.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton.icon(
          onPressed: (_isComplete && !_isSigning) ? _onConfirm : null,
          icon: Icon(
            _isSigning
                ? Icons.hourglass_top_rounded
                : (_isComplete ? Icons.verified_rounded : Icons.lock_outline_rounded),
            size: 20,
          ),
          label: Text(
            _isSigning
                ? 'Đang xử lý...'
                : (_isComplete ? 'Xác nhận & Gửi hợp đồng' : 'Hoàn tất ký kết để tiếp tục'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isComplete ? AppColors.success : AppColors.divider,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.divider,
            disabledForegroundColor: AppColors.textDisabled,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: _isComplete ? 3 : 0,
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    // Reset PIN controllers
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _showPinBottomSheet();
  }

  void _showPinBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(Icons.shield_rounded, color: AppColors.primary, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Xác thực giao dịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng nhập mã PIN 6 số để xác nhận ký hợp đồng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 30),
                // PIN input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildPinBoxInModal(index, setModalState, ctx)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinBoxInModal(int index, StateSetter setModalState, BuildContext modalCtx) {
    return SizedBox(
      width: 44, height: 52,
      child: TextFormField(
        controller: _pinControllers[index],
        focusNode: _pinFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        obscureText: true,
        autofocus: index == 0,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: _pinControllers[index].text.isNotEmpty
              ? AppColors.primarySurface.withValues(alpha: 0.5)
              : AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _pinControllers[index].text.isNotEmpty
                  ? AppColors.primary : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setModalState(() {});
          if (value.isNotEmpty && index < 5) {
            _pinFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _pinFocusNodes[index - 1].requestFocus();
          }

          // Check if all 6 digits are entered
          final currentPin = _pinControllers.map((c) => c.text).join();
          if (currentPin.length == 6) {
            Navigator.pop(modalCtx);
            _submitSignContract(currentPin);
          }
        },
      ),
    );
  }

  /// Gọi API ký hợp đồng: export chữ ký → multipart upload
  Future<void> _submitSignContract(String pin) async {
    if (_isSigning) return;
    setState(() => _isSigning = true);

    try {
      // Export chữ ký thành PNG bytes
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        throw Exception('Không thể xuất chữ ký');
      }

      // Gọi API ký hợp đồng
      await _checkoutService.signContract(
        hopDongId: widget.contractData.hopDongId,
        signatureImage: signatureBytes,
        maPin: pin,
      );

      if (!mounted) return;

      // Chuyển sang màn hình thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ContractSuccessScreen(
            maHopDong: widget.contractData.maHopDong,
            hopDongId: widget.contractData.hopDongId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi ký hợp đồng: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigning = false);
    }
  }
}
