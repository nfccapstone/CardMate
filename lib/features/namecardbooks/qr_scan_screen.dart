import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cardmate/features/namecardbooks/card_controller.dart';
import 'package:cardmate/features/home/home_controller.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final CardController cardController = Get.find<CardController>();
  MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  Future<void> _processQRCode(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      // URL에서 cardId 추출
      final uri = Uri.parse(code);
      final cardId = uri.pathSegments.last;

      // 명함 추가
      await cardController.addCardById(cardId);

      // 스캔 중지
      await controller.stop();

      // 성공 메시지 표시
      Get.snackbar(
        '성공',
        '명함이 추가되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // 명함첩 화면으로 돌아가기
      Get.until((route) => route.settings.name == '/home');
    } catch (e) {
      Get.snackbar(
        '오류',
        '명함 추가 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'QR 코드 스캔',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          const Text(
            'QR 코드를 스캔하여\n명함을 추가하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            if (barcode.rawValue != null) {
                              _processQRCode(barcode.rawValue!);
                              return;
                            }
                          }
                        },
                      ),
                      // 스캔 영역 표시
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ScannerOverlayPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: const Text(
              'QR 코드를 사각형 안에 맞춰주세요',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 스캔 영역의 크기
    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    // 스캔 영역 그리기
    canvas.drawRect(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
      paint,
    );

    // 모서리 강조
    final cornerLength = scanAreaSize * 0.1;
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // 왼쪽 상단 모서리
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // 오른쪽 상단 모서리
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // 왼쪽 하단 모서리
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );

    // 오른쪽 하단 모서리
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize - cornerLength,
          scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize,
          scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
