// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phieu_nhap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhieuNhap _$PhieuNhapFromJson(Map<String, dynamic> json) => PhieuNhap(
  phieuNhapId: (json['phieuNhapId'] as num?)?.toInt(),
  nhaCungCapId: (json['nhaCungCapId'] as num).toInt(),
  nhanVienNhapId: (json['nhanVienNhapId'] as num).toInt(),
  ngayNhap: DateTime.parse(json['ngayNhap'] as String),
  tongTienNhap: (json['tongTienNhap'] as num).toDouble(),
  ghiChu: json['ghiChu'] as String?,
);

Map<String, dynamic> _$PhieuNhapToJson(PhieuNhap instance) => <String, dynamic>{
  'phieuNhapId': instance.phieuNhapId,
  'nhaCungCapId': instance.nhaCungCapId,
  'nhanVienNhapId': instance.nhanVienNhapId,
  'ngayNhap': instance.ngayNhap.toIso8601String(),
  'tongTienNhap': instance.tongTienNhap,
  'ghiChu': instance.ghiChu,
};
