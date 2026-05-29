import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/loai_thiet_bi.dart';
import '../providers/cart_provider.dart';
import '../services/danh_muc_service.dart';
import '../widgets/cloud_image.dart';

/// ═══════════════════════════════════════════════════════
///  DEVICE DETAIL PAGE — Chi tiết thiết bị (Client)
/// ═══════════════════════════════════════════════════════
class ClientDeviceDetailPage extends StatefulWidget {
  final LoaiThietBi loaiThietBi;
  final String danhMucTen;

  const ClientDeviceDetailPage({
    super.key,
    required this.loaiThietBi,
    required this.danhMucTen,
  });

  @override
  State<ClientDeviceDetailPage> createState() => _ClientDeviceDetailPageState();
}

class _ClientDeviceDetailPageState extends State<ClientDeviceDetailPage> {
  final DanhMucService _danhMucService = DanhMucService();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final PageController _pageController = PageController();

  // Data
  List<LoaiThietBi> _relatedDevices = [];
  int _currentImageIndex = 0;

  // Stats (tính từ danh sách thiết bị)
  int _tongSL = 0;
  int _sanSang = 0;
  int _dangThue = 0;
  int _dangBaoTri = 0;

  @override
  void initState() {
    super.initState();
    _loadRelatedData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRelatedData() async {
    try {
      await _danhMucService.preloadCaches();

      // Load thiết bị theo loại (để tính thống kê)
      final thietBiList = await _danhMucService
          .getThietBiByLoai(widget.loaiThietBi.loaiThietBiId!);

      // Load thiết bị cùng danh mục (gợi ý liên quan)
      final related = await _danhMucService
          .getLoaiThietBiByDanhMuc(widget.loaiThietBi.danhMucId);

      if (mounted) {
        setState(() {
          _tongSL = thietBiList.length;
          _sanSang = thietBiList
              .where((tb) => tb['tinhTrangId'] == 1)
              .length;
          _dangThue = thietBiList
              .where((tb) => tb['tinhTrangId'] == 2)
              .length;
          _dangBaoTri = thietBiList
              .where((tb) => tb['tinhTrangId'] == 3)
              .length;

          _relatedDevices = related
              .where((ltb) =>
                  ltb.loaiThietBiId != widget.loaiThietBi.loaiThietBiId)
              .take(6)
              .toList();
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _addToCart() async {
    try {
      await context.read<CartProvider>().addItem(widget.loaiThietBi);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Đã thêm vào giỏ hàng',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Không thể thêm vào giỏ: $e',
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ltb = widget.loaiThietBi;
    final nhaCungCapTen =
        _danhMucService.getTenNhaCungCap(ltb.nhaCungCapId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Image Slider ──
              SliverToBoxAdapter(child: _buildImageSlider()),
              // ── Info Section ──
              SliverToBoxAdapter(
                child: _buildInfoSection(ltb, nhaCungCapTen),
              ),
              // ── Price Card ──
              SliverToBoxAdapter(child: _buildPriceCard(ltb)),
              // ── Technical Specs ──
              SliverToBoxAdapter(child: _buildTechnicalSpecs(ltb)),
              // ── Related Devices ──
              SliverToBoxAdapter(child: _buildRelatedSection()),
              // ── Bottom spacing for action bar ──
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          // ── Back button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _buildCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          // ── Share button ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: _buildCircleButton(
              icon: Icons.share_rounded,
              onTap: () {},
            ),
          ),
          // ── Bottom Action Bar ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  IMAGE SLIDER
  // ═══════════════════════════════════════════════════

  Widget _buildImageSlider() {
    // Sử dụng ảnh đại diện + mock thêm vài ảnh
    final images = [widget.loaiThietBi.anhDaiDien];

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CloudImage(
                imageUrl: images[index],
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
                fallbackIcon: Icons.devices_rounded,
                fallbackIconSize: 64,
              );
            },
          ),
          // Page indicator
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          // Nav arrows
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildCircleButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  if (_currentImageIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildCircleButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  INFO SECTION
  // ═══════════════════════════════════════════════════

  Widget _buildInfoSection(LoaiThietBi ltb, String nhaCungCapTen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge danh mục
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.danhMucTen,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tên thiết bị
          Text(
            ltb.tenLoaiThietBi,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          // Thống kê kho & Hãng SX
          Row(
            children: [
              _buildInfoColumn(
                  'Tổng SL', '$_tongSL máy', AppColors.textSecondary),
              const SizedBox(width: 24),
              _buildInfoColumn('Hãng SX', nhaCungCapTen, AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStockIndicator(
                  AppColors.success, 'Còn: $_sanSang máy'),
              const SizedBox(width: 16),
              _buildStockIndicator(
                  AppColors.info, 'Thuê: $_dangThue máy'),
              const SizedBox(width: 16),
              _buildStockIndicator(
                  AppColors.warning, 'Bảo trì: $_dangBaoTri'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStockIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  //  PRICE CARD
  // ═══════════════════════════════════════════════════

  Widget _buildPriceCard(LoaiThietBi ltb) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Đơn giá thuê dự kiến',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_currencyFormat.format(ltb.giaThueThamKhao)} đ',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' / tháng',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  TECHNICAL SPECS
  // ═══════════════════════════════════════════════════

  Widget _buildTechnicalSpecs(LoaiThietBi ltb) {
    // Parse thông số kỹ thuật từ JSON string
    Map<String, String> specs = {};
    if (ltb.thongSoKyThuat != null && ltb.thongSoKyThuat!.isNotEmpty) {
      try {
        // thongSoKyThuat có thể là JSON object
        final jsonStr = ltb.thongSoKyThuat!;
        if (jsonStr.startsWith('{')) {
          // Parse JSON manually (simple key-value)
          final cleaned =
              jsonStr.replaceAll('{', '').replaceAll('}', '').replaceAll('"', '');
          final pairs = cleaned.split(',');
          for (var pair in pairs) {
            final parts = pair.split(':');
            if (parts.length >= 2) {
              final key = parts[0].trim().replaceAll('_', ' ');
              final value = parts.sublist(1).join(':').trim();
              specs[_formatSpecKey(key)] = value;
            }
          }
        } else {
          specs['Thông số'] = jsonStr;
        }
      } catch (_) {
        specs['Thông số'] = ltb.thongSoKyThuat ?? '';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đặc tính Kỹ thuật',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // Tình trạng vật lý
          _buildSpecCard(
            title: 'Tình trạng vật lý',
            content: 'Mới 95%',
            icon: Icons.verified_rounded,
          ),
          const SizedBox(height: 10),
          // Thông số chính
          _buildSpecCard(
            title: 'Thông số chính',
            content: specs.isNotEmpty
                ? specs.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join('\n')
                : 'Hỗ trợ xâm nhập & không xâm nhập.',
            icon: Icons.settings_rounded,
          ),
          const SizedBox(height: 10),
          // Phụ kiện đi kèm
          _buildSpecCard(
            title: 'Phụ kiện đi kèm',
            content:
                'Đầy đủ cáp nguồn, HDSD, Vật tư tiêu hao cơ bản',
            icon: Icons.inventory_2_rounded,
          ),
        ],
      ),
    );
  }

  String _formatSpecKey(String key) {
    return key
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  Widget _buildSpecCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  RELATED DEVICES
  // ═══════════════════════════════════════════════════

  Widget _buildRelatedSection() {
    if (_relatedDevices.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý thiết bị liên quan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedDevices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final related = _relatedDevices[index];
                return _buildRelatedCard(related);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCard(LoaiThietBi ltb) {
    final danhMucTen = _danhMucService.getTenDanhMuc(ltb.danhMucId);

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ClientDeviceDetailPage(
              loaiThietBi: ltb,
              danhMucTen: danhMucTen,
            ),
          ),
        );
      },
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  CloudImage(
                    imageUrl: ltb.anhDaiDien,
                    width: 155,
                    height: 100,
                    fit: BoxFit.cover,
                    fallbackIcon: Icons.devices_rounded,
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        danhMucTen,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ltb.tenLoaiThietBi,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_currencyFormat.format(ltb.giaThueThamKhao)} đ/tháng',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildMiniDot(AppColors.textHint, 'Tổng SL: 15'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildMiniDot(AppColors.success, 'Còn: 5'),
                        const SizedBox(width: 8),
                        _buildMiniDot(AppColors.info, 'Thuê: 9'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 9, color: AppColors.textHint),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  //  BOTTOM ACTION BAR (Fixed)
  // ═══════════════════════════════════════════════════

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Liên hệ button
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Liên hệ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Thêm vào giỏ hàng button
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
              label: const Text(
                'Thêm vào giỏ hàng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
