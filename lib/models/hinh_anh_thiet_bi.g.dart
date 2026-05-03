// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hinh_anh_thiet_bi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HinhAnhThietBi _$HinhAnhThietBiFromJson(Map<String, dynamic> json) =>
    HinhAnhThietBi(
      hinhAnhId: (json['hinhAnhId'] as num?)?.toInt(),
      thietBiId: (json['thietBiId'] as num).toInt(),
      nhanVienChupId: (json['nhanVienChupId'] as num).toInt(),
      urlAnh: json['urlAnh'] as String,
      loaiAnhId: (json['loaiAnhId'] as num).toInt(),
      ngayChup: DateTime.parse(json['ngayChup'] as String),
    );

Map<String, dynamic> _$HinhAnhThietBiToJson(HinhAnhThietBi instance) =>
    <String, dynamic>{
      'hinhAnhId': instance.hinhAnhId,
      'thietBiId': instance.thietBiId,
      'nhanVienChupId': instance.nhanVienChupId,
      'urlAnh': instance.urlAnh,
      'loaiAnhId': instance.loaiAnhId,
      'ngayChup': instance.ngayChup.toIso8601String(),
    };
