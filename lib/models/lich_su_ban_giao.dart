import 'package:json_annotation/json_annotation.dart';

part 'lich_su_ban_giao.g.dart';

/// Entity lịch sử bàn giao - Map với LichSuBanGiao.java
@JsonSerializable()
class LichSuBanGiao {
  final int? banGiaoId;
  final int? hopDongId;
  final int thietBiId;
  final int tuKhoId;
  final int? denKhoId;
  final int nhanVienThucHienId;
  final DateTime ngayGiaoNhan;
  final String? nguoiNhan;
  final String? hinhAnhXacNhan;
  final int loaiGiaoDichId;
  final String? ghiChuTinhTrang;

  LichSuBanGiao({
    this.banGiaoId,
    this.hopDongId,
    required this.thietBiId,
    required this.tuKhoId,
    this.denKhoId,
    required this.nhanVienThucHienId,
    required this.ngayGiaoNhan,
    this.nguoiNhan,
    this.hinhAnhXacNhan,
    required this.loaiGiaoDichId,
    this.ghiChuTinhTrang,
  });

  factory LichSuBanGiao.fromJson(Map<String, dynamic> json) =>
      _$LichSuBanGiaoFromJson(json);

  Map<String, dynamic> toJson() => _$LichSuBanGiaoToJson(this);
}
