import 'package:json_annotation/json_annotation.dart';

part 'khach_hang.g.dart';

/// Entity khách hàng - Map với KhachHang.java
@JsonSerializable()
class KhachHang {
  final int? khachHangId;
  final String hoTen;
  final String soDienThoai;
  final String? email;
  final String? diaChi;
  final int loaiId;
  final String? maSoThue;

  KhachHang({
    this.khachHangId,
    required this.hoTen,
    required this.soDienThoai,
    this.email,
    this.diaChi,
    required this.loaiId,
    this.maSoThue,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) =>
      _$KhachHangFromJson(json);

  Map<String, dynamic> toJson() => _$KhachHangToJson(this);
}
