import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/thiet_bi_service.dart';
import '../widgets/cloud_image.dart';
import 'package:intl/intl.dart';

class DeviceScanResultScreen extends StatefulWidget {
  final Map<String, dynamic> deviceData;

  const DeviceScanResultScreen({
    super.key,
    required this.deviceData,
  });

  @override
  State<DeviceScanResultScreen> createState() => _DeviceScanResultScreenState();
}

class _DeviceScanResultScreenState extends State<DeviceScanResultScreen> {
  final ThietBiService _thietBiService = ThietBiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _contracts = [];
  List<Map<String, dynamic>> _maintenanceHistory = [];
  late Map<String, dynamic> _deviceData;

  @override
  void initState() {
    super.initState();
    _deviceData = Map<String, dynamic>.from(widget.deviceData);
    _loadExtraData();
  }

  Future<void> _loadExtraData() async {
    setState(() => _isLoading = true);
    try {
      final thietBiId = _deviceData['thietBiId'] as int;
      final results = await Future.wait([
        _thietBiService.getDeviceContracts(thietBiId),
        _thietBiService.getMaintenanceHistory(thietBiId),
      ]);

      if (mounted) {
        setState(() {
          _contracts = results[0];
          _maintenanceHistory = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(int newStatus) async {
    try {
      final thietBiId = _deviceData['thietBiId'] as int;
      final updated = await _thietBiService.updateStatus(thietBiId, newStatus);
      setState(() {
        _deviceData['tinhTrangId'] = newStatus;
        _deviceData['tenTinhTrang'] = newStatus == 1 ? 'Sẵn sàng' : 'Đang bảo trì';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: $e')),
        );
      }
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0 đ';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Chưa có';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _deviceData['tenLoaiThietBi'] ?? 'Thiết bị không xác định';
    final image = _deviceData['anhDaiDien'];
    final statusId = _deviceData['tinhTrangId'] as int?;
    final statusName = _deviceData['tenTinhTrang'] ?? 'Không rõ';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông tin thiết bị'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Info Card
                  _buildInfoCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: image != null
                              ? CloudImage(imageUrl: image, fit: BoxFit.cover)
                              : const Icon(Icons.devices, size: 40, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLabelValue('Mã TS:', _deviceData['maTaiSan']),
                              _buildLabelValue('Giá thuê:', _formatCurrency(_deviceData['giaThueThamKhao'])),
                              const SizedBox(height: 8),
                              _buildStatusBadge(statusId, statusName),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Maintenance Info
                  _buildInfoCard(
                    title: 'Thông tin bảo trì',
                    icon: Icons.build_circle_outlined,
                    child: Column(
                      children: [
                        _buildLabelValue('Bảo trì tiếp theo:', _formatDate(_deviceData['ngayBaoTriTiepTheo'])),
                        if (_maintenanceHistory.isNotEmpty) ...[
                          const Divider(),
                          _buildLabelValue('Lần cuối:', _formatDate(_maintenanceHistory.first['ngayThucHien'])),
                          _buildLabelValue('Nội dung:', _maintenanceHistory.first['noiDungBaoTri']),
                        ] else ...[
                          const Divider(),
                          const Text('Chưa có lịch sử bảo trì', style: TextStyle(color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contracts List
                  _buildInfoCard(
                    title: 'Hợp đồng tham gia',
                    icon: Icons.description_outlined,
                    child: _contracts.isEmpty
                        ? const Text('Chưa tham gia hợp đồng nào', style: TextStyle(color: Colors.grey))
                        : Column(
                            children: [
                              ..._contracts.take(3).map((c) => _buildContractItem(c)),
                              if (_contracts.length > 3)
                                TextButton(
                                  onPressed: () {
                                    // Show full list bottom sheet
                                    _showFullContractsSheet();
                                  },
                                  child: const Text('Xem tất cả'),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomActions(statusId),
    );
  }

  Widget _buildStatusBadge(int? statusId, String text) {
    Color color;
    if (statusId == 1) color = Colors.green;
    else if (statusId == 2) color = Colors.blue;
    else if (statusId == 3) color = Colors.orange;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoCard({String? title, IconData? icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractItem(Map<String, dynamic> contract) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8ECFF),
        child: Icon(Icons.description, color: AppColors.primary, size: 20),
      ),
      title: Text('HĐ: ${contract['hopDongId'] ?? 'N/A'}'),
      subtitle: Text(_formatDate(contract['ngayLap'])),
      trailing: _buildStatusBadge(contract['trangThaiId'], contract['trangThai'] ?? 'N/A'),
    );
  }

  void _showFullContractsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tất cả hợp đồng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _contracts.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => _buildContractItem(_contracts[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(int? statusId) {
    // Hide actions for status 2 (Renting) unless business logic allows it
    if (statusId == 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
        ]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Quay lại'),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Quay lại'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (statusId == 1) {
                    _updateStatus(3); // Start maintenance
                  } else if (statusId == 3) {
                    _updateStatus(1); // Finish maintenance
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusId == 1 ? Colors.orange : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(statusId == 1 ? 'Bảo trì' : 'Bảo trì xong'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
