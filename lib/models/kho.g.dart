// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kho.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Kho _$KhoFromJson(Map<String, dynamic> json) => Kho(
  khoId: (json['khoId'] as num?)?.toInt(),
  tenKho: json['tenKho'] as String,
  diaChi: json['diaChi'] as String?,
  nguoiPhuTrach: json['nguoiPhuTrach'] as String?,
  soDienThoai: json['soDienThoai'] as String?,
);

Map<String, dynamic> _$KhoToJson(Kho instance) => <String, dynamic>{
  'khoId': instance.khoId,
  'tenKho': instance.tenKho,
  'diaChi': instance.diaChi,
  'nguoiPhuTrach': instance.nguoiPhuTrach,
  'soDienThoai': instance.soDienThoai,
};
