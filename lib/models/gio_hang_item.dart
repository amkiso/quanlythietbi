/// Model cho item trong giỏ hàng
/// Map từ API response GET /api/gio-hang
class GioHangItem {
  final int gioHangId;
  final int loaiThietBiId;
  final String tenLoaiThietBi;
  final String? anhDaiDien;
  final double giaThueThamKhao;
  int soLuong;
  final double thanhTien;
  final String? ngayThem;

  GioHangItem({
    required this.gioHangId,
    required this.loaiThietBiId,
    required this.tenLoaiThietBi,
    this.anhDaiDien,
    required this.giaThueThamKhao,
    this.soLuong = 1,
    required this.thanhTien,
    this.ngayThem,
  });

  /// Factory từ JSON response của API
  factory GioHangItem.fromJson(Map<String, dynamic> json) {
    return GioHangItem(
      gioHangId: json['gioHangId'] ?? 0,
      loaiThietBiId: json['loaiThietBiId'] ?? 0,
      tenLoaiThietBi: json['tenLoaiThietBi'] ?? '',
      anhDaiDien: json['anhDaiDien'],
      giaThueThamKhao: (json['giaThueThamKhao'] ?? 0).toDouble(),
      soLuong: json['soLuong'] ?? 1,
      thanhTien: (json['thanhTien'] ?? 0).toDouble(),
      ngayThem: json['ngayThem'],
    );
  }

  Map<String, dynamic> toJson() => {
        'gioHangId': gioHangId,
        'loaiThietBiId': loaiThietBiId,
        'tenLoaiThietBi': tenLoaiThietBi,
        'anhDaiDien': anhDaiDien,
        'giaThueThamKhao': giaThueThamKhao,
        'soLuong': soLuong,
        'thanhTien': thanhTien,
        'ngayThem': ngayThem,
      };
}
