import 'package:json_annotation/json_annotation.dart';

part 'phieu_nhap.g.dart';

/// Entity phiếu nhập - Map với PhieuNhap.java
@JsonSerializable()
class PhieuNhap {
  final int? phieuNhapId;
  final int nhaCungCapId;
  final int nhanVienNhapId;
  final DateTime ngayNhap;
  final double tongTienNhap;
  final String? ghiChu;

  PhieuNhap({
    this.phieuNhapId,
    required this.nhaCungCapId,
    required this.nhanVienNhapId,
    required this.ngayNhap,
    required this.tongTienNhap,
    this.ghiChu,
  });

  factory PhieuNhap.fromJson(Map<String, dynamic> json) =>
      _$PhieuNhapFromJson(json);

  Map<String, dynamic> toJson() => _$PhieuNhapToJson(this);
}
