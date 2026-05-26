import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

/// Màn hình đăng ký — Xypher Design (2‑step OTP flow)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ╔══════════════════════════════════════════════════╗
  // ║  STATE                                          ║
  // ╚══════════════════════════════════════════════════╝
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Step 1 controllers
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  // Step 2 controllers — 6 OTP digits
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Step management
  int _currentStep = 1; // 1 = form, 2 = OTP

  // OTP countdown
  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 minutes
  bool _canResend = false;

  // ── Entrance animation ──
  late final AnimationController _enterController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
    ));

    _enterController.forward();
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _soDienThoaiController.dispose();
    _diaChiController.dispose();
    _matKhauController.dispose();
    _xacNhanMatKhauController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    _enterController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  BUSINESS LOGIC                                 ║
  // ╚══════════════════════════════════════════════════╝

  void _startCountdown() {
    _remainingSeconds = 300;
    _canResend = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedCountdown {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Step 1 → register init
  Future<void> _handleRegisterInit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerInit(
        hoTen: _hoTenController.text.trim(),
        email: _emailController.text.trim(),
        matKhau: _matKhauController.text,
        soDienThoai: _soDienThoaiController.text.trim(),
        diaChi: _diaChiController.text.trim().isEmpty
            ? null
            : _diaChiController.text.trim(),
        loaiKhachHangId: 1,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  /// Step 2 → register confirm
  Future<void> _handleRegisterConfirm() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.registerConfirm(
        email: _emailController.text.trim(),
        otp: otp,
      );

      if (response.success && response.data != null) {
        final loginData = response.data!;

        // Save token
        await TokenStorage.saveLoginInfo(
          token: loginData.token,
          nguoiDungId: loginData.nguoiDungId,
          hoTen: loginData.hoTen,
          maNguoiDung: loginData.maNguoiDung,
          vaiTroId: loginData.vaiTroId,
          tenVaiTro: loginData.tenVaiTro,
          khoId: loginData.khoId,
          doiMatKhauLanDau: loginData.doiMatKhauLanDau,
          avt: loginData.avt,
        );

        // Update AuthProvider
        if (mounted) {
          await context.read<AuthProvider>().checkLoginStatus();
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.message ?? 'Xác nhận OTP thất bại';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  /// Resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerInit(
        hoTen: _hoTenController.text.trim(),
        email: _emailController.text.trim(),
        matKhau: _matKhauController.text,
        soDienThoai: _soDienThoaiController.text.trim(),
        diaChi: _diaChiController.text.trim().isEmpty
            ? null
            : _diaChiController.text.trim(),
        loaiKhachHangId: 1,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _startCountdown();
        // Clear old OTP
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  BUILD                                          ║
  // ╚══════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XypherColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideIn = Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slideIn, child: child),
                );
              },
              child: _currentStep == 1
                  ? _buildStep1Form()
                  : _buildStep2Otp(),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP 1 — REGISTRATION FORM
  // ═══════════════════════════════════════════════════
  Widget _buildStep1Form() {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),

            // ── Logo ──
            _buildXypherLogo(),
            const SizedBox(height: 32),

            // ── Title ──
            const Text(
              'ĐĂNG KÝ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: XypherColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo tài khoản mới để bắt đầu',
              style: TextStyle(
                fontSize: 14,
                color: XypherColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),

            // ── Họ tên ──
            _buildInputField(
              controller: _hoTenController,
              hintText: 'Họ và tên',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Email ──
            _buildInputField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }
                final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Số điện thoại ──
            _buildInputField(
              controller: _soDienThoaiController,
              hintText: 'Số điện thoại',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Địa chỉ (optional) ──
            _buildInputField(
              controller: _diaChiController,
              hintText: 'Địa chỉ (không bắt buộc)',
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // ── Mật khẩu ──
            _buildInputField(
              controller: _matKhauController,
              hintText: 'Mật khẩu',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _hidePassword = !_hidePassword),
                child: Icon(
                  _hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: XypherColors.textSecondary,
                  size: 22,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // ── Xác nhận mật khẩu ──
            _buildInputField(
              controller: _xacNhanMatKhauController,
              hintText: 'Xác nhận mật khẩu',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _hideConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegisterInit(),
              suffixIcon: GestureDetector(
                onTap: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword),
                child: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: XypherColors.textSecondary,
                  size: 22,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _matKhauController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // ── Error message ──
            _buildErrorMessage(),
            const SizedBox(height: 16),

            // ── Register button ──
            _buildActionButton(
              label: 'Đăng ký',
              isLoading: _isLoading,
              onTap: _handleRegisterInit,
            ),
            const SizedBox(height: 28),

            // ── Login link ──
            _buildLoginRow(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP 2 — OTP VERIFICATION
  // ═══════════════════════════════════════════════════
  Widget _buildStep2Otp() {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 36),

          // ── Logo ──
          _buildXypherLogo(),
          const SizedBox(height: 40),

          // ── Email icon ──
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    XypherColors.primary.withValues(alpha: 0.12),
                    XypherColors.primary.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [XypherColors.primary, Color(0xFF6B7FFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: XypherColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Title ──
          const Center(
            child: Text(
              'Kiểm tra email',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: XypherColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: XypherColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Mã xác nhận đã được gửi đến\n'),
                  TextSpan(
                    text: _emailController.text.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: XypherColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          // ── OTP Fields ──
          _buildOtpFields(),
          const SizedBox(height: 20),

          // ── Countdown ──
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _canResend
                  ? const Text(
                      'Mã đã hết hạn',
                      key: ValueKey('expired'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Row(
                      key: const ValueKey('countdown'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: XypherColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mã hết hạn sau $_formattedCountdown',
                          style: TextStyle(
                            fontSize: 14,
                            color: XypherColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Error message ──
          _buildErrorMessage(),
          const SizedBox(height: 20),

          // ── Confirm button ──
          _buildActionButton(
            label: 'Xác nhận',
            isLoading: _isLoading,
            onTap: _handleRegisterConfirm,
          ),
          const SizedBox(height: 16),

          // ── Resend OTP ──
          Center(
            child: GestureDetector(
              onTap: _canResend && !_isLoading ? _handleResendOtp : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _canResend
                      ? XypherColors.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: _canResend
                          ? XypherColors.primary
                          : XypherColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Gửi lại mã',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _canResend
                            ? XypherColors.primary
                            : XypherColors.textSecondary
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Back to step 1 ──
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = 1;
                  _errorMessage = null;
                  _countdownTimer?.cancel();
                  for (final c in _otpControllers) {
                    c.clear();
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: XypherColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Quay lại chỉnh sửa',
                    style: TextStyle(
                      fontSize: 14,
                      color: XypherColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  UI BUILDER METHODS
  // ═══════════════════════════════════════════════════

  /// Xypher logo — identical to login_screen
  Widget _buildXypherLogo() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [XypherColors.primary, Color(0xFF6B7FFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: XypherColors.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 6,
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const Text(
                  'X',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'ypher',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: XypherColors.textDark,
              letterSpacing: 1.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Custom input field — matches login_screen style
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2D2D2D),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: XypherColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  prefixIcon,
                  size: 22,
                  color: XypherColors.textSecondary,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 22,
          minHeight: 22,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 22,
          minHeight: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: XypherColors.inputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: XypherColors.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE53935),
            width: 2.0,
          ),
        ),
      ),
    );
  }

  /// 6‑digit OTP input row
  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(
            left: index == 0 ? 0 : 6,
            right: index == 5 ? 0 : 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty
                  ? XypherColors.primary
                  : XypherColors.inputBorder,
              width: _otpControllers[index].text.isNotEmpty ? 2.0 : 1.5,
            ),
            boxShadow: _otpControllers[index].text.isNotEmpty
                ? [
                    BoxShadow(
                      color: XypherColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
                height: 1.0,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {}); // Rebuild for border color
                if (value.isNotEmpty && index < 5) {
                  _otpFocusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _otpFocusNodes[index - 1].requestFocus();
                }
              },
            ),
          ),
        );
      }),
    );
  }

  /// Error message container
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFCDD2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFE53935),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable action button (Đăng ký / Xác nhận)
  Widget _buildActionButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isLoading
              ? XypherColors.buttonColor.withValues(alpha: 0.7)
              : XypherColors.buttonColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: XypherColors.buttonColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }

  /// "Đã có tài khoản? Đăng nhập" row
  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            fontSize: 14,
            color: XypherColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: 14,
              color: XypherColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
