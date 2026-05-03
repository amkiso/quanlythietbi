import 'package:json_annotation/json_annotation.dart';

part 'nha_cung_cap.g.dart';

/// Entity nhà cung cấp - Map với NhaCungCap.java
@JsonSerializable()
class NhaCungCap {
  final int? nhaCungCapId;
  final String tenNhaCungCap;
  final String? nguoiLienHe;
  final String? soDienThoai;
  final String? diaChi;

  NhaCungCap({
    this.nhaCungCapId,
    required this.tenNhaCungCap,
    this.nguoiLienHe,
    this.soDienThoai,
    this.diaChi,
  });

  factory NhaCungCap.fromJson(Map<String, dynamic> json) =>
      _$NhaCungCapFromJson(json);

  Map<String, dynamic> toJson() => _$NhaCungCapToJson(this);
}
