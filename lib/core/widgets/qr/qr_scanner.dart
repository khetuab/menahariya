// lib/core/widgets/qr/qr_scanner.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_dimens.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/widgets/buttons/icon_button_widget.dart';

class QRScanner extends StatefulWidget {
  final Function(String) onQRScanned;
  final VoidCallback? onClose;
  final String? title;
  final bool autoStart;
  final Duration scanDelay;

  const QRScanner({
    Key? key,
    required this.onQRScanned,
    this.onClose,
    this.title,
    this.autoStart = true,
    this.scanDelay = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late MobileScannerController _controller;
  bool _isScanning = true;
  bool _torchEnabled = false;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: _torchEnabled,
    );

    if (widget.autoStart) {
      _startScanner();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startScanner() {
    setState(() => _isScanning = true);
    _controller.start();
  }

  void _stopScanner() {
    setState(() => _isScanning = false);
    _controller.stop();
  }

  void _toggleTorch() {
    setState(() => _torchEnabled = !_torchEnabled);
    _controller.toggleTorch();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _stopScanner();
        widget.onQRScanned(barcode.rawValue!);

        // Restart scanning after delay
        Future.delayed(widget.scanDelay, () {
          if (mounted) {
            _startScanner();
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: Colors.black,
      child: Stack(
         children: [
          // Scanner View
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: AppDimens.margin16),
                      Text(
                        'Camera permission required',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppDimens.margin8),
                      Text(
                        'Please enable camera access to scan QR codes',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.margin16),
                      ElevatedButton(
                        onPressed: () {
                          _controller.start();
                        },
                        child: const Text('Request Permission'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanning Overlay
          _buildScanOverlay(context),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppDimens.padding8,
                left: AppDimens.padding16,
                right: AppDimens.padding16,
                bottom: AppDimens.padding16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Close Button
                  IconButtonWidget(
                    icon: Icons.close_rounded,
                    onPressed: widget.onClose ?? () => Get.back(),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    iconColor: Colors.white,
                  ),
                  const Spacer(),
                  // Title
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: AppFonts.semiBold,
                      ),
                    ),
                  const Spacer(),
                  // Torch Button
                  IconButtonWidget(
                    icon: _torchEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onPressed: _toggleTorch,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Info
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.padding16,
                      vertical: AppDimens.padding8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppDimens.radius30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: AppDimens.iconSize16,
                        ),
                        const SizedBox(width: AppDimens.margin8),
                        Text(
                          'Align QR code within frame',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    return CustomPaint(
      painter: ScannerOverlayPainter(
        scanLineColor: AppColors.primaryGreen,
        overlayColor: Colors.black.withOpacity(0.5),
      ),
      child: Container(),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color scanLineColor;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.scanLineColor,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;

    // Calculate scan area (80% of screen width, centered)
    final scanWidth = size.width * 0.7;
    final scanHeight = scanWidth * 0.8;
    final left = (size.width - scanWidth) / 2;
    final top = (size.height - scanHeight) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanWidth, scanHeight);

    // Draw overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(scanRect),
      ),
      paint,
    );

    // Draw scan line
    final linePaint = Paint()
      ..color = scanLineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw corner lines
    final cornerPaint = Paint()
      ..color = scanLineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanWidth - cornerLength, top),
      Offset(left + scanWidth, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanWidth, top),
      Offset(left + scanWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanHeight - cornerLength),
      Offset(left, top + scanHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanHeight),
      Offset(left + cornerLength, top + scanHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanWidth - cornerLength, top + scanHeight),
      Offset(left + scanWidth, top + scanHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanWidth, top + scanHeight - cornerLength),
      Offset(left + scanWidth, top + scanHeight),
      cornerPaint,
    );

    // Draw scanning animation line
    final animationPaint = Paint()
      ..color = scanLineColor.withOpacity(0.5)
      ..strokeWidth = 2;

    final animationY = top + (DateTime.now().millisecondsSinceEpoch % 2000) / 2000 * scanHeight;

    canvas.drawLine(
      Offset(left, animationY),
      Offset(left + scanWidth, animationY),
      animationPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}