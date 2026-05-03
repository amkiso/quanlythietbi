import 'package:flutter/material.dart';
import '../models/thiet_bi.dart';
import '../services/thiet_bi_service.dart';

/// Provider quản lý trạng thái danh sách Thiết Bị
class ThietBiProvider extends ChangeNotifier {
  final ThietBiService _thietBiService = ThietBiService();

  List<ThietBi> _danhSachThietBi = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ThietBi> get danhSachThietBi => _danhSachThietBi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải danh sách thiết bị
  Future<void> loadThietBi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _thietBiService.getAll();
      if (response.success && response.data != null) {
        _danhSachThietBi = response.data!;
      } else {
        _errorMessage = response.message ?? 'Không thể tải danh sách thiết bị';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Thêm thiết bị mới
  Future<bool> themThietBi(ThietBi thietBi) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _thietBiService.create(thietBi);
      if (response.success && response.data != null) {
        _danhSachThietBi.add(response.data!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Không thể tạo thiết bị';
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

  /// Xóa thiết bị
  Future<bool> xoaThietBi(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _thietBiService.delete(id);
      if (response.success) {
        _danhSachThietBi.removeWhere((tb) => tb.thietBiId == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Không thể xóa thiết bị';
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

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
