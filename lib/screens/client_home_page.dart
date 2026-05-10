import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/danh_muc_thiet_bi.dart';
import '../models/loai_thiet_bi.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../services/danh_muc_service.dart';
import '../widgets/azure_image.dart';
import 'client_device_detail_page.dart';

/// CLIENT HOME PAGE — Trang chủ dành cho Khách hàng
class ClientHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const ClientHomePage({super.key, this.onNavigateToProfile});

  @override
  ClientHomePageState createState() => ClientHomePageState();
}

class ClientHomePageState extends State<ClientHomePage> {
  final DanhMucService _danhMucService = DanhMucService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final NumberFormat _currencyFormat = NumberFormat('#,###', 'vi_VN');
  final LayerLink _layerLink = LayerLink();

  List<DanhMucThietBi> _danhMucs = [];
  List<LoaiThietBi> _allLoaiThietBi = [];
  List<LoaiThietBi> _filteredLoaiThietBi = [];
  List<LoaiThietBi> _hotLoaiThietBi = [];
  List<LoaiThietBi> _searchSuggestions = [];

  bool _isLoading = true;
  int? _selectedDanhMucId;
  String _searchQuery = '';
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _searchFocus.removeListener(_onFocusChanged);
    _searchFocus.dispose();
    super.dispose();
  }

  /// Public: reset trang chủ khi nhấn lại tab
  void resetState() {
    _searchController.clear();
    _removeOverlay();
    setState(() {
      _searchQuery = '';
      _selectedDanhMucId = null;
      _filteredLoaiThietBi = _allLoaiThietBi;
      _searchSuggestions = [];
    });
  }

  void _onFocusChanged() {
    if (!_searchFocus.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _removeOverlay();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _danhMucService.preloadCaches();
      final danhMucs = await _danhMucService.getAllDanhMuc();
      final allLoai = await _danhMucService.getLoaiThietBiByDanhMuc(null);
      if (mounted) {
        setState(() {
          _danhMucs = danhMucs;
          _allLoaiThietBi = allLoai;
          _filteredLoaiThietBi = allLoai;
          _hotLoaiThietBi = List<LoaiThietBi>.from(allLoai)
            ..sort((a, b) => b.giaThueThamKhao.compareTo(a.giaThueThamKhao));
          if (_hotLoaiThietBi.length > 4) _hotLoaiThietBi = _hotLoaiThietBi.sublist(0, 4);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
      if (query.isNotEmpty) {
        _searchSuggestions = _allLoaiThietBi
            .where((l) => l.tenLoaiThietBi.toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();
        _showOverlay();
      } else {
        _searchSuggestions = [];
        _removeOverlay();
      }
    });
  }

  void _onDanhMucSelected(int? danhMucId) {
    setState(() {
      _selectedDanhMucId = _selectedDanhMucId == danhMucId ? null : danhMucId;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<LoaiThietBi> result = _allLoaiThietBi;
    if (_selectedDanhMucId != null) {
      result = result.where((l) => l.danhMucId == _selectedDanhMucId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result.where((l) => l.tenLoaiThietBi.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    _filteredLoaiThietBi = result;
  }

  Future<void> _addToCart(LoaiThietBi ltb) async {
    try {
      await context.read<CartProvider>().addItem(ltb);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Đã thêm "${ltb.tenLoaiThietBi}" vào giỏ hàng', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Không thể thêm vào giỏ: $e', style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ));
      }
    }
  }

  void _navigateToDetail(LoaiThietBi ltb) {
    _removeOverlay();
    _searchFocus.unfocus();
    final danhMucTen = _danhMucService.getTenDanhMuc(ltb.danhMucId);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ClientDeviceDetailPage(loaiThietBi: ltb, danhMucTen: danhMucTen),
    ));
  }

  // ── Overlay for search suggestions ──
  void _showOverlay() {
    _removeOverlay();
    if (_searchSuggestions.isEmpty) return;
    _overlayEntry = OverlayEntry(builder: (ctx) {
      return Positioned(
        width: MediaQuery.of(context).size.width - 32 - 42 - 42 - 28,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 46),
          showWhenUnlinked: false,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _searchSuggestions.map((ltb) {
                  return InkWell(
                    onTap: () => _navigateToDetail(ltb),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AzureImage(imageUrl: ltb.anhDaiDien, width: 36, height: 36, fit: BoxFit.cover, fallbackIcon: Icons.devices_rounded, fallbackIconSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ltb.tenLoaiThietBi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${_currencyFormat.format(ltb.giaThueThamKhao)} đ/tháng', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                          ],
                        )),
                        const Icon(Icons.north_west_rounded, size: 16, color: AppColors.textHint),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildSliverHeader(),
                  SliverToBoxAdapter(child: _buildContractCard()),
                  SliverToBoxAdapter(child: _buildCategorySection()),
                  SliverToBoxAdapter(child: _buildHotSection()),
                  SliverToBoxAdapter(child: _buildSuggestedHeader()),
                  _buildSuggestedGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }

  // ── HEADER ──
  Widget _buildSliverHeader() {
    final auth = context.watch<AuthProvider>();
    final name = auth.hoTen ?? 'Người dùng';
    final nameEncoded = Uri.encodeComponent(name);

    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5B72F0), Color(0xFF7B8FF7)]),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(children: [
              // Search bar with overlay link
              Expanded(
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: Container(
                    height: 42,
                    
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14),
                      
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm, mã,...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Notification bell
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Stack(alignment: Alignment.center, children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  Positioned(top: 8, right: 8, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
                ]),
              ),
              const SizedBox(width: 8),
              // Avatar → navigate to profile
              GestureDetector(
                onTap: widget.onNavigateToProfile,
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=$nameEncoded&background=4A6CF7&color=fff&size=200'), fit: BoxFit.cover),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── HỢP ĐỒNG ──
  Widget _buildContractCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5B72F0), Color(0xFF7B8FF7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF5B72F0).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MÃ HỢP ĐỒNG', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          const Text('HD-YT-2401', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade300, size: 16),
            const SizedBox(width: 6),
            Text('Thanh toán trước 01/06/2026', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            const Spacer(),
            Text('Còn 3 ngày', style: TextStyle(color: Colors.amber.shade300, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text('6 SP', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('Cuối tháng thứ 4', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
            const Spacer(),
            Text('4.800.000 đ', style: TextStyle(color: Colors.amber.shade300, fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _buildContractBtn('Xem chi tiết đơn hàng', outlined: true),
            const SizedBox(width: 8),
            _buildContractBtn('Gia hạn', outlined: false),
          ]),
        ]),
      ),
    );
  }

  Widget _buildContractBtn(String text, {required bool outlined}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: outlined ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: outlined ? 0.5 : 0.3)),
            ),
            child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
          ),
        ),
      ),
    );
  }

  // ── DANH MỤC ──
  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Danh mục thiết bị', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          GestureDetector(
            onTap: () { setState(() { _selectedDanhMucId = null; _applyFilters(); }); },
            child: Text('Xem tất cả', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _danhMucs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _buildCategoryItem(_danhMucs[i], _selectedDanhMucId == _danhMucs[i].danhMucId),
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoryItem(DanhMucThietBi dm, bool isSelected) {
    final iconMap = {'Y tế': Icons.local_hospital_rounded, 'Giáo dục': Icons.school_rounded, 'Sự kiện': Icons.celebration_rounded, 'Công trình': Icons.construction_rounded, 'Công nghiệp': Icons.precision_manufacturing_rounded, 'Văn Phòng': Icons.business_rounded, 'Cứu hộ': Icons.health_and_safety_rounded};
    final icon = iconMap[dm.tenDanhMuc] ?? Icons.devices_rounded;
    return GestureDetector(
      onTap: () => _onDanhMucSelected(dm.danhMucId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 78,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(dm.tenDanhMuc, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  // ── HOT ──
  Widget _buildHotSection() {
    if (_searchQuery.isNotEmpty || _selectedDanhMucId != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Thuê thiết bị y tế HOT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          GestureDetector(onTap: () {}, child: Text('Xem tất cả', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: _hotLoaiThietBi.isEmpty
              ? Center(child: Text('Không có thiết bị', style: TextStyle(color: AppColors.textHint)))
              : ListView.separated(
                  scrollDirection: Axis.horizontal, itemCount: _hotLoaiThietBi.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _buildProductCard(_hotLoaiThietBi[i], width: 165),
                ),
        ),
      ]),
    );
  }

  // ── GỢI Ý ──
  Widget _buildSuggestedHeader() {
    final title = (_searchQuery.isNotEmpty || _selectedDanhMucId != null) ? 'Kết quả (${_filteredLoaiThietBi.length})' : 'Gợi ý thiết bị y tế';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }

  Widget _buildSuggestedGrid() {
    if (_filteredLoaiThietBi.isEmpty) {
      return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(40), child: Center(child: Column(children: [
        Icon(Icons.search_off_rounded, size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text('Không tìm thấy thiết bị phù hợp', style: TextStyle(color: AppColors.textHint)),
      ]))));
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.62),
        delegate: SliverChildBuilderDelegate((_, i) => _buildProductCard(_filteredLoaiThietBi[i]), childCount: _filteredLoaiThietBi.length),
      ),
    );
  }

  // ── PRODUCT CARD ──
  Widget _buildProductCard(LoaiThietBi ltb, {double? width}) {
    final danhMucTen = _danhMucService.getTenDanhMuc(ltb.danhMucId);
    return GestureDetector(
      onTap: () => _navigateToDetail(ltb),
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ảnh sản phẩm ──
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(children: [
                AzureImage(imageUrl: ltb.anhDaiDien, width: double.infinity, height: 120, fit: BoxFit.cover, fallbackIcon: Icons.devices_rounded),
                Positioned(top: 8, left: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                  child: Text(danhMucTen, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                )),
              ]),
            ),
            // ── Thông tin sản phẩm ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ltb.tenLoaiThietBi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${_currencyFormat.format(ltb.giaThueThamKhao)} đ/tháng', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Row(children: [
                    _dot(AppColors.textSecondary, 'Tổng SL: 15'),
                    const SizedBox(width: 6),
                    _dot(AppColors.success, 'Còn: 5'),
                    const SizedBox(width: 6),
                    _dot(AppColors.info, 'Thuê: 9'),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, height: 30, child: ElevatedButton.icon(
                    onPressed: () => _addToCart(ltb),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                    label: const Text('Thêm', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: Size.zero, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 3),
    Text(t, style: TextStyle(fontSize: 9, color: AppColors.textHint, fontWeight: FontWeight.w500)),
  ]);
}
