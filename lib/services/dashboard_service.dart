import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/dashboard_data.dart';
import 'api_client.dart';

/// Service gọi API Dashboard
/// GET /api/dashboard — lấy dữ liệu tổng hợp cho trang chủ Admin
class DashboardService {
  final Dio _dio = ApiClient.dioClient;

  /// Lấy dữ liệu dashboard
  /// Requires JWT token (tự động gắn bởi ApiClient interceptor)
  Future<ApiResponse<DashboardData>> getDashboard() async {
    try {
      final response = await _dio.get(ApiConfig.dashboardEndpoint);

      final apiResponse = ApiResponse<DashboardData>.fromJson(
        response.data,
        (json) => DashboardData.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }
}
