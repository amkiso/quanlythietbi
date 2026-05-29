import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/thiet_bi.dart';
import 'api_client.dart';

/// Service xử lý CRUD Thiết Bị
class ThietBiService {
  final Dio _dio = ApiClient.dioClient;

  /// Lấy danh sách tất cả thiết bị
  /// GET /api/thiet-bi
  Future<ApiResponse<List<ThietBi>>> getAll() async {
    try {
      final response = await _dio.get(ApiConfig.thietBiEndpoint);

      final apiResponse = ApiResponse<List<ThietBi>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((item) => ThietBi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Tạo thiết bị mới
  /// POST /api/thiet-bi
  Future<ApiResponse<ThietBi>> create(ThietBi thietBi) async {
    try {
      final response = await _dio.post(
        ApiConfig.thietBiEndpoint,
        data: thietBi.toJson(),
      );

      final apiResponse = ApiResponse<ThietBi>.fromJson(
        response.data,
        (json) => ThietBi.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Xóa thiết bị theo ID
  /// DELETE /api/thiet-bi/{id}
  Future<ApiResponse<void>> delete(int id) async {
    try {
      final response = await _dio.delete('${ApiConfig.thietBiEndpoint}/$id');

      return ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ═══════════════════════════════════════════════════════
  //  QR SCAN — Tra cứu thiết bị
  // ═══════════════════════════════════════════════════════

  /// Tra cứu thiết bị theo mã tài sản (từ QR code)
  /// GET /api/thiet-bi/tra-cuu/{maTaiSan}
  Future<Map<String, dynamic>> traCuu(String maTaiSan) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.thietBiEndpoint}/tra-cuu/$maTaiSan',
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception(data['message'] ?? 'Không tìm thấy thiết bị');
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy danh sách hợp đồng của thiết bị
  /// GET /api/thiet-bi/{id}/hop-dong
  Future<List<Map<String, dynamic>>> getDeviceContracts(int thietBiId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.thietBiEndpoint}/$thietBiId/hop-dong',
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Lấy lịch sử bảo trì của thiết bị
  /// GET /api/thiet-bi/{id}/lich-su-bao-tri
  Future<List<Map<String, dynamic>>> getMaintenanceHistory(int thietBiId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.thietBiEndpoint}/$thietBiId/lich-su-bao-tri',
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Cập nhật tình trạng thiết bị (bảo trì / hoàn thành bảo trì)
  /// PUT /api/thiet-bi/{id}/cap-nhat-tinh-trang
  Future<Map<String, dynamic>> updateStatus(int thietBiId, int tinhTrangId) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.thietBiEndpoint}/$thietBiId/cap-nhat-tinh-trang',
        data: {'tinhTrangId': tinhTrangId},
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception(data['message'] ?? 'Cập nhật thất bại');
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }
}

