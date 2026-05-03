import 'package:json_annotation/json_annotation.dart';

part 'loai_thiet_bi.g.dart';

/// Entity loại thiết bị - Map với LoaiThietBi.java
@JsonSerializable()
class LoaiThietBi {
  final int? loaiThietBiId;
  final int danhMucId;
  final int nhaCungCapId;
  final String tenLoaiThietBi;
  final String? thongSoKyThuat;
  final double giaThueThamKhao;
  final String? anhDaiDien;

  LoaiThietBi({
    this.loaiThietBiId,
    required this.danhMucId,
    required this.nhaCungCapId,
    required this.tenLoaiThietBi,
    this.thongSoKyThuat,
    required this.giaThueThamKhao,
    this.anhDaiDien,
  });

  factory LoaiThietBi.fromJson(Map<String, dynamic> json) =>
      _$LoaiThietBiFromJson(json);

  Map<String, dynamic> toJson() => _$LoaiThietBiToJson(this);
}
