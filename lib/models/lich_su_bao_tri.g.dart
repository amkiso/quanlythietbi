// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lich_su_bao_tri.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LichSuBaoTri _$LichSuBaoTriFromJson(Map<String, dynamic> json) => LichSuBaoTri(
  baoTriId: (json['baoTriId'] as num?)?.toInt(),
  thietBiId: (json['thietBiId'] as num).toInt(),
  nhanVienBaoTriId: (json['nhanVienBaoTriId'] as num).toInt(),
  ngayThucHien: DateTime.parse(json['ngayThucHien'] as String),
  loaiBaoTriId: (json['loaiBaoTriId'] as num).toInt(),
  noiDungBaoTri: json['noiDungBaoTri'] as String,
  chiPhi: (json['chiPhi'] as num).toDouble(),
  trangThaiId: (json['trangThaiId'] as num).toInt(),
  ghiChu: json['ghiChu'] as String?,
);

Map<String, dynamic> _$LichSuBaoTriToJson(LichSuBaoTri instance) =>
    <String, dynamic>{
      'baoTriId': instance.baoTriId,
      'thietBiId': instance.thietBiId,
      'nhanVienBaoTriId': instance.nhanVienBaoTriId,
      'ngayThucHien': instance.ngayThucHien.toIso8601String(),
      'loaiBaoTriId': instance.loaiBaoTriId,
      'noiDungBaoTri': instance.noiDungBaoTri,
      'chiPhi': instance.chiPhi,
      'trangThaiId': instance.trangThaiId,
      'ghiChu': instance.ghiChu,
    };
