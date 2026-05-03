import 'package:json_annotation/json_annotation.dart';

part 'danh_muc_thiet_bi.g.dart';

/// Entity danh mục thiết bị - Map với DanhMucThietBi.java
@JsonSerializable()
class DanhMucThietBi {
  final int? danhMucId;
  final String tenDanhMuc;

  DanhMucThietBi({
    this.danhMucId,
    required this.tenDanhMuc,
  });

  factory DanhMucThietBi.fromJson(Map<String, dynamic> json) =>
      _$DanhMucThietBiFromJson(json);

  Map<String, dynamic> toJson() => _$DanhMucThietBiToJson(this);
}
