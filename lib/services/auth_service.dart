import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/doi_mat_khau_request.dart';
import 'api_client.dart';

/// Service xử lý Authentication (đăng nhập, đổi mật khẩu)
class AuthService {
  final Dio _dio = ApiClient.dioClient;

  /// Đăng nhập
  /// POST /api/auth/login
  /// Trả về LoginResponse chứa JWT token và thông tin nhân viên
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );

      return apiResponse;
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Đổi mật khẩu
  /// POST /api/auth/doi-mat-khau
  /// Yêu cầu JWT token (đã đăng nhập)
  Future<ApiResponse<void>> doiMatKhau(DoiMatKhauRequest request) async {
    try {
      final response = await _dio.post(
        ApiConfig.doiMatKhauEndpoint,
        data: request.toJson(),
      );

      return ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }
}
