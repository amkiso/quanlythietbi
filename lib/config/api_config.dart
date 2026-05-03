import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cấu hình API Server
class ApiConfig {
  // ===== Base URL =====
  // Sử dụng biến môi trường từ file .env để bảo mật thông tin
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080/api';

  // ===== Timeout =====
  static const int connectTimeout = 5000; // 5 giây
  static const int receiveTimeout = 5000; // 5 giây

  // ===== Endpoints =====
  static const String loginEndpoint = '/auth/login';
  static const String doiMatKhauEndpoint = '/auth/doi-mat-khau';
  static const String thietBiEndpoint = '/thiet-bi';
  static const String dashboardEndpoint = '/dashboard';
}
