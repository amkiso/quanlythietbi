import 'dart:io';
import 'package:flutter/material.dart';
import '../models/image_upload_response.dart';
import '../services/image_service.dart';

/// Provider quản lý trạng thái upload/xóa ảnh
/// Cung cấp progress tracking, error handling, và caching avatar URL.
class ImageProvider extends ChangeNotifier {
  final ImageService _service = ImageService();

  // ── State ──
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _avatarUrl;

  // ── Getters ──
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  String? get avatarUrl => _avatarUrl;

  /// Đặt avatar URL ban đầu (từ AuthProvider khi đăng nhập)
  void setInitialAvatar(String? url) {
    _avatarUrl = url;
    // Không notify — gọi trước build
  }

  // ══════════════════════════════════════════════════════
  //  UPLOAD AVATAR
  // ══════════════════════════════════════════════════════

  /// Upload ảnh đại diện mới.
  /// Trả về URL ảnh mới nếu thành công, null nếu thất bại.
  Future<String?> uploadAvatar(File file) async {
    _setUploading(true);
    try {
      final url = await _service.uploadAvatar(
        file: file,
        onProgress: _onProgress,
      );
      _avatarUrl = url;
      _setUploading(false);
      return url;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setUploading(false);
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  //  UPLOAD ẢNH SẢN PHẨM
  // ══════════════════════════════════════════════════════

  /// Upload ảnh cho thiết bị/sản phẩm.
  /// Trả về [ImageConfirmData] nếu thành công, null nếu thất bại.
  Future<ImageConfirmData?> uploadProductImage({
    required File file,
    required int thietBiId,
    int loaiAnhId = 1,
  }) async {
    _setUploading(true);
    try {
      final result = await _service.uploadProductImage(
        file: file,
        thietBiId: thietBiId,
        loaiAnhId: loaiAnhId,
        onProgress: _onProgress,
      );
      _setUploading(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setUploading(false);
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  //  UPLOAD ẢNH NGHIỆP VỤ
  // ══════════════════════════════════════════════════════

  /// Upload ảnh nghiệp vụ (giao nhận, bảo trì).
  /// Phải có ít nhất 1 trong 2: banGiaoId hoặc baoTriId.
  /// Trả về [ImageConfirmData] nếu thành công, null nếu thất bại.
  Future<ImageConfirmData?> uploadWorkImage({
    required File file,
    required int thietBiId,
    int loaiAnhId = 2,
    int? banGiaoId,
    int? baoTriId,
  }) async {
    _setUploading(true);
    try {
      final result = await _service.uploadWorkImage(
        file: file,
        thietBiId: thietBiId,
        loaiAnhId: loaiAnhId,
        banGiaoId: banGiaoId,
        baoTriId: baoTriId,
        onProgress: _onProgress,
      );
      _setUploading(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setUploading(false);
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  //  XÓA ẢNH
  // ══════════════════════════════════════════════════════

  /// Xóa ảnh khỏi Azure + Database.
  /// Trả về true nếu thành công.
  Future<bool> deleteImage(int hinhAnhId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.deleteImage(hinhAnhId);
      if (response.success) {
        notifyListeners();
        return true;
      }
      _errorMessage = response.message ?? 'Xóa ảnh thất bại';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════
  //  INTERNAL HELPERS
  // ══════════════════════════════════════════════════════

  void _onProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _setUploading(bool value) {
    _isUploading = value;
    if (value) {
      _uploadProgress = 0.0;
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Xóa lỗi hiện tại
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
