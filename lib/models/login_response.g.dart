// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String,
      nguoiDungId: (json['nguoiDungId'] as num).toInt(),
      hoTen: json['hoTen'] as String,
      maNguoiDung: json['maNguoiDung'] as String,
      vaiTroId: (json['vaiTroId'] as num).toInt(),
      tenVaiTro: json['tenVaiTro'] as String,
      khoId: (json['khoId'] as num?)?.toInt(),
      doiMatKhauLanDau: json['doiMatKhauLanDau'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'nguoiDungId': instance.nguoiDungId,
      'hoTen': instance.hoTen,
      'maNguoiDung': instance.maNguoiDung,
      'vaiTroId': instance.vaiTroId,
      'tenVaiTro': instance.tenVaiTro,
      'khoId': instance.khoId,
      'doiMatKhauLanDau': instance.doiMatKhauLanDau,
    };
