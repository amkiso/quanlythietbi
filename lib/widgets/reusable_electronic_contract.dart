import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/checkout_models.dart';

/// ═══════════════════════════════════════════════════════
///  REUSABLE ELECTRONIC CONTRACT — Widget hợp đồng điện tử
///  6 Điều khoản đầy đủ theo thiết kế:
///  1. Thông tin thiết bị thuê
///  2. Chi phí, thời gian thuê và thanh toán
///  3. Giao nhận, vệ sinh và bảo trì
///  4. Chính sách bồi thường thiệt hại
///  5. Trách nhiệm y khoa và miễn trừ
///  6. Điều khoản chung
/// ═══════════════════════════════════════════════════════
class ReusableElectronicContract extends StatelessWidget {
  final ElectronicContractData data;
  final ScrollController? scrollController;

  const ReusableElectronicContract({
    super.key,
    required this.data,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final dateFmt = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(dateFmt),
          const SizedBox(height: 24),
          _buildArticle1(fmt, dateFmt),
          const SizedBox(height: 20),
          _buildArticle2(fmt),
          const SizedBox(height: 20),
          _buildArticle3(fmt),
          const SizedBox(height: 20),
          _buildArticle4(fmt),
          const SizedBox(height: 20),
          _buildArticle5(),
          const SizedBox(height: 20),
          _buildArticle6(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════════════════════════
  Widget _buildHeader(DateFormat dateFmt) {
    return Column(
      children: [
        Center(
          child: Text('CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center),
        ),
        Center(
          child: Text('Độc lập - Tự do - Hạnh phúc',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
                  decoration: TextDecoration.underline),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text('HỢP ĐỒNG CHO THUÊ THIẾT BỊ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('Số: ${data.maHopDong}',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('Ngày lập: ${dateFmt.format(data.ngayLap)}',
              style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        ),
        const SizedBox(height: 16),
        Text('Hợp đồng này được lập và ký kết giữa các bên dưới đây:', style: _bodyStyle),
        const SizedBox(height: 16),

        // Bên A
        Text('BÊN A: BÊN CHO THUÊ (ĐƠN VỊ CUNG CẤP NỀN TẢNG)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 8),
        _bulletPointRich('Tên Công ty: ', data.tenCongTy),
        _bulletPointRich('Đại diện: ', '${data.nguoiDaiDien} – Chức vụ: ${data.chucVuNguoiDaiDien}'),
        _bulletPointRich('Địa chỉ: ', data.diaChiCongTy),
        _bulletPointRich('Mã số thuế: ', data.maSoThueCongTy),
        const SizedBox(height: 16),

        // Bên B
        Text('BÊN B: BÊN THUÊ (KHÁCH HÀNG)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 8),
        _bulletPointRich('Tên khách hàng: ', data.khachHang.hoTen),
        _bulletPointRich('Đơn vị công tác: ', data.khachHang.donViCongTac),
        _bulletPointRich('Địa chỉ: ', data.khachHang.diaChi),
        _bulletPointRich('Số điện thoại / Email: ', '${data.khachHang.soDienThoai} / ${data.khachHang.email}'),
        _bulletPointRich('CCCD/CMND số: ', '${data.khachHang.cccd} cấp ngày ${dateFmt.format(data.khachHang.cccdNgayCap)} tại ${data.khachHang.cccdNoiCap}'),
        const SizedBox(height: 16),
        Text('Sau khi thỏa thuận, hai bên đồng ý ký kết hợp đồng thuê thiết bị với các điều khoản như sau:',
            style: _bodyStyle),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 1: THÔNG TIN THIẾT BỊ THUÊ
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle1(NumberFormat fmt, DateFormat dateFmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 1: THÔNG TIN THIẾT BỊ THUÊ'),
        const SizedBox(height: 8),
        _paragraph('Bên A đồng ý cho Bên B thuê thiết bị với thông tin chi tiết:'),
        const SizedBox(height: 10),
        ...data.danhSachThietBi.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final device = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$index. ${device.tenThietBi}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 8),
                _bulletPointRich('Số Serial (S/N): ', device.soSerial),
                _bulletPointRich('Tình trạng lúc bàn giao: ', device.tinhTrangBanGiao),
                _bulletPointRich('Mục đích sử dụng: ', device.mucDichSuDung),
                _bulletPointRich('Giá trị máy (để làm cơ sở bồi thường): ', '${fmt.format(device.giaTriMay)} VNĐ'),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 2: CHI PHÍ, THỜI GIAN THUÊ VÀ THANH TOÁN
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle2(NumberFormat fmt) {
    final device = data.danhSachThietBi.isNotEmpty ? data.danhSachThietBi.first : null;
    final giaThueThang = device?.giaThueThang ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 2: CHI PHÍ, THỜI GIAN THUÊ VÀ THANH TOÁN'),
        const SizedBox(height: 10),

        // 1. Thời hạn thuê
        _numberedItemMultiline(1, 'Thời hạn thuê:',
            '${data.soThangThue} tháng kể từ ngày nhận bàn giao thiết bị.'),
        const SizedBox(height: 6),

        // 2. Chi phí thuê
        _numberedItem(2, 'Chi phí thuê:', ''),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('* Đơn giá thuê: ${fmt.format(giaThueThang)} VNĐ/tháng',
                  style: _bodyStyle),
              _bulletPoint('Tổng tiền thuê dự kiến (nếu thuê ${data.soThangThue} tháng): '
                  '${fmt.format(data.tongChiPhiThue)} VNĐ'),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. Tiền đặt cọc
        _numberedItemMultiline(3, 'Tiền đặt cọc:',
            '${fmt.format(data.tienDatCoc)} VNĐ. Tiền cọc sẽ được hoàn trả cho Bên B '
            'sau khi kết thúc hợp đồng, trừ đi các chi phí phát sinh (nếu có) '
            'quy định tại Điều 4 và Điều 5.'),
        const SizedBox(height: 6),

        // 4. Phí trễ hạn
        _numberedItemMultiline(4, 'Phí trễ hạn:',
            'Nếu Bên B chậm thanh toán tiền thuê định kỳ, phí phạt sẽ được tính là '
            'cộng thêm ${data.phiTreHanPhanTram.toInt()}% trên tổng số tiền thuê đang nợ cho mỗi '
            '${data.soNgayTreHanMoiKy} ngày quá hạn.'),
        const SizedBox(height: 6),

        // 5. Xử lý vi phạm thanh toán
        _numberedItemMultiline(5, 'Xử lý vi phạm thanh toán:',
            'Quá ${data.soNgayViPhamChamDut} ngày kể từ ngày đến hạn thanh toán mà Bên B '
            'chưa thanh toán đủ gốc và phí trễ hạn, Bên A có quyền đơn phương chấm dứt hợp đồng, '
            'thu hồi thiết bị ngay lập tức và không hoàn lại tiền cọc.'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 3: GIAO NHẬN, VỆ SINH VÀ BẢO TRÌ
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle3(NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 3: GIAO NHẬN, VỆ SINH VÀ BẢO TRÌ'),
        const SizedBox(height: 10),

        // 1. Giao nhận
        _numberedItemMultiline(1, 'Giao nhận:',
            'Bên A giao máy đến địa chỉ Bên B. Bên B có trách nhiệm kiểm tra, '
            'test máy và ký vào Biên bản bàn giao (hoặc xác nhận điện tử trên App).'),
        const SizedBox(height: 6),

        // 2. Vệ sinh - Tiệt trùng
        _numberedItemMultiline(2, 'Vệ sinh - Tiệt trùng:',
            'Khi trả máy, Bên B phải thực hiện vệ sinh và tiệt trùng bề mặt cơ bản '
            'thiết bị theo tiêu chuẩn.'),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: _bulletPoint(
              'Phụ thu tiệt trùng: Nếu thiết bị được trả về trong tình trạng dính máu, '
              'dịch tiết, hóa chất hoặc rác thải, Bên A sẽ trừ một khoản Phí vệ sinh '
              'chuyên sâu là ${fmt.format(data.phiVeSinhChuyenSau)} VNĐ vào tiền cọc của Bên B.'),
        ),
        const SizedBox(height: 6),

        // 3. Bảo trì định kỳ
        _numberedItemMultiline(3, 'Bảo trì định kỳ:',
            'Bên A chịu trách nhiệm bảo trì, hiệu chuẩn máy định kỳ (nếu thời gian thuê kéo dài). '
            'Bên B phải tạo điều kiện để kỹ thuật viên Bên A tiếp cận thiết bị.'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 4: CHÍNH SÁCH BỒI THƯỜNG THIỆT HẠI
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle4(NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 4: CHÍNH SÁCH BỒI THƯỜNG THIỆT HẠI'),
        const SizedBox(height: 8),
        _paragraph(
            'Trong trường hợp thiết bị bị hư hỏng, mất mát trong thời gian Bên B thuê máy, '
            'mức bồi thường được quy định rõ như sau:'),
        const SizedBox(height: 10),

        // 1. Hao mòn tự nhiên
        _numberedItemMultiline(1, 'Hư hỏng do hao mòn tự nhiên (Wear & Tear):',
            '(Mờ nút bấm, trầy xước nhẹ vỏ máy do lau chùi, mòn dây cắm theo thời gian...).'),
        _indentedBullet('Mức bồi thường: Bên B không phải bồi thường. '
            'Bên A chịu trách nhiệm bảo hành/sửa chữa.'),
        const SizedBox(height: 10),

        // 2. Hư hỏng do lỗi sử dụng
        _numberedItemMultiline(2, 'Hư hỏng do lỗi sử dụng sai cách hoặc tác động vật lý:',
            '(Rơi vỡ, đổ chất lỏng vào bo mạch, cắm sai điện áp, cắm sai công áp lực gây cháy van...).'),
        _indentedBullet('Mức bồi thường: Bên B thanh toán 100% chi phí sửa chữa theo báo giá '
            'thực tế của hãng/đơn vị sửa chữa ủy quyền.'),
        _indentedBullet('Phí gián đoạn kinh doanh: Trong thời gian máy chờ sửa chữa, '
            'Bên B phải thanh toán thêm ${data.phiGianDoanPhanTram.toInt()}% đơn giá thuê '
            'tính theo ngày cho những ngày máy nằm tại xưởng '
            '(Do Bên A không thể khai thác cho thuê).'),
        const SizedBox(height: 10),

        // 3. Hư hỏng nặng / Mất cắp
        _numberedItemMultiline(3, 'Hư hỏng nặng không thể khắc phục hoặc Mất cắp/Thất lạc:', ''),
        _indentedBullet('Mức bồi thường: Bên B có trách nhiệm bồi thường theo giá trị '
            'khấu hao hiện tại của thiết bị tại thời điểm xảy ra sự cố.'),
        _indentedBullet('Giá trị bồi thường = (Giá trị máy quy định tại Điều 1) - '
            '(Khấu hao hao mòn mỗi năm). '
            'Mức bồi thường tối đa không vượt quá 100% giá trị máy ban đầu.'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 5: TRÁCH NHIỆM VÀ MIỄN TRỪ
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 5: TRÁCH NHIỆM VÀ MIỄN TRỪ'),
        const SizedBox(height: 8),
        _paragraph('Đây là điều khoản bắt buộc để đảm bảo an toàn pháp lý cho Bên A:'),
        const SizedBox(height: 8),

        _bulletPoint('Bên A chỉ cung cấp phần cứng (thiết bị) đảm bảo tiêu chuẩn kỹ thuật tại thời điểm bàn giao.'),
        const SizedBox(height: 6),

        _bulletPoint('Bên B (người thuê/người sử dụng) chịu hoàn toàn trách nhiệm '
            'về chuyên môn sử dụng. Bên B phải đảm bảo người vận hành thiết bị là người có đủ '
            'chứng chỉ hành nghề và được đào tạo sử dụng các thiết bị trên.'),
        const SizedBox(height: 6),

        _bulletPointRich('Miễn trừ: ',
            'Bên A KHÔNG chịu bất kỳ trách nhiệm dân sự, hình sự hay bồi thường nào '
            'đối với các sự cố sức khỏe, biến chứng hoặc tử vong của người sử dụng phát sinh '
            'từ việc Bên B không tuân thủ nguyên tắc an toàn, cài đặt thông số máy sai, hoặc do phía của người sử dụng.'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ĐIỀU 6: ĐIỀU KHOẢN CHUNG
  // ═══════════════════════════════════════════════════════
  Widget _buildArticle6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ĐIỀU 6: ĐIỀU KHOẢN CHUNG'),
        const SizedBox(height: 10),

        _numberedItemMultiline(1, '',
            'Hợp đồng có hiệu lực kể từ thời điểm Bên B xác nhận trên Ứng dụng (App) '
            'và hoàn tất việc thanh toán tiền cọc, tiền thuê kỳ đầu tiên.'),
        const SizedBox(height: 6),

        _numberedItemMultiline(2, '',
            'Mọi tranh chấp phát sinh sẽ được hai bên thương lượng giải quyết. '
            'Nếu không thương lượng được, vụ việc sẽ được đưa ra Tòa án nhân dân có thẩm quyền '
            'tại nơi Bên A đặt trụ sở.'),
        const SizedBox(height: 6),

        _numberedItemMultiline(3, '',
            'Hợp đồng điện tử này có giá trị pháp lý tương đương bản giấy được ký kết bởi hai bên.'),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  HELPER WIDGETS
  // ═══════════════════════════════════════════════════════
  TextStyle get _bodyStyle => TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.5);

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary));

  Widget _paragraph(String text) => Text(text, style: _bodyStyle);

  /// "1. **label** value" format
  Widget _numberedItem(int number, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: _bodyStyle),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: '$label ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, height: 1.5)),
                TextSpan(text: value, style: _bodyStyle),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// "1. **label** \n value" format for longer text
  Widget _numberedItemMultiline(int number, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: _bodyStyle),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                if (label.isNotEmpty)
                  TextSpan(text: '$label ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary, height: 1.5)),
                TextSpan(text: value, style: _bodyStyle),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('• ', style: _bodyStyle),
      Expanded(child: Text(text, style: _bodyStyle)),
    ]),
  );

  Widget _bulletPointRich(String label, String value) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('• ', style: _bodyStyle),
      Expanded(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, height: 1.5)),
            TextSpan(text: value, style: _bodyStyle),
          ]),
        ),
      ),
    ]),
  );

  Widget _indentedBullet(String text) => Padding(
    padding: const EdgeInsets.only(left: 20, top: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('• ', style: _bodyStyle),
      Expanded(child: Text(text, style: _bodyStyle)),
    ]),
  );
}
