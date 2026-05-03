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
}
