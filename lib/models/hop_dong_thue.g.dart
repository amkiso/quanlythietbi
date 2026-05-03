// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hop_dong_thue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HopDongThue _$HopDongThueFromJson(Map<String, dynamic> json) => HopDongThue(
  hopDongId: (json['hopDongId'] as num?)?.toInt(),
  khachHangId: (json['khachHangId'] as num).toInt(),
  nhanVienLapId: (json['nhanVienLapId'] as num).toInt(),
  ngayLap: DateTime.parse(json['ngayLap'] as String),
  ngayBatDauThue: DateTime.parse(json['ngayBatDauThue'] as String),
  ngayDuKienTra: DateTime.parse(json['ngayDuKienTra'] as String),
  ngayTraThucTe: json['ngayTraThucTe'] == null
      ? null
      : DateTime.parse(json['ngayTraThucTe'] as String),
  diaDiemGiao: json['diaDiemGiao'] as String,
  tienCoc: (json['tienCoc'] as num).toDouble(),
  tongTienThue: (json['tongTienThue'] as num).toDouble(),
  trangThaiId: (json['trangThaiId'] as num).toInt(),
);

Map<String, dynamic> _$HopDongThueToJson(HopDongThue instance) =>
    <String, dynamic>{
      'hopDongId': instance.hopDongId,
      'khachHangId': instance.khachHangId,
      'nhanVienLapId': instance.nhanVienLapId,
      'ngayLap': instance.ngayLap.toIso8601String(),
      'ngayBatDauThue': instance.ngayBatDauThue.toIso8601String(),
      'ngayDuKienTra': instance.ngayDuKienTra.toIso8601String(),
      'ngayTraThucTe': instance.ngayTraThucTe?.toIso8601String(),
      'diaDiemGiao': instance.diaDiemGiao,
      'tienCoc': instance.tienCoc,
      'tongTienThue': instance.tongTienThue,
      'trangThaiId': instance.trangThaiId,
    };
