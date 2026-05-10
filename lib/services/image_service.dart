import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/image_upload_response.dart';
import 'api_client.dart';

/// Enum loại container trên Azure Blob Storage
enum ImageCategory {
  user,      // Ảnh cá nhân (avatar)
  products,  // Ảnh sản phẩm / thiết bị
  work,      // Ảnh nghiệp vụ (giao nhận, bảo trì)
}

/// Service quản lý upload/tải/xóa ảnh thông qua Azure Blob Storage + SAS Token
///
/// Luồng upload 3 bước:
///   1. Lấy SAS URL từ server  →  [getUploadUrl]
///   2. Upload file lên Azure   →  [uploadToAzure]
///   3. Xác nhận với server     →  [confirmAvatar] / [confirmProductImage] / [confirmWorkImage]
///
/// Tiện ích:
///   - [uploadAvatar]        — 3-in-1 helper cho avatar
///   - [uploadProductImage]  — 3-in-1 helper cho ảnh sản phẩm
///   - [uploadWorkImage]     — 3-in-1 helper cho ảnh nghiệp vụ
///   - [deleteImage]         — Xóa ảnh (Azure + DB)
class ImageService {
  final Dio _dio = ApiClient.dioClient;

  // ══════════════════════════════════════════════════════
  //  BƯỚC 1: LẤY SAS URL
  // ══════════════════════════════════════════════════════

  /// Lấy SAS URL upload có thời hạn 5 phút từ server.
  /// [category]: Loại container (user, products, work)
  /// [extension]: Định dạng file (mặc định: jpg)
  Future<ApiResponse<SasUploadData>> getUploadUrl({
    required ImageCategory category,
    String extension = 'png',
  }) async {
    try {
      final categoryStr = category.name; // "user" | "products" | "work"
      final response = await _dio.get(
        '${ApiConfig.imagesEndpoint}/$categoryStr/get-upload-url',
        queryParameters: {'extension': extension},
      );

      return ApiResponse<SasUploadData>.fromJson(
        response.data,
        (json) => SasUploadData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════
  //  BƯỚC 2: UPLOAD TRỰC TIẾP LÊN AZURE (không qua server)
  // ══════════════════════════════════════════════════════

  /// Upload file binary lên Azure Blob Storage qua SAS URL.
  /// Sử dụng Dio instance riêng (không gắn JWT interceptor).
  /// [sasUrl]: URL đầy đủ nhận từ getUploadUrl
  /// [fileBytes]: Dữ liệu file dạng bytes
  /// [contentType]: MIME type (mặc định: image/jpeg)
  /// [onProgress]: Callback theo dõi tiến trình (0.0 → 1.0)
  Future<void> uploadToAzure({
    required String sasUrl,
    required Uint8List fileBytes,
    String contentType = 'image/jpeg',
    void Function(double progress)? onProgress,
  }) async {
    // Dio instance riêng — không có JWT interceptor, không có baseUrl
    final azureDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));

    try {
      await azureDio.put(
        sasUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'x-ms-blob-type': 'BlockBlob',
            'Content-Type': contentType,
            'Content-Length': fileBytes.length,
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('SAS Token hết hạn. Vui lòng thử lại.');
      }
      throw Exception('Lỗi upload lên Azure: ${e.message}');
    }
  }

  /// Upload file từ đường dẫn File (tiện khi dùng image_picker).
  Future<void> uploadFileToAzure({
    required String sasUrl,
    required File file,
    String? contentType,
    void Function(double progress)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    final mime = contentType ?? _getMimeType(file.path);
    await uploadToAzure(
      sasUrl: sasUrl,
      fileBytes: bytes,
      contentType: mime,
      onProgress: onProgress,
    );
  }

  // ══════════════════════════════════════════════════════
  //  BƯỚC 3: XÁC NHẬN UPLOAD VỚI SERVER
  // ══════════════════════════════════════════════════════

  /// 3a. Xác nhận upload ảnh đại diện (container: user)
  /// POST /api/images/user/update-avatar
  Future<ApiResponse<AvatarUpdateData>> confirmAvatar({
    required String fileName,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.imagesEndpoint}/user/update-avatar',
        data: {'fileName': fileName},
      );

      return ApiResponse<AvatarUpdateData>.fromJson(
        response.data,
        (json) => AvatarUpdateData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// 3b. Xác nhận upload ảnh sản phẩm (container: products)
  /// POST /api/images/products/thiet-bi/{thietBiId}/update-image
  Future<ApiResponse<ImageConfirmData>> confirmProductImage({
    required int thietBiId,
    required String fileName,
    int loaiAnhId = 1, // Mặc định: Ảnh sản phẩm
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.imagesEndpoint}/products/thiet-bi/$thietBiId/update-image',
        data: {
          'fileName': fileName,
          'loaiAnhId': loaiAnhId,
        },
      );

      return ApiResponse<ImageConfirmData>.fromJson(
        response.data,
        (json) => ImageConfirmData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// 3c. Xác nhận upload ảnh nghiệp vụ (container: work)
  /// POST /api/images/work/thiet-bi/{thietBiId}/update-image
  /// Phải có ít nhất 1 trong 2: banGiaoId hoặc baoTriId
  Future<ApiResponse<ImageConfirmData>> confirmWorkImage({
    required int thietBiId,
    required String fileName,
    int loaiAnhId = 2, // Mặc định: Biên bản
    int? banGiaoId,
    int? baoTriId,
  }) async {
    assert(
      banGiaoId != null || baoTriId != null,
      'Phải cung cấp banGiaoId hoặc baoTriId',
    );

    try {
      final response = await _dio.post(
        '${ApiConfig.imagesEndpoint}/work/thiet-bi/$thietBiId/update-image',
        data: {
          'fileName': fileName,
          'loaiAnhId': loaiAnhId,
          if (banGiaoId != null) 'banGiaoId': banGiaoId,
          if (baoTriId != null) 'baoTriId': baoTriId,
        },
      );

      return ApiResponse<ImageConfirmData>.fromJson(
        response.data,
        (json) => ImageConfirmData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════
  //  XÓA ẢNH
  // ══════════════════════════════════════════════════════

  /// Xóa ảnh khỏi Azure Blob Storage + Database.
  /// Server tự phát hiện container từ URL.
  /// DELETE /api/images/{hinhAnhId}
  Future<ApiResponse<void>> deleteImage(int hinhAnhId) async {
    try {
      final response = await _dio.delete(
        '${ApiConfig.imagesEndpoint}/$hinhAnhId',
      );

      return ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════
  //  HELPER 3-IN-1: LẤY URL → UPLOAD → XÁC NHẬN
  // ══════════════════════════════════════════════════════

  /// Upload avatar: Lấy SAS → Upload file → Xác nhận cập nhật avatar
  /// Trả về URL ảnh đại diện mới.
  Future<String> uploadAvatar({
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final ext = _getExtension(file.path);

    // Bước 1: Lấy SAS URL
    final sasResponse = await getUploadUrl(
      category: ImageCategory.user,
      extension: ext,
    );
    final sasData = sasResponse.data!;

    // Bước 2: Upload lên Azure
    await uploadFileToAzure(
      sasUrl: sasData.sasUrl,
      file: file,
      onProgress: onProgress,
    );

    // Bước 3: Xác nhận với server
    final confirmResponse = await confirmAvatar(fileName: sasData.fileName);
    return confirmResponse.data!.avatarUrl;
  }

  /// Upload ảnh sản phẩm: Lấy SAS → Upload file → Xác nhận lưu DB
  /// Trả về [ImageConfirmData] chứa thông tin ảnh đã lưu.
  Future<ImageConfirmData> uploadProductImage({
    required File file,
    required int thietBiId,
    int loaiAnhId = 1,
    void Function(double progress)? onProgress,
  }) async {
    final ext = _getExtension(file.path);

    final sasResponse = await getUploadUrl(
      category: ImageCategory.products,
      extension: ext,
    );
    final sasData = sasResponse.data!;

    await uploadFileToAzure(
      sasUrl: sasData.sasUrl,
      file: file,
      onProgress: onProgress,
    );

    final confirmResponse = await confirmProductImage(
      thietBiId: thietBiId,
      fileName: sasData.fileName,
      loaiAnhId: loaiAnhId,
    );
    return confirmResponse.data!;
  }

  /// Upload ảnh nghiệp vụ: Lấy SAS → Upload file → Xác nhận lưu DB
  /// Trả về [ImageConfirmData] chứa thông tin ảnh đã lưu.
  Future<ImageConfirmData> uploadWorkImage({
    required File file,
    required int thietBiId,
    int loaiAnhId = 2,
    int? banGiaoId,
    int? baoTriId,
    void Function(double progress)? onProgress,
  }) async {
    final ext = _getExtension(file.path);

    final sasResponse = await getUploadUrl(
      category: ImageCategory.work,
      extension: ext,
    );
    final sasData = sasResponse.data!;

    await uploadFileToAzure(
      sasUrl: sasData.sasUrl,
      file: file,
      onProgress: onProgress,
    );

    final confirmResponse = await confirmWorkImage(
      thietBiId: thietBiId,
      fileName: sasData.fileName,
      loaiAnhId: loaiAnhId,
      banGiaoId: banGiaoId,
      baoTriId: baoTriId,
    );
    return confirmResponse.data!;
  }

  // ══════════════════════════════════════════════════════
  //  UTILITIES
  // ══════════════════════════════════════════════════════

  /// Lấy extension từ đường dẫn file
  String _getExtension(String path) {
    final parts = path.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
  }

  /// Xác định MIME type từ extension
  String _getMimeType(String path) {
    final ext = _getExtension(path);
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
