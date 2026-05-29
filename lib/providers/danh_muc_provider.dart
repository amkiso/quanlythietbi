import 'package:flutter/material.dart';
import '../models/danh_muc_thiet_bi.dart';
import '../models/loai_thiet_bi.dart';
import '../services/danh_muc_service.dart';

/// Provider quản lý state cho Danh mục Thiết bị
/// Hỗ trợ: phân tab theo danh mục, tìm kiếm, phân trang mobile-style
class DanhMucProvider extends ChangeNotifier {
  final DanhMucService _service = DanhMucService();

  // ── State: Danh mục ──
  List<DanhMucThietBi> _danhSachDanhMuc = [];
  int? _selectedDanhMucId; // null = Tất cả

  // ── State: Loại thiết bị ──
  List<LoaiThietBi> _danhSachLoaiThietBi = [];
  List<LoaiThietBi> _filteredList = [];

  // ── State: Tìm kiếm ──
  String _searchQuery = '';

  // ── State: Loading ──
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;

  // ── State: Detail ──
  LoaiThietBi? _selectedLoaiThietBi;
  List<Map<String, dynamic>> _thietBiChiTiet = [];

  // ═══════════════════════════════════════
  //  GETTERS
  // ═══════════════════════════════════════

  List<DanhMucThietBi> get danhSachDanhMuc => _danhSachDanhMuc;
  int? get selectedDanhMucId => _selectedDanhMucId;
  List<LoaiThietBi> get filteredLoaiThietBi => _filteredList;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  LoaiThietBi? get selectedLoaiThietBi => _selectedLoaiThietBi;
  List<Map<String, dynamic>> get thietBiChiTiet => _thietBiChiTiet;

  /// Số lượng loại thiết bị đang hiển thị
  int get totalItems => _filteredList.length;

  // ═══════════════════════════════════════
  //  LOAD DATA
  // ═══════════════════════════════════════

  /// Tải toàn bộ danh mục + loại thiết bị
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Preload cache nhà cung cấp trước khi load data
      await _service.preloadCaches();
      _danhSachDanhMuc = await _service.getAllDanhMuc();
      _danhSachLoaiThietBi = await _service.getLoaiThietBiByDanhMuc(null);
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAll();
  }

  // ═══════════════════════════════════════
  //  FILTER — Tab danh mục + Tìm kiếm
  // ═══════════════════════════════════════

  /// Chọn danh mục (null = Tất cả)
  void selectDanhMuc(int? danhMucId) {
    _selectedDanhMucId = danhMucId;
    _applyFilter();
    notifyListeners();
  }

  /// Cập nhật search query
  void updateSearch(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Áp dụng filter (danh mục + tìm kiếm)
  void _applyFilter() {
    var result = _danhSachLoaiThietBi.toList();

    // Filter theo danh mục
    if (_selectedDanhMucId != null) {
      result = result.where((l) => l.danhMucId == _selectedDanhMucId).toList();
    }

    // Filter theo search
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      result = result
          .where((l) => l.tenLoaiThietBi.toLowerCase().contains(lower))
          .toList();
    }

    _filteredList = result;
  }

  // ═══════════════════════════════════════
  //  DETAIL — Xem chi tiết loại thiết bị
  // ═══════════════════════════════════════

  /// Tải chi tiết loại thiết bị + danh sách serial
  Future<void> loadDetail(int loaiThietBiId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedLoaiThietBi = await _service.getLoaiThietBiDetail(loaiThietBiId);
      _thietBiChiTiet = await _service.getThietBiByLoai(loaiThietBiId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// Clear detail
  void clearDetail() {
    _selectedLoaiThietBi = null;
    _thietBiChiTiet = [];
    notifyListeners();
  }

  // ═══════════════════════════════════════
  //  CRUD — Sửa / Xóa
  // ═══════════════════════════════════════

  /// Cập nhật loại thiết bị
  Future<bool> updateLoaiThietBi(LoaiThietBi loaiThietBi) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.updateLoaiThietBi(loaiThietBi);
      if (success) {
        // Reload data
        _danhSachLoaiThietBi = await _service.getLoaiThietBiByDanhMuc(null);
        _applyFilter();
        _selectedLoaiThietBi = loaiThietBi;
      } else {
        _errorMessage = 'Không thể cập nhật thiết bị';
      }
      _isLoadingDetail = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoadingDetail = false;
      notifyListeners();
      return false;
    }
  }

  /// Xóa loại thiết bị
  Future<bool> deleteLoaiThietBi(int loaiThietBiId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _service.deleteLoaiThietBi(loaiThietBiId);
      if (success) {
        _danhSachLoaiThietBi = await _service.getLoaiThietBiByDanhMuc(null);
        _applyFilter();
        _selectedLoaiThietBi = null;
        _thietBiChiTiet = [];
      } else {
        _errorMessage = 'Không thể xóa thiết bị';
      }
      _isLoadingDetail = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoadingDetail = false;
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════

  /// Lấy tên nhà cung cấp
  String getTenNhaCungCap(int id) => _service.getTenNhaCungCap(id);

  /// Lấy tên danh mục
  String getTenDanhMuc(int id) => _service.getTenDanhMuc(id);

  /// Lấy tên trạng thái
  String getTenTinhTrang(int id) => _service.getTenTinhTrang(id);

  /// Lấy hoặc tạo QR Code cho thiết bị
  Future<String?> generateQrCode(int thietBiId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final qrUrl = await _service.generateQrCode(thietBiId);
      if (qrUrl != null) {
        // Cập nhật lại list thietBiChiTiet cục bộ để hiển thị ảnh QR
        final index = _thietBiChiTiet.indexWhere((tb) => tb['thietBiId'] == thietBiId);
        if (index != -1) {
          _thietBiChiTiet[index]['qrCodeUrl'] = qrUrl;
        }
      }
      _isLoadingDetail = false;
      notifyListeners();
      return qrUrl;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoadingDetail = false;
      notifyListeners();
      return null;
    }
  }

  /// Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
