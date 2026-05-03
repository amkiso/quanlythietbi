// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thiet_bi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThietBi _$ThietBiFromJson(Map<String, dynamic> json) => ThietBi(
  thietBiId: (json['thietBiId'] as num?)?.toInt(),
  loaiThietBiId: (json['loaiThietBiId'] as num).toInt(),
  maTaiSan: json['maTaiSan'] as String,
  tinhTrangId: (json['tinhTrangId'] as num).toInt(),
  khoHienTaiId: (json['khoHienTaiId'] as num).toInt(),
  ngayBaoTriTiepTheo: json['ngayBaoTriTiepTheo'] == null
      ? null
      : DateTime.parse(json['ngayBaoTriTiepTheo'] as String),
);

Map<String, dynamic> _$ThietBiToJson(ThietBi instance) => <String, dynamic>{
  'thietBiId': instance.thietBiId,
  'loaiThietBiId': instance.loaiThietBiId,
  'maTaiSan': instance.maTaiSan,
  'tinhTrangId': instance.tinhTrangId,
  'khoHienTaiId': instance.khoHienTaiId,
  'ngayBaoTriTiepTheo': instance.ngayBaoTriTiepTheo?.toIso8601String(),
};
