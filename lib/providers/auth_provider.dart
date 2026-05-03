import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/doi_mat_khau_request.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

/// Provider quản lý trạng thái xác thực (Authentication)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;
  String? get token => _loginResponse?.token;
  String? get hoTen => _loginResponse?.hoTen;
  String? get tenVaiTro => _loginResponse?.tenVaiTro;
  int? get nguoiDungId => _loginResponse?.nguoiDungId;
  int? get vaiTroId => _loginResponse?.vaiTroId;
  int? get khoId => _loginResponse?.khoId;
  bool get doiMatKhauLanDau => _loginResponse?.doiMatKhauLanDau ?? false;

  /// Kiểm tra trạng thái đăng nhập khi mở app
  Future<void> checkLoginStatus() async {
    final isLoggedIn = await TokenStorage.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await TokenStorage.getSavedUserInfo();
      _isLoggedIn = true;
      _loginResponse = LoginResponse(
        token: userInfo['token'] ?? '',
        nguoiDungId: userInfo['nguoiDungId'] ?? 0,
        hoTen: userInfo['hoTen'] ?? '',
        maNguoiDung: userInfo['maNguoiDung'] ?? '',
        vaiTroId: userInfo['vaiTroId'] ?? 0,
        tenVaiTro: userInfo['tenVaiTro'] ?? '',
        khoId: userInfo['khoId'],
        doiMatKhauLanDau: userInfo['doiMatKhauLanDau'] ?? false,
      );
      notifyListeners();
    }
  }

  /// Đăng nhập
  Future<bool> login(String taiKhoan, String matKhau) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(taiKhoan: taiKhoan, matKhau: matKhau);
      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        _loginResponse = response.data!;
        _isLoggedIn = true;

        // Lưu token và thông tin vào SharedPreferences
        await TokenStorage.saveLoginInfo(
          token: _loginResponse!.token,
          nguoiDungId: _loginResponse!.nguoiDungId,
          hoTen: _loginResponse!.hoTen,
          maNguoiDung: _loginResponse!.maNguoiDung,
          vaiTroId: _loginResponse!.vaiTroId,
          tenVaiTro: _loginResponse!.tenVaiTro,
          khoId: _loginResponse!.khoId,
          doiMatKhauLanDau: _loginResponse!.doiMatKhauLanDau,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đổi mật khẩu
  Future<bool> doiMatKhau(String matKhauCu, String matKhauMoi) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = DoiMatKhauRequest(
        matKhauCu: matKhauCu,
        matKhauMoi: matKhauMoi,
      );
      final response = await _authService.doiMatKhau(request);

      _isLoading = false;
      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Đổi mật khẩu thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await TokenStorage.clearAll();
    _isLoggedIn = false;
    _loginResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
