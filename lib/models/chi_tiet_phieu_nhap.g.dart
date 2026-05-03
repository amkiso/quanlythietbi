// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chi_tiet_phieu_nhap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChiTietPhieuNhap _$ChiTietPhieuNhapFromJson(Map<String, dynamic> json) =>
    ChiTietPhieuNhap(
      phieuNhapId: (json['phieuNhapId'] as num).toInt(),
      loaiThietBiId: (json['loaiThietBiId'] as num).toInt(),
      soLuong: (json['soLuong'] as num).toInt(),
      donGiaNhap: (json['donGiaNhap'] as num).toDouble(),
    );

Map<String, dynamic> _$ChiTietPhieuNhapToJson(ChiTietPhieuNhap instance) =>
    <String, dynamic>{
      'phieuNhapId': instance.phieuNhapId,
      'loaiThietBiId': instance.loaiThietBiId,
      'soLuong': instance.soLuong,
      'donGiaNhap': instance.donGiaNhap,
    };
