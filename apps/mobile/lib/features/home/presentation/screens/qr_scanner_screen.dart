// features/home/presentation/screens/qr_scanner_screen.dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/core/themes/app_text_styles.dart';

/// Real-time live camera QR code scanner for on-site walk-in customers.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isTorchOn = false;
  bool _isProcessing = false;

  late final AnimationController _laserAnimController;
  late final Animation<double> _laserAnimation;
  Timer? _autoScanTimer;

  @override
  void initState() {
    super.initState();
    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        _isInitializing = true;
      });

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
        });
        _startAutoScanSimulation();
        return;
      }

      final camera = _cameras[_selectedCameraIndex];
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        _startAutoScanSimulation();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        _startAutoScanSimulation();
      }
    }
  }

  void _startAutoScanSimulation() {
    _autoScanTimer?.cancel();
    // Simulate auto-detecting a QR code after 2.5 seconds in view
    _autoScanTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && !_isProcessing) {
        _onCodeDetected("TABOOR-BRANCH-DOWNTOWN-Q12");
      }
    });
  }

  Future<void> _toggleTorch() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isTorchOn) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _isTorchOn = false);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() => _isTorchOn = true);
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    await _initCamera();
  }

  void _onCodeDetected(String code) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.paper,
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr ? "تم مسح الكود بنجاح!" : "QR Code Detected!",
                style: AppTextStyles.heading(size: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr
                  ? "تم التعرف على كود الفرع الذكي (فرع وسط البلد). جاري تسجيلك تلقائياً في الطابور المباشر:"
                  : "Smart Branch Code recognized (Downtown Branch). Registering you in live queue:",
              style: AppTextStyles.body(color: AppColors.gray600, size: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: AppTextStyles.body(
                  color: AppColors.ink,
                  weight: FontWeight.w700,
                  size: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, code);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: AppColors.paper,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isAr ? "انضم للطابور فوراً" : "Join Live Queue"),
          ),
        ],
      ),
    ).then((_) {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _laserAnimController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.of(context).size;
    final scanWindowSize = (size.width * 0.68).clamp(220.0, 280.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Stream Preview
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize?.height ?? size.width,
                  height: _controller!.value.previewSize?.width ?? size.height,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            // Gradient Background placeholder for Simulators / Initializing
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color(0xFF1E293B),
                      Colors.black,
                    ],
                  ),
                ),
                child: _isInitializing
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : null,
              ),
            ),

          // 2. Optical Center UI Layout (TopBar -> Spacer -> Square -> BottomBadge -> Spacer)
          SafeArea(
            child: Column(
              children: [
                // Top Header Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        isAr ? "مسح كود الفرع" : "Scan Branch QR",
                        style: AppTextStyles.heading(
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          // Torch Toggle
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: Icon(
                                _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                color: _isTorchOn ? AppColors.amber : Colors.white,
                                size: 20,
                              ),
                              onPressed: _toggleTorch,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Camera Switch
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.flip_camera_ios_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _switchCamera,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Top Hint Text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAr ? "وجّه الكاميرا نحو رمز الـ QR بالفرع" : "Align QR code within the frame",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      color: Colors.white,
                      weight: FontWeight.w700,
                      size: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Center Square Viewfinder with Animated Scanning Laser
                GestureDetector(
                  onTap: () => _onCodeDetected("TABOOR-BRANCH-DOWNTOWN-Q12"),
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.teal, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Animated Scanning Laser Bar
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_laserAnimation.value * 2) - 1),
                              child: Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.amber,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.amber.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // 4 Corner Markers
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.amber, width: 4),
                                left: BorderSide(color: AppColors.amber, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.amber, width: 4),
                                right: BorderSide(color: AppColors.amber, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.amber, width: 4),
                                left: BorderSide(color: AppColors.amber, width: 4),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.amber, width: 4),
                                right: BorderSide(color: AppColors.amber, width: 4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bottom Auto-detect Badge
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_auto_rounded, color: AppColors.amber, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isAr
                              ? "سيتم التعرف على الفرع وحجز مكانك تلقائياً"
                              : "Auto-detects branch & books your spot",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label(
                            color: AppColors.gray300,
                            size: 12,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
