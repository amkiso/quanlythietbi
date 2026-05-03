// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vai_tro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaiTro _$VaiTroFromJson(Map<String, dynamic> json) => VaiTro(
  vaiTroId: (json['vaiTroId'] as num?)?.toInt(),
  tenVaiTro: json['tenVaiTro'] as String,
  moTa: json['moTa'] as String?,
);

Map<String, dynamic> _$VaiTroToJson(VaiTro instance) => <String, dynamic>{
  'vaiTroId': instance.vaiTroId,
  'tenVaiTro': instance.tenVaiTro,
  'moTa': instance.moTa,
};
