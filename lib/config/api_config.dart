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
  static const String registerInitEndpoint = '/auth/register-init';
  static const String registerConfirmEndpoint = '/auth/register-confirm';
  static const String forgotPasswordInitEndpoint = '/auth/forgot-password-init';
  static const String forgotPasswordConfirmEndpoint = '/auth/forgot-password-confirm';
  static const String profileEndpoint = '/auth/me';
  static const String checkEmailResetEndpoint = '/auth/check-email-reset';
  static const String thietBiEndpoint = '/thiet-bi';
  static const String dashboardEndpoint = '/dashboard';
  static const String imagesEndpoint = '/images';
  static const String danhMucEndpoint = '/danh-muc';
  static const String loaiThietBiEndpoint = '/loai-thiet-bi';
  static const String nhaCungCapEndpoint = '/nha-cung-cap';
  static const String thongBaoEndpoint = '/thong-bao';
  static const String gioHangEndpoint = '/gio-hang';
  static const String hopDongEndpoint = '/hop-dong';
  static const String diaChiEndpoint = '/dia-chi';
  static const String dieuKhoanMauEndpoint = '/dieu-khoan-mau';
}
