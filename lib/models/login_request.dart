import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Request body cho API đăng nhập
/// Map với LoginRequest.java
@JsonSerializable()
class LoginRequest {
  final String taiKhoan;
  final String matKhau;

  LoginRequest({
    required this.taiKhoan,
    required this.matKhau,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
