import 'package:json_annotation/json_annotation.dart';

part 'thiet_bi.g.dart';

/// Entity thiết bị - Map với ThietBi.java
@JsonSerializable()
class ThietBi {
  final int? thietBiId;
  final int loaiThietBiId;
  final String maTaiSan;
  final int tinhTrangId;
  final int khoHienTaiId;
  final DateTime? ngayBaoTriTiepTheo;

  ThietBi({
    this.thietBiId,
    required this.loaiThietBiId,
    required this.maTaiSan,
    required this.tinhTrangId,
    required this.khoHienTaiId,
    this.ngayBaoTriTiepTheo,
  });

  factory ThietBi.fromJson(Map<String, dynamic> json) =>
      _$ThietBiFromJson(json);

  Map<String, dynamic> toJson() => _$ThietBiToJson(this);
}
