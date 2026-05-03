import 'package:json_annotation/json_annotation.dart';

part 'chi_tiet_thue.g.dart';

/// Entity chi tiết thuê - Map với ChiTietThue.java
@JsonSerializable()
class ChiTietThue {
  final int hopDongId;
  final int thietBiId;
  final double giaThueThucTe;

  ChiTietThue({
    required this.hopDongId,
    required this.thietBiId,
    required this.giaThueThucTe,
  });

  factory ChiTietThue.fromJson(Map<String, dynamic> json) =>
      _$ChiTietThueFromJson(json);

  Map<String, dynamic> toJson() => _$ChiTietThueToJson(this);
}
