import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';
import '../services/checkout_service.dart';
import '../widgets/reusable_electronic_contract.dart';

/// Màn hình xem lại hợp đồng — load từ API chi tiết
class ContractViewScreen extends StatefulWidget {
  final int hopDongId;
  const ContractViewScreen({super.key, required this.hopDongId});

  @override
  State<ContractViewScreen> createState() => _ContractViewScreenState();
}

class _ContractViewScreenState extends State<ContractViewScreen> {
  final CheckoutService _service = CheckoutService();
  bool _isLoading = true;
  String? _error;
  ElectronicContractData? _contractData;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final detail = await _service.getContractDetail(widget.hopDongId);
      final kh = detail['khachHang'] as Map<String, dynamic>? ?? {};
      final chiPhi = detail['chiPhi'] as Map<String, dynamic>? ?? {};
      final chiTietList = detail['chiTietThietBi'] as List? ?? [];

      final devices = chiTietList.map((e) => ContractDevice.fromJson(e as Map<String, dynamic>)).toList();

      final ngayBatDau = DateTime.tryParse(detail['ngayBatDauThue']?.toString() ?? '') ?? DateTime.now();
      final ngayKetThuc = DateTime.tryParse(detail['ngayDuKienTra']?.toString() ?? '') ?? DateTime.now();

      final data = ElectronicContractData(
        hopDongId: detail['hopDongId'] ?? 0,
        maHopDong: detail['maHopDong'] ?? '',
        ngayLap: DateTime.tryParse(detail['ngayLap']?.toString() ?? '') ?? DateTime.now(),
        khachHang: ContractCustomerInfo(
          hoTen: kh['hoTen'] ?? '',
          diaChi: kh['diaChi'] ?? '',
          soDienThoai: kh['soDienThoai'] ?? '',
          email: kh['email'] ?? '',
          cccd: kh['cccd'] ?? '',
          donViCongTac: kh['donViCongTac'] ?? '',
          cccdNgayCap: DateTime.tryParse(kh['cccdNgayCap']?.toString() ?? '') ?? DateTime.now(),
          cccdNoiCap: kh['cccdNoiCap'] ?? '',
        ),
        danhSachThietBi: devices,
        ngayBatDau: ngayBatDau,
        ngayKetThuc: ngayKetThuc,
        soThangThue: detail['soThangThue'] ?? 0,
        tongChiPhiThue: (chiPhi['tongTienThue'] ?? 0).toDouble(),
        tienDatCoc: (chiPhi['tienCoc'] ?? 0).toDouble(),
        phiTreHanPhanTram: (chiPhi['phiTreHanPhanTram'] ?? 3.0).toDouble(),
        soNgayTreHanMoiKy: chiPhi['soNgayTreHanMoiKy'] ?? 3,
        soNgayViPhamChamDut: chiPhi['soNgayViPhamChamDut'] ?? 15,
        phiVeSinhChuyenSau: (chiPhi['phiVeSinhChuyenSau'] ?? 1000000).toDouble(),
        khauHaoHaoMonNam: (chiPhi['khauHaoHaoMonNam'] ?? 0).toDouble(),
        phiGianDoanPhanTram: (chiPhi['phiGianDoanPhanTram'] ?? 50.0).toDouble(),
      );

      if (mounted) setState(() { _contractData = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(_contractData?.maHopDong ?? 'Hợp đồng', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 8),
        Text('Không thể tải hợp đồng', style: TextStyle(color: AppColors.textHint)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadContract, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(120, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Thử lại')),
      ]));
    }
    if (_contractData == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ReusableElectronicContract(data: _contractData!),
    );
  }
}
