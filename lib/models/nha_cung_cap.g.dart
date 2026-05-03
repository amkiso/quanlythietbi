// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nha_cung_cap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NhaCungCap _$NhaCungCapFromJson(Map<String, dynamic> json) => NhaCungCap(
  nhaCungCapId: (json['nhaCungCapId'] as num?)?.toInt(),
  tenNhaCungCap: json['tenNhaCungCap'] as String,
  nguoiLienHe: json['nguoiLienHe'] as String?,
  soDienThoai: json['soDienThoai'] as String?,
  diaChi: json['diaChi'] as String?,
);

Map<String, dynamic> _$NhaCungCapToJson(NhaCungCap instance) =>
    <String, dynamic>{
      'nhaCungCapId': instance.nhaCungCapId,
      'tenNhaCungCap': instance.tenNhaCungCap,
      'nguoiLienHe': instance.nguoiLienHe,
      'soDienThoai': instance.soDienThoai,
      'diaChi': instance.diaChi,
    };
