// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khach_hang.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KhachHang _$KhachHangFromJson(Map<String, dynamic> json) => KhachHang(
  khachHangId: (json['khachHangId'] as num?)?.toInt(),
  hoTen: json['hoTen'] as String,
  soDienThoai: json['soDienThoai'] as String,
  email: json['email'] as String?,
  diaChi: json['diaChi'] as String?,
  loaiId: (json['loaiId'] as num).toInt(),
  maSoThue: json['maSoThue'] as String?,
);

Map<String, dynamic> _$KhachHangToJson(KhachHang instance) => <String, dynamic>{
  'khachHangId': instance.khachHangId,
  'hoTen': instance.hoTen,
  'soDienThoai': instance.soDienThoai,
  'email': instance.email,
  'diaChi': instance.diaChi,
  'loaiId': instance.loaiId,
  'maSoThue': instance.maSoThue,
};
