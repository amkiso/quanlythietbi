import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_theme.dart';
import '../services/thiet_bi_service.dart';
import 'device_scan_result_screen.dart';

/// QR SCANNER SCREEN — Quét mã QR thiết bị
/// Format QR: DEVICE:<maTaiSan>
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  final ThietBiService _thietBiService = ThietBiService();

  bool _isProcessing = false;
  bool _torchOn = false;
  late AnimationController _animController;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;

      // Parse QR content: DEVICE:<maTaiSan>
      if (rawValue.startsWith('DEVICE:')) {
        final maTaiSan = rawValue.substring(7);
        if (maTaiSan.isNotEmpty) {
          _handleScan(maTaiSan);
          return;
        }
      }
    }
  }

  Future<void> _handleScan(String maTaiSan) async {
    setState(() => _isProcessing = true);

    try {
      final deviceData = await _thietBiService.traCuu(maTaiSan);

      if (!mounted) return;

      // Navigate to result screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeviceScanResultScreen(deviceData: deviceData),
        ),
      );

      // Resume scanning after returning
      if (mounted) setState(() => _isProcessing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                e.toString().replaceFirst('Exception: ', ''),
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    }
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Overlay with scan area
          _buildOverlay(),

          // Top bar
          _buildTopBar(),

          // Bottom instructions
          _buildBottomPanel(),

          // Loading overlay
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                ),
                const Expanded(
                  child: Text(
                    'Quét mã QR thiết bị',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleTorch,
                  icon: Icon(
                    _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _torchOn ? Colors.amber : Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(builder: (context, constraints) {
      final scanAreaSize = constraints.maxWidth * 0.7;
      final top = (constraints.maxHeight - scanAreaSize) / 2 - 20;
      final left = (constraints.maxWidth - scanAreaSize) / 2;

      return Stack(
        children: [
          // Dark overlay with cutout
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.55),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.red, // any non-transparent color
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Positioned(
                  top: top,
                  left: left,
                  child: Container(
                    width: scanAreaSize,
                    height: scanAreaSize,
                    decoration: BoxDecoration(
                      color: Colors.red, // any non-transparent color
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Corner decorations
          Positioned(
            top: top,
            left: left,
            child: _buildScanFrame(scanAreaSize),
          ),

          // Animated scan line
          Positioned(
            top: top,
            left: left,
            child: AnimatedBuilder(
              animation: _scanLineAnim,
              builder: (context, child) {
                return Container(
                  width: scanAreaSize,
                  height: scanAreaSize,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment(0, -1 + _scanLineAnim.value * 2),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildScanFrame(double size) {
    const cornerLength = 30.0;
    const cornerWidth = 4.0;
    const cornerRadius = 20.0;

    Widget buildCorner({
      required Alignment alignment,
      required BorderRadius borderRadius,
    }) {
      return Align(
        alignment: alignment,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: BoxDecoration(
            border: Border(
              top: alignment.y < 0
                  ? const BorderSide(color: AppColors.primary, width: cornerWidth)
                  : BorderSide.none,
              bottom: alignment.y > 0
                  ? const BorderSide(color: AppColors.primary, width: cornerWidth)
                  : BorderSide.none,
              left: alignment.x < 0
                  ? const BorderSide(color: AppColors.primary, width: cornerWidth)
                  : BorderSide.none,
              right: alignment.x > 0
                  ? const BorderSide(color: AppColors.primary, width: cornerWidth)
                  : BorderSide.none,
            ),
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          buildCorner(
            alignment: Alignment.topLeft,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(cornerRadius)),
          ),
          buildCorner(
            alignment: Alignment.topRight,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(cornerRadius)),
          ),
          buildCorner(
            alignment: Alignment.bottomLeft,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(cornerRadius)),
          ),
          buildCorner(
            alignment: Alignment.bottomRight,
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(cornerRadius)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Đưa mã QR thiết bị vào khung hình',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Định dạng: DEVICE:<Mã tài sản>',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Đang tra cứu thiết bị...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
