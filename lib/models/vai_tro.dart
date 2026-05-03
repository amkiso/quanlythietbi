import 'package:json_annotation/json_annotation.dart';

part 'vai_tro.g.dart';

/// Entity vai trò - Map với VaiTro.java
@JsonSerializable()
class VaiTro {
  final int? vaiTroId;
  final String tenVaiTro;
  final String? moTa;

  VaiTro({
    this.vaiTroId,
    required this.tenVaiTro,
    this.moTa,
  });

  factory VaiTro.fromJson(Map<String, dynamic> json) =>
      _$VaiTroFromJson(json);

  Map<String, dynamic> toJson() => _$VaiTroToJson(this);
}
