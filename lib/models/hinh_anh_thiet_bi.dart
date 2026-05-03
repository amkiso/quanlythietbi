import 'package:json_annotation/json_annotation.dart';

part 'hinh_anh_thiet_bi.g.dart';

/// Entity hình ảnh thiết bị - Map với HinhAnhThietBi.java
@JsonSerializable()
class HinhAnhThietBi {
  final int? hinhAnhId;
  final int thietBiId;
  final int nhanVienChupId;
  final String urlAnh;
  final int loaiAnhId;
  final DateTime ngayChup;

  HinhAnhThietBi({
    this.hinhAnhId,
    required this.thietBiId,
    required this.nhanVienChupId,
    required this.urlAnh,
    required this.loaiAnhId,
    required this.ngayChup,
  });

  factory HinhAnhThietBi.fromJson(Map<String, dynamic> json) =>
      _$HinhAnhThietBiFromJson(json);

  Map<String, dynamic> toJson() => _$HinhAnhThietBiToJson(this);
}
