// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lich_su_ban_giao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LichSuBanGiao _$LichSuBanGiaoFromJson(Map<String, dynamic> json) =>
    LichSuBanGiao(
      banGiaoId: (json['banGiaoId'] as num?)?.toInt(),
      hopDongId: (json['hopDongId'] as num?)?.toInt(),
      thietBiId: (json['thietBiId'] as num).toInt(),
      tuKhoId: (json['tuKhoId'] as num).toInt(),
      denKhoId: (json['denKhoId'] as num?)?.toInt(),
      nhanVienThucHienId: (json['nhanVienThucHienId'] as num).toInt(),
      ngayGiaoNhan: DateTime.parse(json['ngayGiaoNhan'] as String),
      nguoiNhan: json['nguoiNhan'] as String?,
      hinhAnhXacNhan: json['hinhAnhXacNhan'] as String?,
      loaiGiaoDichId: (json['loaiGiaoDichId'] as num).toInt(),
      ghiChuTinhTrang: json['ghiChuTinhTrang'] as String?,
    );

Map<String, dynamic> _$LichSuBanGiaoToJson(LichSuBanGiao instance) =>
    <String, dynamic>{
      'banGiaoId': instance.banGiaoId,
      'hopDongId': instance.hopDongId,
      'thietBiId': instance.thietBiId,
      'tuKhoId': instance.tuKhoId,
      'denKhoId': instance.denKhoId,
      'nhanVienThucHienId': instance.nhanVienThucHienId,
      'ngayGiaoNhan': instance.ngayGiaoNhan.toIso8601String(),
      'nguoiNhan': instance.nguoiNhan,
      'hinhAnhXacNhan': instance.hinhAnhXacNhan,
      'loaiGiaoDichId': instance.loaiGiaoDichId,
      'ghiChuTinhTrang': instance.ghiChuTinhTrang,
    };
