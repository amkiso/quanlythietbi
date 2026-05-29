import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/danh_muc_thiet_bi.dart';
import '../models/loai_thiet_bi.dart';
import '../models/nha_cung_cap.dart';
import 'api_client.dart';

/// Service quản lý Danh mục Thiết bị
/// Gọi REST API từ Spring Boot backend
class DanhMucService {
  final Dio _dio = ApiClient.dioClient;

  /// ═══════════════════════════════════════
  ///  CACHE — Nhà cung cấp & Danh mục
  /// ═══════════════════════════════════════

  /// Cache nhà cung cấp: {id: tên}
  Map<int, String> _nhaCungCapCache = {};
  bool _nhaCungCapLoaded = false;

  /// Cache danh mục: {id: tên}
  Map<int, String> _danhMucCache = {};
  bool _danhMucLoaded = false;

  /// Trạng thái thiết bị (hardcode — lookup table cố định)
  static final Map<int, String> _tinhTrangMap = {
    1: 'Sẵn sàng',
    2: 'Đang cho thuê',
    3: 'Đang bảo trì',
    4: 'Hỏng',
  };

  // ═══════════════════════════════════════
  //  PRIVATE: Load cache
  // ═══════════════════════════════════════

  /// Load cache nhà cung cấp từ API (gọi 1 lần)
  Future<void> _ensureNhaCungCapLoaded() async {
    if (_nhaCungCapLoaded) return;
    try {
      final response = await _dio.get(ApiConfig.nhaCungCapEndpoint);
      final apiResponse = ApiResponse<List<NhaCungCap>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) => NhaCungCap.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      if (apiResponse.success && apiResponse.data != null) {
        _nhaCungCapCache = {
          for (var ncc in apiResponse.data!)
            if (ncc.nhaCungCapId != null) ncc.nhaCungCapId!: ncc.tenNhaCungCap,
        };
        _nhaCungCapLoaded = true;
      }
    } catch (_) {
      // Giữ cache rỗng nếu lỗi — getTenNhaCungCap sẽ trả 'Không rõ'
    }
  }

  /// Load cache danh mục từ kết quả getAllDanhMuc
  void _updateDanhMucCache(List<DanhMucThietBi> danhMucs) {
    _danhMucCache = {
      for (var dm in danhMucs)
        if (dm.danhMucId != null) dm.danhMucId!: dm.tenDanhMuc,
    };
    _danhMucLoaded = true;
  }

  // ═══════════════════════════════════════
  //  PUBLIC METHODS
  // ═══════════════════════════════════════

  /// Lấy danh sách tất cả danh mục
  Future<List<DanhMucThietBi>> getAllDanhMuc() async {
    try {
      final response = await _dio.get(ApiConfig.danhMucEndpoint);
      final apiResponse = ApiResponse<List<DanhMucThietBi>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) =>
                DanhMucThietBi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Cập nhật cache
        _updateDanhMucCache(apiResponse.data!);
        return apiResponse.data!;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy danh sách loại thiết bị theo danh mục
  /// danhMucId == null → lấy tất cả
  Future<List<LoaiThietBi>> getLoaiThietBiByDanhMuc(int? danhMucId) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (danhMucId != null) {
        queryParams['danhMucId'] = danhMucId;
      }
      final response = await _dio.get(
        ApiConfig.loaiThietBiEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final apiResponse = ApiResponse<List<LoaiThietBi>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) =>
                LoaiThietBi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy chi tiết 1 loại thiết bị
  Future<LoaiThietBi?> getLoaiThietBiDetail(int loaiThietBiId) async {
    try {
      final response =
          await _dio.get('${ApiConfig.loaiThietBiEndpoint}/$loaiThietBiId');
      final apiResponse = ApiResponse<LoaiThietBi>.fromJson(
        response.data,
        (json) => LoaiThietBi.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy tên nhà cung cấp theo ID (sync — từ cache)
  String getTenNhaCungCap(int id) {
    return _nhaCungCapCache[id] ?? 'Không rõ';
  }

  /// Lấy tên danh mục theo ID (sync — từ cache)
  String getTenDanhMuc(int id) {
    return _danhMucCache[id] ?? 'Không rõ';
  }

  /// Lấy tên trạng thái (hardcode local)
  String getTenTinhTrang(int id) {
    return _tinhTrangMap[id] ?? 'Không rõ';
  }

  /// Lấy danh sách thiết bị cụ thể (serial) theo loại thiết bị
  /// Backend trả về ThietBiByLoaiDTO, map sang format cũ cho Flutter
  Future<List<Map<String, dynamic>>> getThietBiByLoai(
      int loaiThietBiId) async {
    try {
      final response = await _dio.get(
        ApiConfig.thietBiEndpoint,
        queryParameters: {'loaiThietBiId': loaiThietBiId},
      );
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!.map((item) {
          final map = item as Map<String, dynamic>;
          return {
            'thietBiId': map['thietBiId'] ?? 0,
            'maTaiSan': map['maTaiSan'] ?? '',
            'tinhTrangId': map['tinhTrangId'] ?? 0,
            'khoHienTai': map['tenKho'] ?? 'Không rõ',
            'qrCodeUrl': map['qrCodeUrl'],
          };
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Cập nhật loại thiết bị
  Future<bool> updateLoaiThietBi(LoaiThietBi loaiThietBi) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.loaiThietBiEndpoint}/${loaiThietBi.loaiThietBiId}',
        data: loaiThietBi.toJson(),
      );
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      return apiResponse.success;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Xóa loại thiết bị
  Future<bool> deleteLoaiThietBi(int loaiThietBiId) async {
    try {
      final response = await _dio.delete(
        '${ApiConfig.loaiThietBiEndpoint}/$loaiThietBiId',
      );
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      return apiResponse.success;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Tìm kiếm loại thiết bị theo tên
  Future<List<LoaiThietBi>> searchLoaiThietBi(String query) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.loaiThietBiEndpoint}/search',
        queryParameters: {'q': query},
      );
      final apiResponse = ApiResponse<List<LoaiThietBi>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) =>
                LoaiThietBi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy hoặc tạo QR Code cho thiết bị
  Future<String?> generateQrCode(int thietBiId) async {
    try {
      final response = await _dio.get('${ApiConfig.thietBiEndpoint}/$thietBiId/qr-code');
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!['qrCodeUrl'] as String?;
      }
      return null;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Preload caches khi service khởi tạo (gọi trong loadAll của provider)
  Future<void> preloadCaches() async {
    await _ensureNhaCungCapLoaded();
  }
}
