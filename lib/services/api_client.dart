import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/token_storage.dart';

/// Dio HTTP Client singleton với JWT Interceptor
/// Tự động gắn Authorization header cho mọi request (trừ login)
class ApiClient {
  static ApiClient? _instance;
  late final Dio dio;

  ApiClient._() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // JWT Interceptor - tự động thêm token vào header
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Bỏ qua token cho endpoint login
        if (!options.path.contains('/auth/login')) {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Xử lý lỗi 401 (Unauthorized) - token hết hạn
        if (error.response?.statusCode == 401) {
          // Token hết hạn, xóa token cũ
          TokenStorage.clearAll();
        }
        handler.next(error);
      },
    ));

    // Log interceptor (chỉ trong debug mode)
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
  }

  /// Singleton instance
  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  /// Lấy Dio instance
  static Dio get dioClient => instance.dio;

  /// Parse error message từ ApiResponse error
  static String getErrorMessage(DioException error) {
    if (error.response?.data != null && error.response?.data is Map) {
      final data = error.response?.data as Map<String, dynamic>;
      return data['message'] ?? 'Đã xảy ra lỗi';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối tới server quá lâu. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Server phản hồi quá lâu. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối tới server. Kiểm tra kết nối mạng.';
      default:
        return error.message ?? 'Đã xảy ra lỗi không xác định';
    }
  }
}
