import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

/// Response body sau khi đăng nhập thành công
/// Map với LoginResponse.java (API v3 — dùng NguoiDung thay vì NhanVien)
@JsonSerializable()
class LoginResponse {
  final String token;
  final int nguoiDungId;
  final String hoTen;
  final String maNguoiDung;
  final int vaiTroId;
  final String tenVaiTro;
  final int? khoId;
  final bool doiMatKhauLanDau;
  final String? avt;

  LoginResponse({
    required this.token,
    required this.nguoiDungId,
    required this.hoTen,
    required this.maNguoiDung,
    required this.vaiTroId,
    required this.tenVaiTro,
    this.khoId,
    this.doiMatKhauLanDau = false,
    this.avt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
