import 'package:json_annotation/json_annotation.dart';

part 'image_upload_response.g.dart';

/// Phản hồi từ API GET /{category}/get-upload-url
/// Chứa SAS URL và thông tin file cần upload
@JsonSerializable()
class SasUploadData {
  /// SAS URL có thời hạn 5 phút để upload trực tiếp lên Azure
  final String sasUrl;

  /// Tên file UUID được server tạo (vd: "a1b2c3d4-...jpg")
  final String fileName;

  /// URL công khai truy cập ảnh sau khi upload thành công
  final String publicUrl;

  /// Container: "user" | "products" | "work"
  final String category;

  SasUploadData({
    required this.sasUrl,
    required this.fileName,
    required this.publicUrl,
    required this.category,
  });

  factory SasUploadData.fromJson(Map<String, dynamic> json) =>
      _$SasUploadDataFromJson(json);
  Map<String, dynamic> toJson() => _$SasUploadDataToJson(this);
}

/// Phản hồi từ API POST /user/update-avatar
@JsonSerializable()
class AvatarUpdateData {
  final String nguoiDungId;
  final String avatarUrl;

  AvatarUpdateData({
    required this.nguoiDungId,
    required this.avatarUrl,
  });

  factory AvatarUpdateData.fromJson(Map<String, dynamic> json) =>
      _$AvatarUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$AvatarUpdateDataToJson(this);
}

/// Phản hồi từ API POST /products/thiet-bi/{id}/update-image
/// và POST /work/thiet-bi/{id}/update-image
@JsonSerializable()
class ImageConfirmData {
  final int hinhAnhId;
  final int thietBiId;
  final int nguoiDungChupId;
  final String urlAnh;
  final int loaiAnhId;
  final DateTime ngayChup;
  final int? banGiaoId;
  final int? baoTriId;

  ImageConfirmData({
    required this.hinhAnhId,
    required this.thietBiId,
    required this.nguoiDungChupId,
    required this.urlAnh,
    required this.loaiAnhId,
    required this.ngayChup,
    this.banGiaoId,
    this.baoTriId,
  });

  factory ImageConfirmData.fromJson(Map<String, dynamic> json) =>
      _$ImageConfirmDataFromJson(json);
  Map<String, dynamic> toJson() => _$ImageConfirmDataToJson(this);
}
