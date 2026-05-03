import 'package:json_annotation/json_annotation.dart';

part 'kho.g.dart';

/// Entity kho - Map với Kho.java
@JsonSerializable()
class Kho {
  final int? khoId;
  final String tenKho;
  final String? diaChi;
  final String? nguoiPhuTrach;
  final String? soDienThoai;

  Kho({
    this.khoId,
    required this.tenKho,
    this.diaChi,
    this.nguoiPhuTrach,
    this.soDienThoai,
  });

  factory Kho.fromJson(Map<String, dynamic> json) => _$KhoFromJson(json);

  Map<String, dynamic> toJson() => _$KhoToJson(this);
}
