// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loai_thiet_bi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoaiThietBi _$LoaiThietBiFromJson(Map<String, dynamic> json) => LoaiThietBi(
  loaiThietBiId: (json['loaiThietBiId'] as num?)?.toInt(),
  danhMucId: (json['danhMucId'] as num).toInt(),
  nhaCungCapId: (json['nhaCungCapId'] as num).toInt(),
  tenLoaiThietBi: json['tenLoaiThietBi'] as String,
  thongSoKyThuat: json['thongSoKyThuat'] as String?,
  giaThueThamKhao: (json['giaThueThamKhao'] as num).toDouble(),
  anhDaiDien: json['anhDaiDien'] as String?,
);

Map<String, dynamic> _$LoaiThietBiToJson(LoaiThietBi instance) =>
    <String, dynamic>{
      'loaiThietBiId': instance.loaiThietBiId,
      'danhMucId': instance.danhMucId,
      'nhaCungCapId': instance.nhaCungCapId,
      'tenLoaiThietBi': instance.tenLoaiThietBi,
      'thongSoKyThuat': instance.thongSoKyThuat,
      'giaThueThamKhao': instance.giaThueThamKhao,
      'anhDaiDien': instance.anhDaiDien,
    };
