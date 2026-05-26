import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';

/// Màn hình Quên mật khẩu — Xypher Design (multi-step)
///
/// Flow:
///   Step 1: Nhập email → gọi check-email-reset
///   Step 2a (KH): Gửi OTP → nhập OTP → xác nhận
///   Step 2b (NV): Hiển thị thông báo liên hệ admin
///   Step 3: Nhập mật khẩu mới → gọi forgot-password-confirm
///   Step 4: Thành công → quay về đăng nhập
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──
  final _authService = AuthService();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // Step: 1=email, 2=otp, 3=newPassword, 4=success, 5=contactAdmin
  int _currentStep = 1;

  // OTP countdown
  Timer? _countdownTimer;
  int _remainingSeconds = 300;
  bool _canResend = false;

  // Admin info (for employee accounts)
  String _adminPhone = '';
  String _adminName = '';

  // Entrance animation
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
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  // ════════════════════════════════════════════════════
  //  BUSINESS LOGIC
  // ════════════════════════════════════════════════════

  /// Step 1: Kiểm tra email
  Future<void> _handleCheckEmail() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.checkEmailForReset(
        _emailController.text.trim(),
      );

      final isCustomer = result['isCustomer'] == true ||
          result['customer'] == true;

      if (isCustomer) {
        // Khách hàng → gửi OTP
        await _authService.forgotPasswordInit(_emailController.text.trim());
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentStep = 2;
          });
          _startCountdown();
        }
      } else {
        // Nhân viên → hiển thị trang liên hệ admin
        if (mounted) {
          setState(() {
            _isLoading = false;
            _adminPhone = result['adminPhone']?.toString() ?? '0123456789';
            _adminName = result['adminName']?.toString() ?? 'Quản trị viên';
            _currentStep = 5;
          });
        }
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

  /// Step 2: Xác nhận OTP
  Future<void> _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _currentStep = 3;
    });
  }

  /// Step 3: Đổi mật khẩu
  Future<void> _handleResetPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final otp = _otpControllers.map((c) => c.text).join();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPasswordConfirm(
        email: _emailController.text.trim(),
        otp: otp,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 4;
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

  /// Gửi lại OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPasswordInit(_emailController.text.trim());
      if (mounted) {
        setState(() => _isLoading = false);
        _startCountdown();
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

  // ════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════
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
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Email();
      case 2:
        return _buildStep2Otp();
      case 3:
        return _buildStep3NewPassword();
      case 4:
        return _buildStep4Success();
      case 5:
        return _buildStep5ContactAdmin();
      default:
        return _buildStep1Email();
    }
  }

  // ═══════════════════════════════════════════════════
  //  STEP 1 — NHẬP EMAIL
  // ═══════════════════════════════════════════════════
  Widget _buildStep1Email() {
    return SingleChildScrollView(
      key: const ValueKey('step1-email'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),
            _buildXypherLogo(),
            const SizedBox(height: 48),

            // Hero icon
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      XypherColors.primary.withValues(alpha: 0.12),
                      XypherColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
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
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'QUÊN MẬT KHẨU',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: XypherColors.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nhập email đã đăng ký để lấy lại mật khẩu',
              style: TextStyle(
                fontSize: 14,
                color: XypherColors.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Email field
            _buildInputField(
              controller: _emailController,
              hintText: 'Email đã đăng ký',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleCheckEmail(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            _buildErrorMessage(),
            const SizedBox(height: 20),

            _buildActionButton(
              label: 'Tiếp tục',
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onTap: _handleCheckEmail,
            ),
            const SizedBox(height: 28),

            // Back to login
            _buildBackToLoginRow(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP 2 — XÁC NHẬN OTP
  // ═══════════════════════════════════════════════════
  Widget _buildStep2Otp() {
    return SingleChildScrollView(
      key: const ValueKey('step2-otp'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 36),
          _buildXypherLogo(),
          const SizedBox(height: 40),

          // Email icon
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
                    Icons.mark_email_read_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Title
          const Center(
            child: Text(
              'Xác nhận OTP',
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

          // OTP fields
          _buildOtpFields(),
          const SizedBox(height: 20),

          // Countdown
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

          _buildErrorMessage(),
          const SizedBox(height: 20),

          _buildActionButton(
            label: 'Xác nhận',
            icon: Icons.verified_outlined,
            isLoading: _isLoading,
            onTap: _handleVerifyOtp,
          ),
          const SizedBox(height: 16),

          // Resend
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

          // Back to step 1
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
                  Icon(Icons.arrow_back_ios_rounded,
                      size: 16, color: XypherColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Quay lại nhập email',
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
  //  STEP 3 — MẬT KHẨU MỚI
  // ═══════════════════════════════════════════════════
  Widget _buildStep3NewPassword() {
    return SingleChildScrollView(
      key: const ValueKey('step3-password'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),
            _buildXypherLogo(),
            const SizedBox(height: 48),

            // Hero icon
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.12),
                      const Color(0xFF10B981).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_open_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'TẠO MẬT KHẨU MỚI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF10B981),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nhập mật khẩu mới cho tài khoản của bạn',
              style: TextStyle(
                fontSize: 14,
                color: XypherColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),

            // New password
            _buildInputField(
              controller: _newPasswordController,
              hintText: 'Mật khẩu mới',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _hidePassword = !_hidePassword),
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
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Confirm password
            _buildInputField(
              controller: _confirmPasswordController,
              hintText: 'Xác nhận mật khẩu mới',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _hideConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleResetPassword(),
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
                if (value != _newPasswordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            _buildErrorMessage(),
            const SizedBox(height: 20),

            _buildActionButton(
              label: 'Đổi mật khẩu',
              icon: Icons.check_circle_outline_rounded,
              isLoading: _isLoading,
              onTap: _handleResetPassword,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP 4 — THÀNH CÔNG
  // ═══════════════════════════════════════════════════
  Widget _buildStep4Success() {
    return SingleChildScrollView(
      key: const ValueKey('step4-success'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 36),
          _buildXypherLogo(),
          const SizedBox(height: 80),

          // Success icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.12),
                  const Color(0xFF10B981).withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          const Text(
            'Đổi mật khẩu thành công!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF10B981),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mật khẩu đã được cập nhật.\nBạn có thể đăng nhập bằng mật khẩu mới.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: XypherColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),

          _buildActionButton(
            label: 'Quay về đăng nhập',
            icon: Icons.login_rounded,
            isLoading: false,
            onTap: () => Navigator.pop(context),
            color: XypherColors.primary,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  STEP 5 — LIÊN HỆ QUẢN TRỊ VIÊN (Nhân viên)
  // ═══════════════════════════════════════════════════
  Widget _buildStep5ContactAdmin() {
    return SingleChildScrollView(
      key: const ValueKey('step5-admin'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 36),
          _buildXypherLogo(),
          const SizedBox(height: 60),

          // Warning icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEF6C00).withValues(alpha: 0.12),
                  const Color(0xFFEF6C00).withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEF6C00), Color(0xFFFFA726)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF6C00).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Warning message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFCC80),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFEF6C00),
                  size: 28,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tài khoản không nằm trong diện tự do',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE65100),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Vui lòng liên hệ quản trị viên để lấy lại mật khẩu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFFBF360C).withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Admin contact card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Admin avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [XypherColors.primary, Color(0xFF6B7FFF)],
                    ),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _adminName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: XypherColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Quản trị viên hệ thống',
                  style: TextStyle(
                    fontSize: 13,
                    color: XypherColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: XypherColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        color: XypherColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _adminPhone,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: XypherColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          _buildActionButton(
            label: 'Quay về đăng nhập',
            icon: Icons.arrow_back_rounded,
            isLoading: false,
            onTap: () => Navigator.pop(context),
            color: XypherColors.primary,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════

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
                child: Icon(prefixIcon, size: 22, color: XypherColors.textSecondary),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: XypherColors.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: XypherColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2.0),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: XypherColors.textDark,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: XypherColors.inputBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: XypherColors.primary, width: 2.0),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 20),
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
            GestureDetector(
              onTap: () => setState(() => _errorMessage = null),
              child: const Icon(Icons.close_rounded, color: Color(0xFFE53935), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onTap,
    Color? color,
  }) {
    final btnColor = color ?? XypherColors.buttonColor;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isLoading ? btnColor.withValues(alpha: 0.7) : btnColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: btnColor.withValues(alpha: 0.3),
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_back_ios_rounded,
            size: 14, color: XypherColors.textSecondary),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Quay về đăng nhập',
            style: TextStyle(
              fontSize: 14,
              color: XypherColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
