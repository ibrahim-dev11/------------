import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanQr,
            style: const TextStyle(
                fontFamily: 'NotoSansArabic',
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                final isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: isOn ? Colors.yellow : Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null &&
                    (code.startsWith('https://edubook.app/institutions/') ||
                     code.startsWith('edubook://institutions/'))) {
                  _scanned = true;
                  final String id = code.split('/').last;
                  _controller.stop();
                  context.replace('/institutions/$id');
                  break;
                }
              }
            },
          ),
          // Professional Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: Container(),
          ),
          // Animated Scanner Line
          const _ScannerLine(),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  l10n.scanQrInstructions,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'NotoSansArabic',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.viewInstitutionInfo,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'NotoSansArabic',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(30));

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rrect),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    const len = 40.0;
    
    // Top Left
    path.moveTo(rect.left, rect.top + len);
    path.lineTo(rect.left, rect.top);
    path.lineTo(rect.left + len, rect.top);

    // Top Right
    path.moveTo(rect.right - len, rect.top);
    path.lineTo(rect.right, rect.top);
    path.lineTo(rect.right, rect.top + len);

    // Bottom Left
    path.moveTo(rect.left, rect.bottom - len);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.left + len, rect.bottom);

    // Bottom Right
    path.moveTo(rect.right - len, rect.bottom);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.right, rect.bottom - len);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerLine extends StatefulWidget {
  const _ScannerLine();

  @override
  State<_ScannerLine> createState() => _ScannerLineState();
}

class _ScannerLineState extends State<_ScannerLine> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final top = MediaQuery.of(context).size.height / 2 - 125 + (_ctrl.value * 250);
        return Positioned(
          top: top,
          left: MediaQuery.of(context).size.width / 2 - 125,
          width: 250,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0),
                  AppColors.primary,
                  AppColors.primary.withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
