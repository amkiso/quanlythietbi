import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/checkout_models.dart';
import 'api_client.dart';

/// ═══════════════════════════════════════════════════════
///  CHECKOUT SERVICE — Tích hợp API cho luồng Thanh toán
///  Bao gồm: Địa chỉ, Hợp đồng, Ký kết, Điều khoản mẫu
/// ═══════════════════════════════════════════════════════
class CheckoutService {
  final Dio _dio = ApiClient.dioClient;

  /// Expose Dio cho các thành phần khác tái sử dụng (notifications, etc.)
  Dio get dio => _dio;

  // ─────────────────────────────────────────────────────
  //  15. ĐỊA CHỈ GIAO HÀNG
  // ─────────────────────────────────────────────────────

  /// 15.1 — Lấy danh sách địa chỉ
  Future<List<DeliveryAddress>> getAddresses() async {
    try {
      final response = await _dio.get(ApiConfig.diaChiEndpoint);
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final list = data['data'] as List;
        return list.map((e) => DeliveryAddress.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 15.2 — Tạo địa chỉ mới
  Future<DeliveryAddress> createAddress(DeliveryAddress address) async {
    try {
      final response = await _dio.post(
        ApiConfig.diaChiEndpoint,
        data: address.toJson(),
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return DeliveryAddress.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Tạo địa chỉ thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 15.3 — Cập nhật địa chỉ
  Future<DeliveryAddress> updateAddress(int id, DeliveryAddress address) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.diaChiEndpoint}/$id',
        data: address.toJson(),
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return DeliveryAddress.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Cập nhật địa chỉ thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 15.4 — Xóa địa chỉ
  Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('${ApiConfig.diaChiEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────
  //  16. HỢP ĐỒNG THUÊ — CHECKOUT & E-CONTRACT
  // ─────────────────────────────────────────────────────

  /// 16.1 — Tạo hợp đồng (Checkout)
  /// Trả về response chứa hopDongId, maHopDong, chiTietThietBi, chiPhi
  Future<Map<String, dynamic>> createContract({
    required int diaChiGiaoId,
    required int phuongThucThanhToan,
    required DateTime ngayBatDauThue,
    required int soThangThue,
    String? ghiChuKhachHang,
    required List<Map<String, dynamic>> danhSachThietBi,
  }) async {
    try {
      final body = {
        'diaChiGiaoId': diaChiGiaoId,
        'phuongThucThanhToan': phuongThucThanhToan,
        'ngayBatDauThue': _formatDate(ngayBatDauThue),
        'soThangThue': soThangThue,
        'danhSachThietBi': danhSachThietBi,
      };

      if (ghiChuKhachHang != null && ghiChuKhachHang.isNotEmpty) {
        body['ghiChuKhachHang'] = ghiChuKhachHang;
      }

      final response = await _dio.post(
        '${ApiConfig.hopDongEndpoint}/tao',
        data: body,
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception(data['message'] ?? 'Tạo hợp đồng thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 16.2 — Ký hợp đồng điện tử (multipart/form-data)
  Future<Map<String, dynamic>> signContract({
    required int hopDongId,
    required Uint8List signatureImage,
    required String maPin,
  }) async {
    try {
      final formData = FormData.fromMap({
        'chuKy': MultipartFile.fromBytes(
          signatureImage,
          filename: 'signature.png',
        ),
        'maPin': maPin,
      });

      final response = await _dio.post(
        '${ApiConfig.hopDongEndpoint}/$hopDongId/ky-ket',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception(data['message'] ?? 'Ký hợp đồng thất bại');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────
  //  17. ĐIỀU KHOẢN MẪU HỢP ĐỒNG
  // ─────────────────────────────────────────────────────

  /// 17.1 — Lấy tất cả điều khoản mẫu
  Future<List<Map<String, dynamic>>> getContractTerms() async {
    try {
      final response = await _dio.get(ApiConfig.dieuKhoanMauEndpoint);
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────
  //  19. DANH SÁCH & CHI TIẾT HỢP ĐỒNG KHÁCH HÀNG
  // ─────────────────────────────────────────────────────

  /// 19.1 — Lấy danh sách tất cả hợp đồng của khách hàng
  Future<List<Map<String, dynamic>>> getMyContracts() async {
    try {
      final response = await _dio.get('${ApiConfig.hopDongEndpoint}/cua-toi');
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 19.2 — Lấy N hợp đồng gần nhất (cho label trang chủ)
  Future<List<Map<String, dynamic>>> getRecentContracts({int limit = 5}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.hopDongEndpoint}/gan-nhat',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 19.3 — Xem chi tiết hợp đồng (xem lại hợp đồng đã tạo)
  Future<Map<String, dynamic>> getContractDetail(int hopDongId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.hopDongEndpoint}/$hopDongId/chi-tiet',
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception('Không thể lấy chi tiết hợp đồng');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 19.4 — Đếm số đơn hàng theo trạng thái (cho badge hồ sơ)
  Future<Map<String, dynamic>> getDonHangCount() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.hopDongEndpoint}/don-hang-count',
      );
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────
  //  HELPER
  // ─────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _handleError(DioException e) {
    return ApiClient.getErrorMessage(e);
  }
}

