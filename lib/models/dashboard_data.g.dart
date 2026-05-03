// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      doanhThuThangNay: (json['doanhThuThangNay'] as num).toDouble(),
      doanhThuThangTruoc: (json['doanhThuThangTruoc'] as num).toDouble(),
      tiLeTangTruong: (json['tiLeTangTruong'] as num).toDouble(),
      soThietBiDangBaoTri: (json['soThietBiDangBaoTri'] as num).toInt(),
      soHopDongDenHan: (json['soHopDongDenHan'] as num).toInt(),
      nhacNhoHomNay: (json['nhacNhoHomNay'] as List<dynamic>)
          .map((e) => NhacNhoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'doanhThuThangNay': instance.doanhThuThangNay,
      'doanhThuThangTruoc': instance.doanhThuThangTruoc,
      'tiLeTangTruong': instance.tiLeTangTruong,
      'soThietBiDangBaoTri': instance.soThietBiDangBaoTri,
      'soHopDongDenHan': instance.soHopDongDenHan,
      'nhacNhoHomNay': instance.nhacNhoHomNay,
    };

NhacNhoItem _$NhacNhoItemFromJson(Map<String, dynamic> json) => NhacNhoItem(
      loai: json['loai'] as String,
      tieuDe: json['tieuDe'] as String,
      moTa: json['moTa'] as String,
      referenceId: (json['referenceId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NhacNhoItemToJson(NhacNhoItem instance) =>
    <String, dynamic>{
      'loai': instance.loai,
      'tieuDe': instance.tieuDe,
      'moTa': instance.moTa,
      'referenceId': instance.referenceId,
    };
