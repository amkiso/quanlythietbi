import 'package:json_annotation/json_annotation.dart';

part 'doi_mat_khau_request.g.dart';

/// Request body cho API đổi mật khẩu
/// Map với DoiMatKhauRequest.java
@JsonSerializable()
class DoiMatKhauRequest {
  final String matKhauCu;
  final String matKhauMoi;

  DoiMatKhauRequest({
    required this.matKhauCu,
    required this.matKhauMoi,
  });

  factory DoiMatKhauRequest.fromJson(Map<String, dynamic> json) =>
      _$DoiMatKhauRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DoiMatKhauRequestToJson(this);
}
