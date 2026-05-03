import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/token_storage.dart';

/// Màn hình đăng nhập - Xypher Design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ╔══════════════════════════════════════════════════╗
  // ║  EXISTING LOGIC — PRESERVED INTACT              ║
  // ╚══════════════════════════════════════════════════╝
  final _formKey = GlobalKey<FormState>();
  final _taiKhoanController = TextEditingController();
  final _matKhauController = TextEditingController();
  bool _hidePassword = true;
  bool _rememberMe = false;

  // ── Entrance animation ──
  late final AnimationController _enterController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Smooth entrance animation
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

  /// Đọc thông tin đăng nhập đã lưu (nếu có)
  Future<void> _loadSavedCredentials() async {
    final remember = await TokenStorage.getRememberMe();
    if (remember) {
      final creds = await TokenStorage.getSavedCredentials();
      if (mounted) {
        setState(() {
          _rememberMe = true;
          _taiKhoanController.text = creds['taiKhoan'] ?? '';
          _matKhauController.text = creds['matKhau'] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _taiKhoanController.dispose();
    _matKhauController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Lưu hoặc xóa credentials theo trạng thái checkbox
      if (_rememberMe) {
        await TokenStorage.saveRememberMe(true);
        await TokenStorage.saveCredentials(
          taiKhoan: _taiKhoanController.text.trim(),
          matKhau: _matKhauController.text,
        );
      } else {
        await TokenStorage.clearCredentials();
      }

      final success = await authProvider.login(
        _taiKhoanController.text.trim(),
        _matKhauController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  XYPHER UI — BUILD METHOD                       ║
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // ── Xypher logo (icon + text) ──
                    _buildXypherLogo(),
                    const SizedBox(height: 40),

                    // ── Title: ĐĂNG NHẬP ──
                    const Text(
                      'ĐĂNG NHẬP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: XypherColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chào mừng bạn quay trở lại',
                      style: TextStyle(
                        fontSize: 14,
                        color: XypherColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Account Input ──
                    _buildInputField(
                      controller: _taiKhoanController,
                      hintText: 'Nhập tài khoản',
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tài khoản';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Password Input ──
                    _buildInputField(
                      controller: _matKhauController,
                      hintText: 'Nhập Password',
                      obscureText: _hidePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // ── Remember Me + Forgot Password Row ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Checkbox "Nhớ đăng nhập"
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: XypherColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: XypherColors.textSecondary,
                                    width: 1.5,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Nhớ đăng nhập',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: XypherColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // "Quên mật khẩu?"
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to forgot password screen
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 13,
                              color: XypherColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Error Message (from existing AuthProvider) ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        if (auth.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
                                      auth.errorMessage!,
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
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Login Button ──
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return _buildLoginButton(auth.isLoading);
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Register Section ──
                    _buildRegisterRow(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  UI BUILDER METHODS
  // ═══════════════════════════════════════════════════

  /// Full "Xypher" logo at the top (icon graphic + text),
  /// matching the final state of the splash animation
  Widget _buildXypherLogo() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Stylized icon graphic ──
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  XypherColors.primary,
                  Color(0xFF6B7FFF),
                ],
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
                // Inner geometric border
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
          // ── "ypher" text ──
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

  /// Custom input field matching the Xypher design
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

  /// Primary "Đăng nhập" button
  Widget _buildLoginButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleLogin,
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
              : const Text(
                  'Đăng nhập',
                  style: TextStyle(
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

  /// "Chưa có tài khoản? Đăng ký ngay" row
  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            fontSize: 14,
            color: XypherColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to registration screen
          },
          child: const Text(
            'Đăng ký ngay',
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
