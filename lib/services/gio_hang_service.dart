import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/gio_hang_item.dart';
import 'api_client.dart';

/// Service gọi API giỏ hàng — /api/gio-hang
/// Chỉ dành cho Khách hàng (VaiTroID = 4)
class GioHangService {
  final Dio _dio = ApiClient.dioClient;

  /// 13.1 — Lấy danh sách giỏ hàng
  Future<List<GioHangItem>> getCart() async {
    try {
      final response = await _dio.get(ApiConfig.gioHangEndpoint);
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final list = data['data'] as List;
        return list.map((e) => GioHangItem.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 13.2 — Thêm item vào giỏ hàng
  /// Nếu loaiThietBiId đã tồn tại → server tự cộng dồn
  Future<GioHangItem> addItem({
    required int loaiThietBiId,
    int soLuong = 1,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.gioHangEndpoint,
        data: {
          'loaiThietBiId': loaiThietBiId,
          'soLuong': soLuong,
        },
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return GioHangItem.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Thêm vào giỏ hàng thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 13.3 — Cập nhật số lượng
  Future<GioHangItem> updateQuantity({
    required int gioHangId,
    required int soLuong,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.gioHangEndpoint}/$gioHangId',
        data: {'soLuong': soLuong},
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return GioHangItem.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Cập nhật số lượng thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 13.4 — Xóa item khỏi giỏ hàng
  Future<void> removeItem(int gioHangId) async {
    try {
      await _dio.delete('${ApiConfig.gioHangEndpoint}/$gioHangId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 13.5 — Đếm tổng items (badge)
  Future<int> getCartCount() async {
    try {
      final response = await _dio.get('${ApiConfig.gioHangEndpoint}/count');
      final data = response.data;
      if (data['success'] == true) {
        return (data['data'] ?? 0) as int;
      }
      return 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Xử lý lỗi API
  String _handleError(DioException e) {
    return ApiClient.getErrorMessage(e);
  }
}
