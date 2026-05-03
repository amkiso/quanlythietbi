import 'package:json_annotation/json_annotation.dart';

part 'dashboard_data.g.dart';

/// Model cho dữ liệu Dashboard Admin
/// Map với response từ GET /api/dashboard
@JsonSerializable()
class DashboardData {
  final double doanhThuThangNay;
  final double doanhThuThangTruoc;
  final double tiLeTangTruong;
  final int soThietBiDangBaoTri;
  final int soHopDongDenHan;
  final List<NhacNhoItem> nhacNhoHomNay;

  DashboardData({
    required this.doanhThuThangNay,
    required this.doanhThuThangTruoc,
    required this.tiLeTangTruong,
    required this.soThietBiDangBaoTri,
    required this.soHopDongDenHan,
    required this.nhacNhoHomNay,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);
}

/// Model cho mỗi item nhắc nhở hôm nay
@JsonSerializable()
class NhacNhoItem {
  final String loai;
  final String tieuDe;
  final String moTa;
  final int? referenceId;

  NhacNhoItem({
    required this.loai,
    required this.tieuDe,
    required this.moTa,
    this.referenceId,
  });

  factory NhacNhoItem.fromJson(Map<String, dynamic> json) =>
      _$NhacNhoItemFromJson(json);

  Map<String, dynamic> toJson() => _$NhacNhoItemToJson(this);
}
