import 'package:json_annotation/json_annotation.dart';

part 'lich_su_bao_tri.g.dart';

/// Entity lịch sử bảo trì - Map với LichSuBaoTri.java
@JsonSerializable()
class LichSuBaoTri {
  final int? baoTriId;
  final int thietBiId;
  final int nhanVienBaoTriId;
  final DateTime ngayThucHien;
  final int loaiBaoTriId;
  final String noiDungBaoTri;
  final double chiPhi;
  final int trangThaiId;
  final String? ghiChu;

  LichSuBaoTri({
    this.baoTriId,
    required this.thietBiId,
    required this.nhanVienBaoTriId,
    required this.ngayThucHien,
    required this.loaiBaoTriId,
    required this.noiDungBaoTri,
    required this.chiPhi,
    required this.trangThaiId,
    this.ghiChu,
  });

  factory LichSuBaoTri.fromJson(Map<String, dynamic> json) =>
      _$LichSuBaoTriFromJson(json);

  Map<String, dynamic> toJson() => _$LichSuBaoTriToJson(this);
}
