// ═══════════════════════════════════════════════════════
//  CHECKOUT MODELS
//  Cấu trúc dữ liệu cho luồng Thanh toán & Hợp đồng điện tử
// ═══════════════════════════════════════════════════════

/// Loại địa chỉ giao hàng
enum AddressType { personal, office }

/// Địa chỉ nhận hàng
class DeliveryAddress {
  final int? diaChiId;
  final String tenNguoiNhan;
  final String soDienThoai;
  final String tinhThanhPho;
  final String phuongXa;
  final String diaChiChiTiet;
  final String? donVi;
  final AddressType loaiDiaChi;
  final bool laMacDinh;

  DeliveryAddress({
    this.diaChiId,
    required this.tenNguoiNhan,
    required this.soDienThoai,
    required this.tinhThanhPho,
    required this.phuongXa,
    required this.diaChiChiTiet,
    this.donVi,
    this.loaiDiaChi = AddressType.office,
    this.laMacDinh = false,
  });

  /// Chuỗi địa chỉ đầy đủ
  String get diaChiDayDu =>
      '$diaChiChiTiet, $phuongXa, $tinhThanhPho';

  /// SĐT format quốc tế
  String get soDienThoaiFormatted {
    if (soDienThoai.startsWith('0')) {
      return '(+84) ${soDienThoai.substring(1)}';
    }
    return soDienThoai;
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    final loai = json['loaiDiaChi'];
    return DeliveryAddress(
      diaChiId: json['diaChiId'],
      tenNguoiNhan: json['tenNguoiNhan'] ?? '',
      soDienThoai: json['soDienThoai'] ?? '',
      tinhThanhPho: json['tinhThanhPho'] ?? '',
      phuongXa: json['phuongXa'] ?? '',
      diaChiChiTiet: json['diaChiChiTiet'] ?? '',
      donVi: json['donVi'],
      loaiDiaChi: loai == 1 ? AddressType.personal : AddressType.office,
      laMacDinh: json['laMacDinh'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'tenNguoiNhan': tenNguoiNhan,
        'soDienThoai': soDienThoai,
        'tinhThanhPho': tinhThanhPho,
        'phuongXa': phuongXa,
        'diaChiChiTiet': diaChiChiTiet,
        'donVi': donVi,
        'loaiDiaChi': loaiDiaChi == AddressType.personal ? 1 : 2,
        'laMacDinh': laMacDinh,
      };
}

/// Thời lượng thuê
class RentalDuration {
  final String label; // "6 tháng", "1 năm", ...
  final int months; // Số tháng
  final int? days; // Tùy chỉnh số ngày

  const RentalDuration({
    required this.label,
    required this.months,
    this.days,
  });

  static const List<RentalDuration> options = [
    RentalDuration(label: '3 tháng', months: 3),
    RentalDuration(label: '6 tháng', months: 6),
    RentalDuration(label: '1 năm', months: 12),
    RentalDuration(label: '2 năm', months: 24),
  ];
}

/// Phương thức thanh toán
enum PaymentMethodType { momo, zalopay, cash }

class PaymentMethod {
  final PaymentMethodType type;
  final String name;
  final String iconAsset; // tên icon
  final bool isLinked; // Đã liên kết chưa

  const PaymentMethod({
    required this.type,
    required this.name,
    required this.iconAsset,
    this.isLinked = false,
  });
}

/// Tóm tắt hóa đơn thanh toán
class OrderSummary {
  final double tongTien; // Tổng tiền thuê cả kỳ
  final double tienCoc; // Tiền cọc (= 1 tháng)
  final double thangDau; // Tháng đầu
  final double thueVAT; // 10%
  final double thanhTien; // Tổng thanh toán tạm tính
  final String? tongTienLabel; // vd: "18.000.000 đ/ năm"

  OrderSummary({
    required this.tongTien,
    required this.tienCoc,
    required this.thangDau,
    required this.thueVAT,
    required this.thanhTien,
    this.tongTienLabel,
  });
}

/// ═══════════════════════════════════════════════════════
///  E-CONTRACT MODELS
///  Model cho Hợp đồng Điện tử — 6 Điều khoản
/// ═══════════════════════════════════════════════════════

/// Thông tin khách hàng trong hợp đồng
class ContractCustomerInfo {
  final String hoTen;
  final String diaChi;
  final String soDienThoai;
  final String email;
  final String cccd;
  final String donViCongTac;
  final DateTime cccdNgayCap;
  final String cccdNoiCap;

  ContractCustomerInfo({
    required this.hoTen,
    required this.diaChi,
    required this.soDienThoai,
    required this.email,
    required this.cccd,
    required this.donViCongTac,
    required this.cccdNgayCap,
    required this.cccdNoiCap,
  });
}

/// Thiết bị trong hợp đồng — Điều 1: Thông tin thiết bị thuê
class ContractDevice {
  final String tenThietBi;
  final String soSerial;          // S/N
  final String tinhTrangBanGiao;  // Tình trạng lúc bàn giao (chi tiết)
  final String mucDichSuDung;     // Mục đích sử dụng
  final double giaTriMay;         // Giá trị máy (cơ sở bồi thường)
  final double giaThueThang;      // Đơn giá thuê/tháng
  final DateTime? ngayKiemDinh;   // Ngày kiểm định/hiệu chuẩn

  ContractDevice({
    required this.tenThietBi,
    required this.soSerial,
    required this.tinhTrangBanGiao,
    this.mucDichSuDung = 'Phục vụ điều trị bệnh nhân tại cơ sở của Bên B.',
    required this.giaTriMay,
    required this.giaThueThang,
    this.ngayKiemDinh,
  });

  /// Parse từ API response (POST /api/hop-dong/tao → chiTietThietBi[])
  factory ContractDevice.fromJson(Map<String, dynamic> json) {
    DateTime? ngayKD;
    if (json['ngayKiemDinh'] != null) {
      ngayKD = DateTime.tryParse(json['ngayKiemDinh'].toString());
    }
    return ContractDevice(
      tenThietBi: json['tenThietBi'] ?? '',
      soSerial: json['soSerial'] ?? '',
      tinhTrangBanGiao: json['tinhTrangBanGiao'] ?? '',
      mucDichSuDung: json['mucDichSuDung'] ?? 'Phục vụ điều trị bệnh nhân tại cơ sở của Bên B.',
      giaTriMay: (json['giaTriMay'] ?? 0).toDouble(),
      giaThueThang: (json['giaThueThang'] ?? 0).toDouble(),
      ngayKiemDinh: ngayKD,
    );
  }
}

/// Dữ liệu hợp đồng điện tử — truyền vào ReusableElectronicContract
class ElectronicContractData {
  final int hopDongId;
  final String maHopDong;
  final DateTime ngayLap;
  final ContractCustomerInfo khachHang;
  final List<ContractDevice> danhSachThietBi;

  // Điều 2: Chi phí, thời gian thuê và thanh toán
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int soThangThue;
  final double tongChiPhiThue;
  final double tienDatCoc;
  final double phiTreHanPhanTram;    // 3% mỗi 3 ngày
  final int soNgayTreHanMoiKy;      // 3 ngày
  final int soNgayViPhamChamDut;     // 15 ngày → chấm dứt hợp đồng

  // Điều 3: Giao nhận, vệ sinh, bảo trì
  final double phiVeSinhChuyenSau;   // 1.000.000 VNĐ

  // Điều 4: Bồi thường
  final double khauHaoHaoMonNam;     // Khấu hao mỗi năm
  final double phiGianDoanPhanTram;  // 50% đơn giá thuê / ngày

  // Thông tin Bên A
  final String tenCongTy;
  final String diaChiCongTy;
  final String soDienThoaiCongTy;
  final String nguoiDaiDien;
  final String chucVuNguoiDaiDien;
  final String maSoThueCongTy;

  ElectronicContractData({
    required this.hopDongId,
    required this.maHopDong,
    required this.ngayLap,
    required this.khachHang,
    required this.danhSachThietBi,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.soThangThue,
    required this.tongChiPhiThue,
    required this.tienDatCoc,
    this.phiTreHanPhanTram = 3.0,
    this.soNgayTreHanMoiKy = 3,
    this.soNgayViPhamChamDut = 15,
    this.phiVeSinhChuyenSau = 1000000,
    this.khauHaoHaoMonNam = 0,
    this.phiGianDoanPhanTram = 50.0,
    this.tenCongTy = 'Công ty TNHH Công nghệ Y tế Xypher (Nền tảng Xypher)',
    this.diaChiCongTy = 'Tòa nhà Xypher, Tầng 15, Số 123 Nguyễn Văn Linh, Quận 7, TP.HCM',
    this.soDienThoaiCongTy = '028 3855 1234',
    this.nguoiDaiDien = 'Ông Nguyễn Tuấn Khải',
    this.chucVuNguoiDaiDien = 'Giám đốc',
    this.maSoThueCongTy = '0312345678',
  });

  /// Build từ API response (POST /api/hop-dong/tao) + context người dùng
  factory ElectronicContractData.fromApiResponse({
    required Map<String, dynamic> apiData,
    required DeliveryAddress address,
    required DateTime startDate,
    required DateTime endDate,
    required int soThangThue,
    required String userEmail,
    String? cccd,
    DateTime? cccdNgayCap,
    String? cccdNoiCap,
  }) {
    // Parse danh sách thiết bị
    final chiTietList = apiData['chiTietThietBi'] as List? ?? [];
    final devices = chiTietList.map((e) =>
        ContractDevice.fromJson(e as Map<String, dynamic>)).toList();

    // Parse chi phí
    final chiPhi = apiData['chiPhi'] as Map<String, dynamic>? ?? {};

    return ElectronicContractData(
      hopDongId: apiData['hopDongId'] ?? 0,
      maHopDong: apiData['maHopDong'] ?? '',
      ngayLap: DateTime.now(),
      khachHang: ContractCustomerInfo(
        hoTen: address.tenNguoiNhan,
        diaChi: address.diaChiDayDu,
        soDienThoai: address.soDienThoai,
        email: userEmail,
        cccd: cccd ?? '',
        donViCongTac: address.donVi ?? '',
        cccdNgayCap: cccdNgayCap ?? DateTime.now(),
        cccdNoiCap: cccdNoiCap ?? '',
      ),
      danhSachThietBi: devices,
      ngayBatDau: startDate,
      ngayKetThuc: endDate,
      soThangThue: soThangThue,
      tongChiPhiThue: (chiPhi['tongTienThue'] ?? 0).toDouble(),
      tienDatCoc: (chiPhi['tienCoc'] ?? 0).toDouble(),
      phiTreHanPhanTram: (chiPhi['phiTreHanPhanTram'] ?? 3.0).toDouble(),
      soNgayTreHanMoiKy: chiPhi['soNgayTreHanMoiKy'] ?? 3,
      soNgayViPhamChamDut: chiPhi['soNgayViPhamChamDut'] ?? 15,
      phiVeSinhChuyenSau: (chiPhi['phiVeSinhChuyenSau'] ?? 1000000).toDouble(),
      khauHaoHaoMonNam: (chiPhi['khauHaoHaoMonNam'] ?? 0).toDouble(),
      phiGianDoanPhanTram: (chiPhi['phiGianDoanPhanTram'] ?? 50.0).toDouble(),
    );
  }
}

