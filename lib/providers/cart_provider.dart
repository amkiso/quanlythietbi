import 'package:flutter/material.dart';
import '../models/gio_hang_item.dart';
import '../models/loai_thiet_bi.dart';
import '../services/gio_hang_service.dart';

/// Provider quản lý giỏ hàng — kết nối API /api/gio-hang
/// Tự động đồng bộ với server qua GioHangService
class CartProvider extends ChangeNotifier {
  final GioHangService _service = GioHangService();

  List<GioHangItem> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  /// Danh sách items trong giỏ
  List<GioHangItem> get items => List.unmodifiable(_items);

  /// Trạng thái loading
  bool get isLoading => _isLoading;

  /// Thông báo lỗi (nếu có)
  String? get error => _error;

  /// Đã load lần đầu chưa
  bool get isInitialized => _isInitialized;

  /// Tổng số loại thiết bị trong giỏ
  int get itemCount => _items.length;

  /// Tổng số lượng thiết bị (SUM soLuong)
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.soLuong);

  /// Tổng tiền tạm tính
  double get tongTienTamTinh =>
      _items.fold(0.0, (sum, item) => sum + item.thanhTien);

  /// ═══════════════════════════════════════════════════
  ///  LOAD giỏ hàng từ API
  /// ═══════════════════════════════════════════════════
  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.getCart();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════
  ///  THÊM sản phẩm vào giỏ hàng (gọi API)
  /// ═══════════════════════════════════════════════════
  /// Nếu đã có → server tự cộng dồn số lượng
  Future<void> addItem(LoaiThietBi loaiThietBi) async {
    try {
      await _service.addItem(
        loaiThietBiId: loaiThietBi.loaiThietBiId!,
        soLuong: 1,
      );
      // Reload lại giỏ hàng từ server để đồng bộ
      await loadCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════
  ///  TĂNG số lượng (gioHangId)
  /// ═══════════════════════════════════════════════════
  Future<void> increaseQuantity(int gioHangId) async {
    final index = _items.indexWhere((item) => item.gioHangId == gioHangId);
    if (index < 0) return;

    final newQty = _items[index].soLuong + 1;

    // Optimistic update
    _items[index].soLuong = newQty;
    notifyListeners();

    try {
      await _service.updateQuantity(
        gioHangId: gioHangId,
        soLuong: newQty,
      );
      // Reload để đồng bộ thanhTien từ server
      await loadCart();
    } catch (e) {
      // Rollback
      _items[index].soLuong = newQty - 1;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════
  ///  GIẢM số lượng (tối thiểu 1)
  /// ═══════════════════════════════════════════════════
  Future<void> decreaseQuantity(int gioHangId) async {
    final index = _items.indexWhere((item) => item.gioHangId == gioHangId);
    if (index < 0 || _items[index].soLuong <= 1) return;

    final newQty = _items[index].soLuong - 1;

    // Optimistic update
    _items[index].soLuong = newQty;
    notifyListeners();

    try {
      await _service.updateQuantity(
        gioHangId: gioHangId,
        soLuong: newQty,
      );
      await loadCart();
    } catch (e) {
      // Rollback
      _items[index].soLuong = newQty + 1;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════
  ///  XÓA item khỏi giỏ (gioHangId)
  /// ═══════════════════════════════════════════════════
  Future<void> removeItem(int gioHangId) async {
    final removedIndex = _items.indexWhere((item) => item.gioHangId == gioHangId);
    if (removedIndex < 0) return;

    final removedItem = _items[removedIndex];

    // Optimistic update
    _items.removeAt(removedIndex);
    notifyListeners();

    try {
      await _service.removeItem(gioHangId);
    } catch (e) {
      // Rollback
      _items.insert(removedIndex, removedItem);
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ═══════════════════════════════════════════════════
  ///  XÓA toàn bộ giỏ hàng (local clear + cờ)
  /// ═══════════════════════════════════════════════════
  void clearCart() {
    _items.clear();
    _isInitialized = false;
    notifyListeners();
  }

  /// Kiểm tra sản phẩm đã có trong giỏ chưa
  bool isInCart(int loaiThietBiId) {
    return _items.any((item) => item.loaiThietBiId == loaiThietBiId);
  }

  /// Lấy số lượng badge (count) từ API
  Future<int> getCartBadgeCount() async {
    try {
      return await _service.getCartCount();
    } catch (e) {
      return totalQuantity;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
