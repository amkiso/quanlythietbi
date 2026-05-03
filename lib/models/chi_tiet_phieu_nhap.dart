import 'package:json_annotation/json_annotation.dart';

part 'chi_tiet_phieu_nhap.g.dart';

/// Entity chi tiết phiếu nhập - Map với ChiTietPhieuNhap.java
@JsonSerializable()
class ChiTietPhieuNhap {
  final int phieuNhapId;
  final int loaiThietBiId;
  final int soLuong;
  final double donGiaNhap;

  ChiTietPhieuNhap({
    required this.phieuNhapId,
    required this.loaiThietBiId,
    required this.soLuong,
    required this.donGiaNhap,
  });

  factory ChiTietPhieuNhap.fromJson(Map<String, dynamic> json) =>
      _$ChiTietPhieuNhapFromJson(json);

  Map<String, dynamic> toJson() => _$ChiTietPhieuNhapToJson(this);
}
