// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SasUploadData _$SasUploadDataFromJson(Map<String, dynamic> json) =>
    SasUploadData(
      sasUrl: json['sasUrl'] as String,
      fileName: json['fileName'] as String,
      publicUrl: json['publicUrl'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$SasUploadDataToJson(SasUploadData instance) =>
    <String, dynamic>{
      'sasUrl': instance.sasUrl,
      'fileName': instance.fileName,
      'publicUrl': instance.publicUrl,
      'category': instance.category,
    };

AvatarUpdateData _$AvatarUpdateDataFromJson(Map<String, dynamic> json) =>
    AvatarUpdateData(
      nguoiDungId: json['nguoiDungId'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );

Map<String, dynamic> _$AvatarUpdateDataToJson(AvatarUpdateData instance) =>
    <String, dynamic>{
      'nguoiDungId': instance.nguoiDungId,
      'avatarUrl': instance.avatarUrl,
    };

ImageConfirmData _$ImageConfirmDataFromJson(Map<String, dynamic> json) =>
    ImageConfirmData(
      hinhAnhId: (json['hinhAnhId'] as num).toInt(),
      thietBiId: (json['thietBiId'] as num).toInt(),
      nguoiDungChupId: (json['nguoiDungChupId'] as num).toInt(),
      urlAnh: json['urlAnh'] as String,
      loaiAnhId: (json['loaiAnhId'] as num).toInt(),
      ngayChup: DateTime.parse(json['ngayChup'] as String),
      banGiaoId: (json['banGiaoId'] as num?)?.toInt(),
      baoTriId: (json['baoTriId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ImageConfirmDataToJson(ImageConfirmData instance) =>
    <String, dynamic>{
      'hinhAnhId': instance.hinhAnhId,
      'thietBiId': instance.thietBiId,
      'nguoiDungChupId': instance.nguoiDungChupId,
      'urlAnh': instance.urlAnh,
      'loaiAnhId': instance.loaiAnhId,
      'ngayChup': instance.ngayChup.toIso8601String(),
      'banGiaoId': instance.banGiaoId,
      'baoTriId': instance.baoTriId,
    };
