import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

/// Provider quản lý trạng thái Dashboard Admin
/// Có kiểm tra kết nối internet và timeout API 5s
class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool _isLoading = false;
  bool _hasConnection = true;
  String? _errorMessage;
  DashboardData? _data;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasConnection => _hasConnection;
  String? get errorMessage => _errorMessage;
  DashboardData? get data => _data;

  // Convenience getters
  double get doanhThuThangNay => _data?.doanhThuThangNay ?? 0;
  double get doanhThuThangTruoc => _data?.doanhThuThangTruoc ?? 0;
  double get tiLeTangTruong => _data?.tiLeTangTruong ?? 0;
  int get soThietBiDangBaoTri => _data?.soThietBiDangBaoTri ?? 0;
  int get soHopDongDenHan => _data?.soHopDongDenHan ?? 0;
  List<NhacNhoItem> get nhacNhoHomNay => _data?.nhacNhoHomNay ?? [];

  /// Kiểm tra kết nối internet
  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  /// Tải dữ liệu dashboard từ API (timeout 5s)
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Kiểm tra kết nối internet trước
    _hasConnection = await _checkInternet();
    if (!_hasConnection) {
      _errorMessage = 'Không có kết nối internet';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Đặt timeout 5s cho API call
      final response = await _service.getDashboard()
          .timeout(const Duration(seconds: 5));

      if (response.success && response.data != null) {
        _data = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Không thể tải dữ liệu dashboard';
      }
    } on TimeoutException catch (_) {
      _errorMessage = 'Server phản hồi quá lâu. Vui lòng thử lại.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh dữ liệu (pull-to-refresh)
  Future<void> refresh() async {
    await loadDashboard();
  }

  /// Xóa lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
