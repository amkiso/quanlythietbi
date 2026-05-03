import 'package:json_annotation/json_annotation.dart';

part 'hop_dong_thue.g.dart';

/// Entity hợp đồng thuê - Map với HopDongThue.java
@JsonSerializable()
class HopDongThue {
  final int? hopDongId;
  final int khachHangId;
  final int nhanVienLapId;
  final DateTime ngayLap;
  final DateTime ngayBatDauThue;
  final DateTime ngayDuKienTra;
  final DateTime? ngayTraThucTe;
  final String diaDiemGiao;
  final double tienCoc;
  final double tongTienThue;
  final int trangThaiId;

  HopDongThue({
    this.hopDongId,
    required this.khachHangId,
    required this.nhanVienLapId,
    required this.ngayLap,
    required this.ngayBatDauThue,
    required this.ngayDuKienTra,
    this.ngayTraThucTe,
    required this.diaDiemGiao,
    required this.tienCoc,
    required this.tongTienThue,
    required this.trangThaiId,
  });

  factory HopDongThue.fromJson(Map<String, dynamic> json) =>
      _$HopDongThueFromJson(json);

  Map<String, dynamic> toJson() => _$HopDongThueToJson(this);
}
