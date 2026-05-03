import 'package:json_annotation/json_annotation.dart';

part 'nhan_vien.g.dart';

/// Entity nhân viên - Map với NhanVien.java
@JsonSerializable()
class NhanVien {
  final int? nhanVienId;
  final String maNhanVien;
  final String hoTen;
  final String taiKhoan;
  final String? matKhau; // Không trả về từ API (bảo mật)
  final int vaiTroId;
  final int khoId;
  final int trangThaiId;

  NhanVien({
    this.nhanVienId,
    required this.maNhanVien,
    required this.hoTen,
    required this.taiKhoan,
    this.matKhau,
    required this.vaiTroId,
    required this.khoId,
    required this.trangThaiId,
  });

  factory NhanVien.fromJson(Map<String, dynamic> json) =>
      _$NhanVienFromJson(json);

  Map<String, dynamic> toJson() => _$NhanVienToJson(this);
}
