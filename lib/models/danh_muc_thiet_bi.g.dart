// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'danh_muc_thiet_bi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DanhMucThietBi _$DanhMucThietBiFromJson(Map<String, dynamic> json) =>
    DanhMucThietBi(
      danhMucId: (json['danhMucId'] as num?)?.toInt(),
      tenDanhMuc: json['tenDanhMuc'] as String,
    );

Map<String, dynamic> _$DanhMucThietBiToJson(DanhMucThietBi instance) =>
    <String, dynamic>{
      'danhMucId': instance.danhMucId,
      'tenDanhMuc': instance.tenDanhMuc,
    };
