import 'package:shared_preferences/shared_preferences.dart';

/// Helper class để lưu và đọc JWT token từ SharedPreferences
class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _nguoiDungIdKey = 'nguoi_dung_id';
  static const String _hoTenKey = 'ho_ten';
  static const String _maNguoiDungKey = 'ma_nguoi_dung';
  static const String _vaiTroIdKey = 'vai_tro_id';
  static const String _tenVaiTroKey = 'ten_vai_tro';
  static const String _khoIdKey = 'kho_id';
  static const String _doiMatKhauLanDauKey = 'doi_mat_khau_lan_dau';

  // ── Remember Me keys ──
  static const String _rememberMeKey = 'remember_me';
  static const String _savedTaiKhoanKey = 'saved_tai_khoan';
  static const String _savedMatKhauKey = 'saved_mat_khau';

  /// Lưu thông tin đăng nhập
  static Future<void> saveLoginInfo({
    required String token,
    required int nguoiDungId,
    required String hoTen,
    required String maNguoiDung,
    required int vaiTroId,
    required String tenVaiTro,
    int? khoId,
    bool doiMatKhauLanDau = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_nguoiDungIdKey, nguoiDungId);
    await prefs.setString(_hoTenKey, hoTen);
    await prefs.setString(_maNguoiDungKey, maNguoiDung);
    await prefs.setInt(_vaiTroIdKey, vaiTroId);
    await prefs.setString(_tenVaiTroKey, tenVaiTro);
    await prefs.setBool(_doiMatKhauLanDauKey, doiMatKhauLanDau);
    if (khoId != null) {
      await prefs.setInt(_khoIdKey, khoId);
    }
  }

  /// Đọc JWT token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Đọc thông tin người dùng đã lưu
  static Future<Map<String, dynamic>> getSavedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'nguoiDungId': prefs.getInt(_nguoiDungIdKey),
      'hoTen': prefs.getString(_hoTenKey),
      'maNguoiDung': prefs.getString(_maNguoiDungKey),
      'vaiTroId': prefs.getInt(_vaiTroIdKey),
      'tenVaiTro': prefs.getString(_tenVaiTroKey),
      'khoId': prefs.getInt(_khoIdKey),
      'doiMatKhauLanDau': prefs.getBool(_doiMatKhauLanDauKey) ?? false,
    };
  }

  /// Kiểm tra đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ══════════════════════════════════════════════════
  //  REMEMBER ME — Lưu / đọc thông tin đăng nhập
  // ══════════════════════════════════════════════════

  /// Lưu trạng thái checkbox "Nhớ đăng nhập"
  static Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  /// Đọc trạng thái checkbox "Nhớ đăng nhập"
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Lưu tài khoản & mật khẩu (khi chọn "Nhớ đăng nhập")
  static Future<void> saveCredentials({
    required String taiKhoan,
    required String matKhau,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedTaiKhoanKey, taiKhoan);
    await prefs.setString(_savedMatKhauKey, matKhau);
  }

  /// Đọc tài khoản & mật khẩu đã lưu
  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'taiKhoan': prefs.getString(_savedTaiKhoanKey),
      'matKhau': prefs.getString(_savedMatKhauKey),
    };
  }

  /// Xóa tài khoản & mật khẩu đã lưu
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedTaiKhoanKey);
    await prefs.remove(_savedMatKhauKey);
    await prefs.remove(_rememberMeKey);
  }

  /// Xóa tất cả thông tin (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nguoiDungIdKey);
    await prefs.remove(_hoTenKey);
    await prefs.remove(_maNguoiDungKey);
    await prefs.remove(_vaiTroIdKey);
    await prefs.remove(_tenVaiTroKey);
    await prefs.remove(_khoIdKey);
    await prefs.remove(_doiMatKhauLanDauKey);
    // Cũng xóa credentials khi đăng xuất
    await prefs.remove(_savedTaiKhoanKey);
    await prefs.remove(_savedMatKhauKey);
    await prefs.remove(_rememberMeKey);
  }
}
