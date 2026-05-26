import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/doi_mat_khau_request.dart';
import 'api_client.dart';

/// Service xử lý Authentication (đăng nhập, đổi mật khẩu, đăng ký, quên MK, profile)
class AuthService {
  final Dio _dio = ApiClient.dioClient;

  /// Đăng nhập
  /// POST /api/auth/login
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

  // ─────────────────────────────────────────────────────
  //  ĐĂNG KÝ KHÁCH HÀNG (2 bước OTP)
  // ─────────────────────────────────────────────────────

  /// Bước 1: Khởi tạo đăng ký — gửi OTP vào email
  /// POST /api/auth/register-init
  Future<String> registerInit({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
    String? diaChi,
    int loaiKhachHangId = 1,
  }) async {
    try {
      final body = {
        'hoTen': hoTen,
        'email': email,
        'matKhau': matKhau,
        'soDienThoai': soDienThoai,
        'loaiKhachHangId': loaiKhachHangId,
      };
      if (diaChi != null && diaChi.isNotEmpty) {
        body['diaChi'] = diaChi;
      }

      final response = await _dio.post(
        ApiConfig.registerInitEndpoint,
        data: body,
      );

      // Response có thể là String hoặc Map
      if (response.data is String) return response.data;
      if (response.data is Map) {
        return response.data['message'] ?? 'Vui lòng kiểm tra email để lấy mã OTP';
      }
      return 'Vui lòng kiểm tra email để lấy mã OTP';
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Bước 2: Xác nhận OTP → tạo tài khoản + nhận token
  /// POST /api/auth/register-confirm
  Future<ApiResponse<LoginResponse>> registerConfirm({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerConfirmEndpoint,
        data: {'email': email, 'otp': otp},
      );

      return ApiResponse<LoginResponse>.fromJson(
        response.data,
        (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ─────────────────────────────────────────────────────
  //  QUÊN MẬT KHẨU (2 bước OTP)
  // ─────────────────────────────────────────────────────

  /// Bước 1: Gửi email yêu cầu quên mật khẩu → nhận OTP
  /// POST /api/auth/forgot-password-init
  Future<String> forgotPasswordInit(String email) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPasswordInitEndpoint,
        data: {'email': email},
      );

      if (response.data is String) return response.data;
      if (response.data is Map) {
        return response.data['message'] ?? 'Vui lòng kiểm tra email để lấy mã OTP';
      }
      return 'Vui lòng kiểm tra email để lấy mã OTP';
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  /// Bước 2: Xác nhận OTP + đặt mật khẩu mới
  /// POST /api/auth/forgot-password-confirm
  Future<String> forgotPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPasswordConfirmEndpoint,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      if (response.data is String) return response.data;
      if (response.data is Map) {
        return response.data['message'] ?? 'Đổi mật khẩu thành công';
      }
      return 'Đổi mật khẩu thành công';
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ─────────────────────────────────────────────────────
  //  THÔNG TIN CÁ NHÂN
  // ─────────────────────────────────────────────────────

  /// Lấy thông tin cá nhân
  /// GET /api/auth/me
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profileEndpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // API trả về { success: true, data: { ... } } hoặc trực tiếp object
        if (data.containsKey('data') && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data']);
        }
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }

  // ─────────────────────────────────────────────────────
  //  KIỂM TRA EMAIL QUÊN MẬT KHẨU
  // ─────────────────────────────────────────────────────

  /// Kiểm tra email trước khi quên mật khẩu
  /// POST /api/auth/check-email-reset
  /// Trả về { isCustomer, vaiTroId, adminPhone?, adminName? }
  Future<Map<String, dynamic>> checkEmailForReset(String email) async {
    try {
      final response = await _dio.post(
        ApiConfig.checkEmailResetEndpoint,
        data: {'email': email},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map) {
          return Map<String, dynamic>.from(data['data']);
        }
        return data;
      }
      return {};
    } on DioException catch (e) {
      throw Exception(ApiClient.getErrorMessage(e));
    }
  }
}
