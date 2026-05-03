import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';

/// Splash Screen - Xypher brand animation
/// Phase 1: Fade-in & scale the stylized icon graphic at center
/// Phase 2: Icon slides left + "ypher" reveals from behind
/// Supports looping as a loading indicator until app is ready
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Phase 1: Fade-in & scale of the icon
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Phase 2: Slide icon to the left + reveal "ypher"
  late final AnimationController _slideController;
  late final Animation<double> _iconSlideAnimation;
  late final Animation<double> _ypherRevealAnimation;
  late final Animation<double> _ypherOpacityAnimation;

  // Glow pulse for the icon during Phase 1
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  // Whether the app is ready to navigate (set externally or after timeout)
  bool _appReady = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent for immersive splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // ── Phase 1 Controller: Fade-in + Scale ──
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    // ── Glow pulse for icon ──
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // ── Phase 2 Controller: Slide + Reveal ──
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Icon slides from center (0.0) to slightly left
    _iconSlideAnimation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // "ypher" reveals via clipping: 0.0 (hidden) → 1.0 (fully visible)
    _ypherRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _ypherOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Small initial delay for visual breathing room
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Phase 1: Fade-in + scale the icon
    _fadeController.forward();

    // Start glow pulse while icon is centered
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _glowController.repeat(reverse: true);

    // Wait for Phase 1 to complete + a short pause
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Stop glow and proceed to Phase 2
    _glowController.stop();
    _glowController.animateTo(0.0,
        duration: const Duration(milliseconds: 200));

    // Phase 2: Slide icon left & reveal "ypher"
    _slideController.forward();

    // Wait for Phase 2 to complete + hold the full logo
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    _animationComplete = true;
    _appReady = true;

    // Navigate to auth check
    _navigateWhenReady();
  }

  void _navigateWhenReady() {
    if (_appReady && _animationComplete && mounted) {
      Navigator.pushReplacementNamed(context, '/auth-check');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XypherColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation:
              Listenable.merge([_fadeController, _slideController, _glowController]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLogoRow(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoRow() {
    const ypherStyle = TextStyle(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      color: XypherColors.textDark,
      letterSpacing: 1.2,
      height: 1.0,
    );

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── The stylized "X" icon graphic ──
            Transform.translate(
              offset: Offset(_iconSlideAnimation.value * 6, 0),
              child: _buildStylizedIcon(),
            ),

            // ── The "ypher" text, revealed via ClipRect ──
            Opacity(
              opacity: _ypherOpacityAnimation.value,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: _ypherRevealAnimation.value,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('ypher', style: ypherStyle),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The stylized "X" icon — a geometric/abstract graphic
  /// matching the Xypher branding (not a plain letter)
  Widget _buildStylizedIcon() {
    final glowValue = _glowAnimation.value;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            XypherColors.primary,
            XypherColors.primary.withValues(alpha: 0.85),
            const Color(0xFF6B7FFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: XypherColors.primary.withValues(alpha: 0.15 + glowValue * 0.25),
            blurRadius: 16 + glowValue * 12,
            offset: const Offset(0, 4),
            spreadRadius: glowValue * 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner geometric pattern
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            bottom: 8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // "X" mark as part of the icon
          const Text(
            'X',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}
