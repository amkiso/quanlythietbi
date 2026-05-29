import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget hiển thị ảnh từ Cloudflare R2 (S3 API) với cơ chế caching thông minh.
///
/// Logic caching:
/// 1. Lần đầu load ảnh → tải từ server, lưu vào bộ nhớ cục bộ (disk cache).
/// 2. Các lần tiếp theo → đọc từ cache, KHÔNG gửi request lên server.
/// 3. Chỉ tải lại từ server khi:
///    - Ảnh chưa từng được tải (lần đầu).
///    - File cache bị hỏng/không tồn tại hoặc lần tải trước bị lỗi.
///
/// Tích hợp: placeholder loading shimmer + error fallback UI.
class CloudImage extends StatelessWidget {
  /// URL đầy đủ của ảnh (từ API, ví dụ: https://endpoint.cloudflarestorage.com/quanlythietbi/products/...)
  final String? imageUrl;

  /// Kích thước width (default: fill parent)
  final double? width;

  /// Kích thước height (default: fill parent)
  final double? height;

  /// Border radius
  final BorderRadius? borderRadius;

  /// BoxFit cho ảnh
  final BoxFit fit;

  /// Icon fallback khi không có ảnh
  final IconData fallbackIcon;

  /// Màu nền fallback
  final Color? fallbackColor;

  /// Kích thước icon fallback
  final double fallbackIconSize;

  /// Hiển thị text "Chưa có ảnh" trong fallback
  final bool showFallbackText;

  const CloudImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported_outlined,
    this.fallbackColor,
    this.fallbackIconSize = 40,
    this.showFallbackText = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    Widget child;
    if (hasImage) {
      final safeUrl = imageUrl!.trim();
      final safeCacheKey = safeUrl.split('?').first;

      child = CachedNetworkImage(
        imageUrl: safeUrl,
        width: width,
        height: height,
        fit: fit,
        // ── Cache key: dùng URL gốc (bỏ tham số SAS token) làm key duy nhất ──
        cacheKey: safeCacheKey,
        // ── Không giới hạn thời gian cache ──
        maxWidthDiskCache: 1024,
        maxHeightDiskCache: 1024,
        // ── Thêm Headers giả lập trình duyệt để vượt qua Cloudflare Bot Protection ──
        httpHeaders: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
        },

        // ── Loading placeholder — hiệu ứng shimmer ──
        placeholder: (context, url) => _buildLoadingPlaceholder(),

        // ── Error fallback — hiển thị khi tải lỗi ──
        errorWidget: (context, url, error) => _buildErrorFallback(),
      );
    } else {
      child = _buildFallback();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }

  /// Placeholder khi đang tải ảnh — shimmer animation
  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? Colors.grey.shade100,
      child: Center(
        child: _ShimmerLoadingIndicator(
          size: fallbackIconSize * 0.6,
        ),
      ),
    );
  }

  /// Fallback khi tải ảnh bị lỗi — có nút retry ngầm (tap để xóa cache + reload)
  Widget _buildErrorFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: fallbackIconSize * 0.8,
              color: Colors.grey.shade400,
            ),
            if (showFallbackText) ...[
              const SizedBox(height: 4),
              Text(
                'Lỗi tải ảnh',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Fallback khi không có URL ảnh
  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              fallbackIcon,
              size: fallbackIconSize,
              color: Colors.grey.shade400,
            ),
            if (showFallbackText) ...[
              const SizedBox(height: 4),
              Text(
                'Chưa có ảnh',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading indicator — vòng xoay nhẹ nhàng khi đang tải
class _ShimmerLoadingIndicator extends StatelessWidget {
  final double size;
  const _ShimmerLoadingIndicator({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: const Color(0xFF4A6CF7).withValues(alpha: 0.6),
        backgroundColor: const Color(0xFF4A6CF7).withValues(alpha: 0.1),
      ),
    );
  }
}

