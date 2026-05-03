// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chi_tiet_thue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChiTietThue _$ChiTietThueFromJson(Map<String, dynamic> json) => ChiTietThue(
  hopDongId: (json['hopDongId'] as num).toInt(),
  thietBiId: (json['thietBiId'] as num).toInt(),
  giaThueThucTe: (json['giaThueThucTe'] as num).toDouble(),
);

Map<String, dynamic> _$ChiTietThueToJson(ChiTietThue instance) =>
    <String, dynamic>{
      'hopDongId': instance.hopDongId,
      'thietBiId': instance.thietBiId,
      'giaThueThucTe': instance.giaThueThucTe,
    };
