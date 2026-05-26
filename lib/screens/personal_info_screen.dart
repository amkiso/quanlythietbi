import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/azure_image.dart';

/// PERSONAL INFO SCREEN — Thông tin cá nhân
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _profile = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadProfile();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _authService.getProfile();
      if (mounted) {
        setState(() {
          _profile = data;
          _isLoading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _safe(dynamic value, [String fallback = 'Chưa cập nhật']) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Chưa cập nhật';
    try {
      final dt = DateTime.parse(value.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return value.toString();
    }
  }

  String _formatStatus(dynamic value) {
    if (value == null) return 'Chưa cập nhật';
    if (value is bool) return value ? 'Hoạt động' : 'Ngưng hoạt động';
    if (value is int) return value == 1 ? 'Hoạt động' : 'Ngưng hoạt động';
    final s = value.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'active' || s == 'hoạt động') {
      return 'Hoạt động';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadProfile,
                  child: _buildContent(),
                ),
    );
  }

  // ─── LOADING STATE ──────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
              backgroundColor: AppColors.primarySurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải thông tin...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông tin',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: AppDimens.buttonHeightSM,
              child: ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Thử lại', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MAIN CONTENT ───────────────────────────────────
  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              _buildHeaderSection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    _buildSectionCard(
                      icon: Icons.account_circle_outlined,
                      title: 'Tài khoản',
                      items: [
                        _InfoItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Họ và tên',
                          value: _safe(_profile['hoTen']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      icon: Icons.contact_mail_outlined,
                      title: 'Liên hệ',
                      items: [
                        _InfoItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _safe(_profile['email']),
                        ),
                        _InfoItem(
                          icon: Icons.phone_outlined,
                          label: 'Số điện thoại',
                          value: _safe(_profile['soDienThoai']),
                        ),
                        _InfoItem(
                          icon: Icons.location_on_outlined,
                          label: 'Địa chỉ',
                          value: _safe(_profile['diaChi']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── GRADIENT HEADER ────────────────────────────────
  Widget _buildHeaderSection() {
    final auth = context.read<AuthProvider>();
    final name = _safe(_profile['hoTen'], auth.hoTen ?? 'Người dùng');
    
    String? validAvatarUrl;
    final profileAvt = _profile['avt']?.toString();
    if (profileAvt != null && profileAvt != 'null' && profileAvt.trim().isNotEmpty) {
      validAvatarUrl = profileAvt;
    } else if (auth.avt != null && auth.avt!.isNotEmpty) {
      validAvatarUrl = auth.avt;
    }
    
    final nameEncoded = Uri.encodeComponent(name);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            AppColors.primaryLight.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              // ── Avatar ──
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (validAvatarUrl != null)
                      ? AzureImage(
                          imageUrl: validAvatarUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://ui-avatars.com/api/?name=$nameEncoded&background=4A6CF7&color=fff&size=200',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.primaryDark,
                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Name ──
              Text(
                name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SECTION CARD ───────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section title ──
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Items ──
            ...List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildInfoRow(item),
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Divider(
                        color: AppColors.divider.withValues(alpha: 0.6),
                        height: 1,
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─── INFO ROW ───────────────────────────────────────
  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Icon container ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: item.icon == Icons.circle ? 12 : 18,
            ),
          ),
          const SizedBox(width: 12),

          // ── Text column ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 15,
                    color: item.valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DATA CLASS ─────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
