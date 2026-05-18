import '../models/checkout_models.dart';
import '../models/gio_hang_item.dart';

/// ═══════════════════════════════════════════════════════
///  CHECKOUT HELPER — Tính toán hóa đơn & Dữ liệu tĩnh
///  Phần tính toán vẫn giữ để hiển thị tạm trên UI
///  (Server sẽ tính chính xác khi tạo hợp đồng)
/// ═══════════════════════════════════════════════════════
class CheckoutMockData {
  CheckoutMockData._();

  // ── Danh sách phương thức thanh toán ──
  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      type: PaymentMethodType.momo,
      name: 'Momo',
      iconAsset: 'momo',
      isLinked: false,
    ),
    PaymentMethod(
      type: PaymentMethodType.zalopay,
      name: 'Zalo Pay',
      iconAsset: 'zalopay',
      isLinked: false,
    ),
    PaymentMethod(
      type: PaymentMethodType.cash,
      name: 'Tiền mặt',
      iconAsset: 'cash',
      isLinked: true,
    ),
  ];

  /// Tính toán hóa đơn dựa trên items và thời lượng thuê
  static OrderSummary calculateOrderSummary({
    required List<GioHangItem> items,
    required RentalDuration? duration,
  }) {
    // Tổng giá thuê / tháng
    final double giaThueThang =
        items.fold(0.0, (sum, item) => sum + item.thanhTien);

    if (duration == null) {
      return OrderSummary(
        tongTien: 0,
        tienCoc: giaThueThang, // Cọc = 1 tháng
        thangDau: giaThueThang,
        thueVAT: 0,
        thanhTien: 0,
      );
    }

    double tongTien;
    String tongTienLabel;

    if (duration.days != null) {
      tongTien = (giaThueThang / 30) * duration.days!;
      tongTienLabel = '${duration.days} ngày';
    } else {
      tongTien = giaThueThang * duration.months;
      if (duration.months >= 12) {
        tongTienLabel = '${duration.months ~/ 12} năm';
      } else {
        tongTienLabel = '${duration.months} tháng';
      }
    }

    final double tienCoc = tongTien * 0.5; // Cọc 50% tổng đơn đặt
    final double thangDau = giaThueThang;
    final double thueVAT = giaThueThang * 0.1;
    final double thanhTien = tienCoc; // Thanh toán tạm tính = cọc

    return OrderSummary(
      tongTien: tongTien,
      tienCoc: tienCoc,
      thangDau: thangDau,
      thueVAT: thueVAT,
      thanhTien: thanhTien,
      tongTienLabel: tongTienLabel,
    );
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
