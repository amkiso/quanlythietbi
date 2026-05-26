import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

/// Màn hình Đổi mật khẩu — Premium Xypher Design
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  // ╔══════════════════════════════════════════════════╗
  // ║  FORM STATE                                     ║
  // ╚══════════════════════════════════════════════════╝
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Entrance animation ──
  late final AnimationController _enterController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Password strength ──
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = AppColors.textHint;

  @override
  void initState() {
    super.initState();

    // Smooth entrance animation (matching login_screen)
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

    // Listen to new password changes for strength indicator
    _newPasswordController.addListener(_evaluatePasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  PASSWORD STRENGTH EVALUATOR                    ║
  // ╚══════════════════════════════════════════════════╝
  void _evaluatePasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0;

    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthLabel = '';
        _passwordStrengthColor = AppColors.textHint;
      });
      return;
    }

    // Length checks
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.1;
    if (password.length >= 12) strength += 0.1;

    // Complexity checks
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;

    strength = strength.clamp(0.0, 1.0);

    String label;
    Color color;
    if (strength < 0.3) {
      label = 'Yếu';
      color = AppColors.error;
    } else if (strength < 0.6) {
      label = 'Trung bình';
      color = AppColors.warning;
    } else if (strength < 0.8) {
      label = 'Khá';
      color = AppColors.info;
    } else {
      label = 'Mạnh';
      color = AppColors.success;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  HANDLE CHANGE PASSWORD                         ║
  // ╚══════════════════════════════════════════════════╝
  Future<void> _handleChangePassword() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.doiMatKhau(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Đổi mật khẩu thành công!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            ),
            margin: const EdgeInsets.all(AppDimens.paddingMD),
            duration: const Duration(seconds: 2),
          ),
        );
        // Pop after a brief delay so user sees the snackbar
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ?? 'Đổi mật khẩu thất bại';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ╔══════════════════════════════════════════════════╗
  // ║  BUILD METHOD                                   ║
  // ╚══════════════════════════════════════════════════╝
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimens.appBarElevation,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLG,
                vertical: AppDimens.paddingMD,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // ── Hero lock icon ──
                    _buildHeroIcon(),
                    const SizedBox(height: 24),

                    // ── Description ──
                    Center(
                      child: Text(
                        'Tạo mật khẩu mới an toàn cho\ntài khoản của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Current Password ──
                    _buildFieldLabel('Mật khẩu hiện tại'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      hintText: 'Nhập mật khẩu hiện tại',
                      obscureText: _hideCurrentPassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.next,
                      onToggleVisibility: () {
                        setState(() {
                          _hideCurrentPassword = !_hideCurrentPassword;
                        });
                      },
                      isHidden: _hideCurrentPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu hiện tại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── New Password ──
                    _buildFieldLabel('Mật khẩu mới'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                      obscureText: _hideNewPassword,
                      prefixIcon: Icons.lock_reset_rounded,
                      textInputAction: TextInputAction.next,
                      onToggleVisibility: () {
                        setState(() {
                          _hideNewPassword = !_hideNewPassword;
                        });
                      },
                      isHidden: _hideNewPassword,
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
                    const SizedBox(height: 10),

                    // ── Password Strength Indicator ──
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 20),

                    // ── Confirm New Password ──
                    _buildFieldLabel('Xác nhận mật khẩu mới'),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'Nhập lại mật khẩu mới',
                      obscureText: _hideConfirmPassword,
                      prefixIcon: Icons.lock_clock_outlined,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleChangePassword(),
                      onToggleVisibility: () {
                        setState(() {
                          _hideConfirmPassword = !_hideConfirmPassword;
                        });
                      },
                      isHidden: _hideConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu mới';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // ── Error Message ──
                    _buildErrorMessage(),
                    const SizedBox(height: 20),

                    // ── Submit Button ──
                    _buildSubmitButton(),
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

  /// Gradient circle with lock icon — the hero visual
  Widget _buildHeroIcon() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF6B7FFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle inner ring
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
            ),
            const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  /// Field label text
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Password input field — matches Xypher design from login_screen
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData prefixIcon,
    required VoidCallback onToggleVisibility,
    required bool isHidden,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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
          color: AppColors.textHint.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            prefixIcon,
            size: 22,
            color: AppColors.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 22,
          minHeight: 22,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onToggleVisibility,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isHidden
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                key: ValueKey(isHidden),
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
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
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2.0,
          ),
        ),
      ),
    );
  }

  /// Password strength indicator bar + label
  Widget _buildPasswordStrengthIndicator() {
    if (_newPasswordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented strength bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _passwordStrength),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _passwordStrengthLabel,
                  key: ValueKey(_passwordStrengthLabel),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _passwordStrengthColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Error message container — matching login_screen pattern
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            border: Border.all(
              color: const Color(0xFFFFCDD2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Dismiss button
              GestureDetector(
                onTap: () => setState(() => _errorMessage = null),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Submit button with loading state
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleChangePassword,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF6B7FFF),
                  ],
                ),
          color: _isLoading
              ? AppColors.primary.withValues(alpha: 0.6)
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
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
}
