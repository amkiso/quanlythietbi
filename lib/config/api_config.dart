/// Cấu hình API Server
class ApiConfig {
  // ===== Base URL =====
  // Android Emulator: 10.0.2.2 là alias cho localhost của máy host
  // Thiết bị thật: thay bằng IP thực của máy chạy server
  static const String baseUrl = 'https://lg42grrn.asse.devtunnels.ms:8080/api';

  // ===== Timeout =====
  static const int connectTimeout = 5000; // 5 giây
  static const int receiveTimeout = 5000; // 5 giây

  // ===== Endpoints =====
  static const String loginEndpoint = '/auth/login';
  static const String doiMatKhauEndpoint = '/auth/doi-mat-khau';
  static const String thietBiEndpoint = '/thiet-bi';
  static const String dashboardEndpoint = '/dashboard';
}
